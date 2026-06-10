import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../../localization/app_localization.dart';
import '../../theme/app_theme.dart';
import '../../models/camera_model.dart' as fs;
import '../../widgets/common_widgets.dart';
import '../../providers/auth_provider.dart';
import '../../repositories/chip_binding_repository.dart';
import '../../repositories/camera_repository.dart';
import '../../utils/tenda_camera_helper.dart';
import 'admin_camera_live_screen.dart';

class CameraConfigScreen extends StatelessWidget {
  /// Khi `true`, không render Scaffold/AppBar (dùng trong [ServerCameraHubScreen]).
  final bool embedded;

  const CameraConfigScreen({super.key, this.embedded = false});

  void _showAddCameraSheet(
    BuildContext context,
    String familyId,
    String chipId,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: _AddCameraSheet(familyId: familyId, chipId: chipId),
      ),
    );
  }

  void _showBindChipSheet(
    BuildContext context,
    String familyId,
    ChipBindingRepository chipBindingRepo,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: _BindChipSheet(
          familyId: familyId,
          chipBindingRepo: chipBindingRepo,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final familyId = context.watch<AuthProvider>().user?.familyId;
    final cameraRepo = CameraRepository();
    final chipBindingRepo = ChipBindingRepository();

    final body = familyId == null || familyId.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(loc.translate('create_family_before_camera')),
              ),
            )
          : StreamBuilder<List<fs.CameraModel>>(
              stream: cameraRepo.getCameras(familyId),
              builder: (context, snapshot) {
                final cameras = snapshot.data ?? [];
                final online = cameras.where((c) => c.status == 'online').length;
                final offline = cameras.length - online;

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      StreamBuilder<DocumentSnapshot<Map<String, dynamic>>?>(
                        stream: chipBindingRepo.watchFamilyChip(familyId),
                        builder: (context, chipSnap) {
                          final chipDoc = chipSnap.data;
                          final chipId =
                              (chipDoc?.data()?['chipId'] as String?)?.trim();
                          final hasChip = chipId != null && chipId.isNotEmpty;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _ChipBindingCard(
                                chipId: chipId,
                                onBind: () => _showBindChipSheet(
                                  context,
                                  familyId,
                                  chipBindingRepo,
                                ),
                                onUnbind: hasChip
                                    ? () => chipBindingRepo
                                        .unbindChipFromFamily(familyId)
                                    : null,
                              ),
                              const SizedBox(height: 12),
                              ElevatedButton.icon(
                                onPressed: !hasChip || cameras.length >= 4
                                    ? null
                                    : () => _showAddCameraSheet(
                                          context,
                                          familyId,
                                          chipId,
                                        ),
                                icon: const Icon(Icons.add_rounded, size: 20),
                                label: Text(
                                  !hasChip
                                      ? loc.translate('bind_chip_first')
                                      : cameras.length >= 4
                                          ? loc.translate(
                                              'camera_limit_reached',
                                            )
                                          : loc.translate('add_new_camera'),
                                ),
                                style: ElevatedButton.styleFrom(
                                  minimumSize:
                                      const Size(double.infinity, 46),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _MiniStat(
                              label: loc.translate('stat_total'),
                              value: '${cameras.length}',
                              icon: Icons.videocam_rounded,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _MiniStat(
                              label: loc.translate('stat_online'),
                              value: '$online',
                              icon: Icons.wifi_rounded,
                              valueColor: AppTheme.primary,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _MiniStat(
                              label: loc.translate('stat_offline'),
                              value: '$offline',
                              icon: Icons.wifi_off_rounded,
                              valueColor: AppTheme.errorColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SectionHeader(title: loc.translate('configured_cameras')),
                      if (snapshot.connectionState == ConnectionState.waiting &&
                          !snapshot.hasData)
                        const Padding(
                          padding: EdgeInsets.all(24),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      else if (cameras.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Text(
                            loc.translate('no_cameras_chip_hint'),
                            style: const TextStyle(color: AppTheme.textSecondary),
                          ),
                        )
                      else
                        ...cameras.map(
                          (cam) => _CameraConfigCard(
                            camera: cam,
                            onOpenLive: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      AdminCameraLiveScreen(camera: cam),
                                ),
                              );
                            },
                            onToggleStatus: () async {
                              final next =
                                  cam.status == 'online' ? 'offline' : 'online';
                              await cameraRepo.updateCameraStatus(cam.id, next);
                            },
                            onDelete: () => cameraRepo.deleteCamera(cam.id),
                          ),
                        ),
                      SizedBox(height: embedded ? 24 : 80),
                    ],
                  ),
                );
              },
            );

    if (embedded) return body;

    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: SubtitleAppBar(
        title: loc.cameraConfig,
        subtitle: loc.translate('camera_config_subtitle'),
      ),
      body: body,
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? valueColor;

  const _MiniStat({
    required this.label,
    required this.value,
    required this.icon,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: AppTheme.surface2,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.primaryContainer),
      ),
      child: Column(
        children: [
          Icon(icon, size: 18, color: valueColor ?? AppTheme.primary),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: valueColor ?? AppTheme.primaryDark,
            ),
          ),
          Text(
            label,
            style: const TextStyle(fontSize: 9.5, color: AppTheme.primary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _ChipBindingCard extends StatelessWidget {
  final String? chipId;
  final VoidCallback onBind;
  final VoidCallback? onUnbind;

  const _ChipBindingCard({
    required this.chipId,
    required this.onBind,
    required this.onUnbind,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final hasChip = chipId != null && chipId!.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: hasChip ? AppTheme.surface2 : const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hasChip ? AppTheme.primaryContainer : AppTheme.warningColor,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: (hasChip ? AppTheme.primary : AppTheme.warningColor)
                  .withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.memory_rounded,
              color: hasChip ? AppTheme.primary : AppTheme.warningColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  loc.translate('family_chip'),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  hasChip ? chipId! : loc.translate('no_chip_bound'),
                  style: TextStyle(
                    fontSize: 12,
                    color: hasChip
                        ? AppTheme.textSecondary
                        : AppTheme.warningColor,
                    fontFamily: hasChip ? 'monospace' : null,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: onBind,
            child: Text(
              loc.translate(hasChip ? 'change_chip' : 'bind_chip'),
            ),
          ),
          if (hasChip)
            IconButton(
              icon: const Icon(Icons.link_off_rounded),
              color: AppTheme.errorColor,
              onPressed: onUnbind,
            ),
        ],
      ),
    );
  }
}

class _BindChipSheet extends StatefulWidget {
  final String familyId;
  final ChipBindingRepository chipBindingRepo;

  const _BindChipSheet({
    required this.familyId,
    required this.chipBindingRepo,
  });

  @override
  State<_BindChipSheet> createState() => _BindChipSheetState();
}

class _BindChipSheetState extends State<_BindChipSheet> {
  final _chipCtrl = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _chipCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final loc = AppLocalizations.of(context);
    final chipId = _chipCtrl.text.trim();
    if (chipId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.translate('chip_id_required'))),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      await widget.chipBindingRepo.bindChipToFamily(
        familyId: widget.familyId,
        chipId: chipId,
      );
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.translate('chip_bound'))),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${loc.translate('error_prefix')}: $e')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Text(
            loc.translate('bind_chip'),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            loc.translate('bind_chip_help'),
            style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _chipCtrl,
            decoration: InputDecoration(
              labelText: loc.translate('chip_id_label'),
              hintText: 'chip_living_room_01',
              prefixIcon: const Icon(Icons.memory_outlined),
            ),
          ),
          const SizedBox(height: 18),
          ElevatedButton.icon(
            onPressed: _saving ? null : _save,
            icon: _saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.link_rounded),
            label: Text(loc.translate('bind_chip')),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 46),
            ),
          ),
        ],
      ),
    );
  }
}

class _CameraConfigCard extends StatelessWidget {
  final fs.CameraModel camera;
  final VoidCallback onOpenLive;
  final VoidCallback onToggleStatus;
  final VoidCallback onDelete;

  const _CameraConfigCard({
    required this.camera,
    required this.onOpenLive,
    required this.onToggleStatus,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final isLive = camera.status == 'online';
    final isOffline = camera.status == 'offline';
    final chipLabel = camera.cameraIp.isNotEmpty
        ? '${loc.translate('tenda_ip_label')}: ${camera.cameraIp}'
        : (camera.chipId.isNotEmpty
            ? '${loc.translate('chip_prefix')} ${camera.chipId}'
            : camera.relayCameraId);

    return InkWell(
      onTap: onOpenLive,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: isOffline ? const Color(0xFF1A0A0A) : const Color(0xFF1A2A1A),
          borderRadius: BorderRadius.circular(14),
          border: isOffline
              ? Border.all(color: AppTheme.errorColor.withOpacity(0.4))
              : Border.all(color: AppTheme.primaryLight.withOpacity(0.15)),
        ),
        child: Column(
          children: [
          // Preview
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(13)),
            child: Container(
              height: 90,
              width: double.infinity,
              color: isOffline
                  ? const Color(0xFF0D0505)
                  : const Color(0xFF0A1A0A),
              child: Stack(
                children: [
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.videocam_rounded,
                          size: 32,
                          color: isOffline
                              ? AppTheme.errorColor.withOpacity(0.4)
                              : AppTheme.primaryLight.withOpacity(0.25),
                        ),
                        if (!isOffline) ...[
                          const SizedBox(height: 6),
                          Text(
                            chipLabel,
                            style: TextStyle(
                              fontSize: 10,
                              color: AppTheme.primaryLight.withOpacity(0.5),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  // Status badge
                  Positioned(
                    top: 8,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: isLive
                            ? AppTheme.errorColor
                            : const Color(0xFFFF9800),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        isLive
                            ? loc.translate('camera_live')
                            : loc.translate('camera_offline_badge'),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Meta
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        camera.name,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFE8F5E9),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Container(
                            width: 5,
                            height: 5,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isLive
                                  ? AppTheme.primaryLight
                                  : AppTheme.errorColor,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            chipLabel,
                            style: const TextStyle(
                              fontSize: 10,
                              color: Color(0xFF81C784),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                _DarkButton(
                  label: isOffline
                      ? loc.translate('mark_online')
                      : loc.translate('mark_offline'),
                  icon: Icons.sync_rounded,
                  color: AppTheme.primaryLight,
                  onTap: onToggleStatus,
                ),
                const SizedBox(width: 6),
                _DarkButton(
                  label: loc.translate('remove'),
                  icon: Icons.delete_outline_rounded,
                  color: AppTheme.errorColor,
                  onTap: onDelete,
                ),
              ],
            ),
          ),
          ],
        ),
      ),
    );
  }

}

class _DarkButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _DarkButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.4)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CpuLoadBar extends StatelessWidget {
  final double load;

  const _CpuLoadBar({required this.load});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text(
          'CPU',
          style: TextStyle(fontSize: 9, color: Color(0xFF81C784)),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: load,
              minHeight: 4,
              backgroundColor: Colors.white.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation<Color>(
                load > 0.7 ? AppTheme.warningColor : AppTheme.primaryLight,
              ),
            ),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          '${(load * 100).round()}%',
          style: const TextStyle(fontSize: 9, color: Color(0xFF81C784)),
        ),
      ],
    );
  }
}

class _AddCameraSheet extends StatefulWidget {
  final String familyId;
  final String chipId;

  const _AddCameraSheet({
    required this.familyId,
    required this.chipId,
  });

  @override
  State<_AddCameraSheet> createState() => _AddCameraSheetState();
}

class _AddCameraSheetState extends State<_AddCameraSheet> {
  static const _modeTenda = 0;

  int _mode = _modeTenda;
  String _cameraType = 'tenda_cp6';
  final _nameCtrl = TextEditingController();
  final _ipCtrl = TextEditingController(text: '192.168.0.102');
  final _relayIdCtrl = TextEditingController();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _syncTendaFields();
    _ipCtrl.addListener(_syncTendaFields);
  }

  void _syncTendaFields() {
    if (_mode != _modeTenda) return;
    final ip = _ipCtrl.text.trim();
    if (!TendaCameraHelper.isValidIpv4(ip)) return;
    _relayIdCtrl.text = TendaCameraHelper.relayIdFromIp(ip);
    if (_nameCtrl.text.trim().isEmpty ||
        _nameCtrl.text.startsWith('Tenda CP6')) {
      _nameCtrl.text = TendaCameraHelper.defaultName(ip);
    }
    setState(() {});
  }

  @override
  void dispose() {
    _ipCtrl.removeListener(_syncTendaFields);
    _nameCtrl.dispose();
    _ipCtrl.dispose();
    _relayIdCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    final relayCameraId = _relayIdCtrl.text.trim();
    if (name.isEmpty || relayCameraId.isEmpty) return;

    String cameraIp = '';
    String rtspMain = '';
    String rtspSub = '';
    if (_mode == _modeTenda) {
      cameraIp = _ipCtrl.text.trim();
      if (!TendaCameraHelper.isValidIpv4(cameraIp)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context).translate('tenda_ip_invalid'),
            ),
          ),
        );
        return;
      }
      rtspMain = TendaCameraHelper.mainRtspUrl(cameraIp);
      rtspSub = TendaCameraHelper.subRtspUrl(cameraIp);
    }

    setState(() => _saving = true);
    final id = await CameraRepository().addCamera(
      widget.familyId,
      widget.chipId,
      name,
      relayCameraId: relayCameraId,
      cameraIp: cameraIp,
      rtspMainUrl: rtspMain,
      rtspSubUrl: rtspSub,
      cameraType: _cameraType,
    );
    if (!mounted) return;
    setState(() => _saving = false);
    final loc = AppLocalizations.of(context);
    if (id != null) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.translate('camera_registered'))),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.translate('camera_add_failed'))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Text(
            loc.translate('add_camera_sheet_title'),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _cameraType,
            decoration: InputDecoration(
              labelText: loc.translate('camera_type_label'),
              prefixIcon: const Icon(Icons.router_outlined),
            ),
            items: [
              DropdownMenuItem(
                value: 'tenda_cp6',
                child: Text(loc.translate('add_camera_mode_tenda')),
              ),
            ],
            onChanged: (value) {
              if (value == null) return;
              setState(() {
                _cameraType = value;
                _mode = _modeTenda;
              });
              _syncTendaFields();
            },
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _ipCtrl,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: loc.translate('tenda_ip_label'),
              hintText: '192.168.0.102',
              prefixIcon: const Icon(Icons.lan_outlined),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            loc.translate('camera_auto_config_hint'),
            style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 18),
          ElevatedButton.icon(
            onPressed: _saving ? null : _save,
            icon: _saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.add_rounded),
            label: Text(loc.translate('add_new_camera')),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 44),
            ),
          ),
        ],
      ),
    );
  }
}
