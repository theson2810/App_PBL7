import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

import '../../config/relay_config.dart';
import 'relay_api_client.dart';
import 'relay_token_service.dart';

enum RelayWatchState {
  idle,
  loading,
  connected,
  reconnecting,
  failed,
  disconnected,
}

class RelayWatchService {
  RTCPeerConnection? _pc;
  RelayWatchState _state = RelayWatchState.idle;
  String? _errorCode;
  Timer? _reconnectTimer;
  int _reconnectAttempt = 0;
  int _sessionId = 0;
  bool _closing = false;

  static const _maxReconnectAttempts = 5;

  RelayWatchState get state => _state;
  String? get errorCode => _errorCode;

  void Function(RelayWatchState state, String? errorCode)? onStateChanged;

  void _emit(RelayWatchState next, {String? error}) {
    _state = next;
    _errorCode = error;
    onStateChanged?.call(next, error);
  }

  Future<void> watch({
    required String relayCameraId,
    required RTCVideoRenderer renderer,
  }) async {
    await disconnect();
    _reconnectAttempt = 0;
    await _connectInternal(relayCameraId: relayCameraId, renderer: renderer);
  }

  Future<void> reconnect({
    required String relayCameraId,
    required RTCVideoRenderer renderer,
  }) async {
    _reconnectTimer?.cancel();
    _emit(RelayWatchState.reconnecting);
    await _closePcOnly(clearRenderer: true, renderer: renderer);
    await _connectInternal(relayCameraId: relayCameraId, renderer: renderer);
  }

  Future<void> _connectInternal({
    required String relayCameraId,
    required RTCVideoRenderer renderer,
  }) async {
    final currentSession = ++_sessionId;
    _closing = false;
    _emit(RelayWatchState.loading);

    try {
      final bearerToken =
          await RelayTokenService.instance.fetchWatchToken(relayCameraId);

      final pc = await createPeerConnection(RelayConfig.iceServers);
      _pc = pc;

      await pc.addTransceiver(
        kind: RTCRtpMediaType.RTCRtpMediaTypeVideo,
        init: RTCRtpTransceiverInit(
          direction: TransceiverDirection.RecvOnly,
        ),
      );

      final trackCompleter = Completer<void>();
      final iceGatheringCompleter = Completer<void>();

      pc.onTrack = (RTCTrackEvent event) {
        if (currentSession != _sessionId) return;
        if (event.streams.isEmpty) return;
        renderer.srcObject = event.streams.first;
        _reconnectAttempt = 0;
        _emit(RelayWatchState.connected);
        if (!trackCompleter.isCompleted) trackCompleter.complete();
      };

      pc.onConnectionState = (RTCPeerConnectionState state) {
        if (kDebugMode) debugPrint('RelayWatchService PC state: $state');
        if (currentSession != _sessionId || _closing) return;
        if (state == RTCPeerConnectionState.RTCPeerConnectionStateFailed ||
            state ==
                RTCPeerConnectionState.RTCPeerConnectionStateDisconnected) {
          _scheduleReconnect(relayCameraId: relayCameraId, renderer: renderer);
        }
      };

      pc.onIceGatheringState = (RTCIceGatheringState state) {
        if (kDebugMode) debugPrint('RelayWatchService ICE gathering: $state');
        if (state == RTCIceGatheringState.RTCIceGatheringStateComplete &&
            !iceGatheringCompleter.isCompleted) {
          iceGatheringCompleter.complete();
        }
      };

      pc.onIceConnectionState = (RTCIceConnectionState state) {
        if (kDebugMode) debugPrint('RelayWatchService ICE: $state');
        if (currentSession != _sessionId || _closing) return;
        if (state == RTCIceConnectionState.RTCIceConnectionStateFailed ||
            state == RTCIceConnectionState.RTCIceConnectionStateDisconnected) {
          _scheduleReconnect(relayCameraId: relayCameraId, renderer: renderer);
        }
      };

      final offer = await pc.createOffer();
      await pc.setLocalDescription(offer);
      await iceGatheringCompleter.future.timeout(
        const Duration(seconds: 8),
        onTimeout: () {},
      );
      if (currentSession != _sessionId) return;

      final localDescription = await pc.getLocalDescription();
      final answerMap = await RelayApiClient.instance.postWatchOffer(
        relayCameraId: relayCameraId,
        bearerToken: bearerToken,
        sdp: localDescription?.sdp ?? offer.sdp ?? '',
        type: localDescription?.type ?? offer.type ?? 'offer',
      );

      if (currentSession != _sessionId) return;
      await pc.setRemoteDescription(
        RTCSessionDescription(answerMap['sdp']!, answerMap['type']!),
      );

      await trackCompleter.future.timeout(
        const Duration(seconds: 25),
        onTimeout: () {
          if (_state != RelayWatchState.connected) {
            throw TimeoutException('track_timeout');
          }
        },
      );
    } on RelayApiException catch (e) {
      _emit(RelayWatchState.failed, error: e.code);
      await _closePcOnly(clearRenderer: true, renderer: renderer);
    } on RelayTokenException catch (e) {
      _emit(RelayWatchState.failed, error: e.code);
      await _closePcOnly(clearRenderer: true, renderer: renderer);
    } on TimeoutException catch (_) {
      _emit(RelayWatchState.failed, error: 'track_timeout');
      await _closePcOnly(clearRenderer: true, renderer: renderer);
    } catch (e) {
      if (kDebugMode) debugPrint('RelayWatchService error: $e');
      _emit(RelayWatchState.failed, error: e.toString());
      await _closePcOnly(clearRenderer: true, renderer: renderer);
    }
  }

  void _scheduleReconnect({
    required String relayCameraId,
    required RTCVideoRenderer renderer,
  }) {
    if (_reconnectAttempt >= _maxReconnectAttempts) {
      _emit(RelayWatchState.failed, error: 'reconnect_exhausted');
      return;
    }
    if (_state == RelayWatchState.reconnecting ||
        _state == RelayWatchState.loading) {
      return;
    }

    _reconnectTimer?.cancel();
    _reconnectAttempt += 1;
    _emit(RelayWatchState.reconnecting);

    _reconnectTimer = Timer(Duration(seconds: 2 * _reconnectAttempt), () {
      reconnect(relayCameraId: relayCameraId, renderer: renderer);
    });
  }

  Future<void> disconnect() async {
    _reconnectTimer?.cancel();
    _reconnectAttempt = 0;
    _sessionId++;
    await _closePcOnly();
    if (_state != RelayWatchState.idle) {
      _emit(RelayWatchState.disconnected);
    }
  }

  Future<void> _closePcOnly({
    bool clearRenderer = false,
    RTCVideoRenderer? renderer,
  }) async {
    _closing = true;
    try {
      await _pc?.close();
    } catch (_) {}
    _pc = null;
    if (clearRenderer) {
      renderer?.srcObject = null;
    }
    _closing = false;
  }

  Future<void> dispose() async {
    await disconnect();
    onStateChanged = null;
    _emit(RelayWatchState.idle);
  }
}
