import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../config/relay_config.dart';

/// HTTP client — khớp FastAPI relay trên VPS (`main.py`).
class RelayApiClient {
  RelayApiClient._();

  static final RelayApiClient instance = RelayApiClient._();

  Map<String, String> _authHeaders(String bearerToken) => {
        'Authorization': 'Bearer $bearerToken',
        'Content-Type': 'application/json',
      };

  /// GET `/cameras` → `{ "online_cameras": ["cam_test_01", ...] }`
  Future<List<String>> getOnlineCameras(String bearerToken) async {
    final response = await http
        .get(RelayConfig.camerasUri(), headers: _authHeaders(bearerToken))
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 401 || response.statusCode == 403) {
      throw RelayApiException('relay_auth_failed', statusCode: response.statusCode);
    }
    if (response.statusCode != 200) {
      throw RelayApiException('cameras_list_failed', statusCode: response.statusCode);
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final list = body['online_cameras'] as List<dynamic>? ?? [];
    return list.map((e) => e.toString()).toList();
  }

  /// POST `/watch/{cameraId}` — Flutter gửi offer, nhận answer.
  Future<Map<String, String>> postWatchOffer({
    required String relayCameraId,
    required String bearerToken,
    required String sdp,
    required String type,
  }) async {
    final response = await http
        .post(
          RelayConfig.watchUri(relayCameraId),
          headers: _authHeaders(bearerToken),
          body: jsonEncode({'sdp': sdp, 'type': type}),
        )
        .timeout(const Duration(seconds: 20));

    if (response.statusCode == 404) {
      throw RelayApiException('camera_not_online', statusCode: 404, body: response.body);
    }
    if (response.statusCode == 401 || response.statusCode == 403) {
      throw RelayApiException('relay_auth_failed', statusCode: response.statusCode);
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw RelayApiException(
        'watch_failed',
        statusCode: response.statusCode,
        body: response.body,
      );
    }

    final answer = jsonDecode(response.body) as Map<String, dynamic>;
    final answerSdp = answer['sdp'] as String?;
    final answerType = answer['type'] as String?;
    if (answerSdp == null || answerType == null) {
      throw RelayApiException('invalid_answer', body: response.body);
    }

    return {'sdp': answerSdp, 'type': answerType};
  }
}

class RelayApiException implements Exception {
  final String code;
  final int? statusCode;
  final String? body;

  RelayApiException(this.code, {this.statusCode, this.body});

  @override
  String toString() =>
      'RelayApiException($code${statusCode != null ? ' HTTP $statusCode' : ''})';
}
