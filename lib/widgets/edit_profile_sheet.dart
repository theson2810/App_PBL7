import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../localization/app_localization.dart';
import '../models/auth_models.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';

Future<bool?> showEditProfileSheet(
  BuildContext context, {
  required UserAccount user,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
      child: _EditProfileSheet(user: user),
    ),
  );
}

class _EditProfileSheet extends StatefulWidget {
  final UserAccount user;

  const _EditProfileSheet({required this.user});

  @override
  State<_EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<_EditProfileSheet> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _phoneCtrl;
  final _formKey = GlobalKey<FormState>();
  XFile? _pickedAvatar;
  Uint8List? _pickedAvatarBytes;
  bool _uploadingAvatar = false;

  ImageProvider<Object>? _avatarImage() {
    if (_pickedAvatarBytes != null) {
      return MemoryImage(_pickedAvatarBytes!);
    }
    final avatar = widget.user.avatar;
    if (avatar != null && avatar.isNotEmpty) {
      return NetworkImage(avatar);
    }
    return null;
  }

  bool get _hasAvatarImage =>
      _pickedAvatarBytes != null ||
      (widget.user.avatar != null && widget.user.avatar!.isNotEmpty);

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.user.fullName);
    _phoneCtrl = TextEditingController(text: widget.user.phone ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final loc = AppLocalizations.of(context);
    String? avatarUrl;
    if (_pickedAvatar != null) {
      setState(() => _uploadingAvatar = true);
      try {
        final uid = FirebaseAuth.instance.currentUser?.uid;
        if (uid == null) throw Exception('No active session');
        final bytes = await _pickedAvatar!.readAsBytes();
        final ref = FirebaseStorage.instance
            .ref('avatars/$uid/${DateTime.now().millisecondsSinceEpoch}.jpg');
        await ref.putData(
          bytes,
          SettableMetadata(contentType: 'image/jpeg'),
        );
        avatarUrl = await ref.getDownloadURL();
      } finally {
        if (mounted) setState(() => _uploadingAvatar = false);
      }
    }

    if (!mounted) return;
    final ok = await context.read<AuthProvider>().updateProfile(
          fullName: _nameCtrl.text.trim(),
          phone: _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim(),
          avatarUrl: avatarUrl,
        );

    if (!mounted) return;

    if (ok) {
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loc.translate('save_success')),
          backgroundColor: AppTheme.primary,
        ),
      );
    } else {
      final err = context.read<AuthProvider>().error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(err ?? loc.translate('save_failed'))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final auth = context.watch<AuthProvider>();

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      child: Form(
        key: _formKey,
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
              loc.translate('edit_profile'),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),
            Center(
              child: InkWell(
                borderRadius: BorderRadius.circular(42),
                onTap: auth.isLoading || _uploadingAvatar
                    ? null
                    : () async {
                        final image = await ImagePicker().pickImage(
                          source: ImageSource.gallery,
                          imageQuality: 75,
                          maxWidth: 512,
                        );
                        if (image == null || !mounted) return;
                        final bytes = await image.readAsBytes();
                        if (!mounted) return;
                        setState(() {
                          _pickedAvatar = image;
                          _pickedAvatarBytes = bytes;
                        });
                      },
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 42,
                      backgroundColor: widget.user.avatarColor,
                      backgroundImage: _avatarImage(),
                      child: !_hasAvatarImage
                          ? Text(
                              widget.user.initials,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                              ),
                            )
                          : null,
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.primary,
                        ),
                        child: const Icon(
                          Icons.photo_camera_outlined,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameCtrl,
              decoration: InputDecoration(
                labelText: loc.translate('full_name'),
                prefixIcon: const Icon(Icons.person_outline),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return loc.translate('name_required');
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _phoneCtrl,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: loc.translate('phone_number'),
                prefixIcon: const Icon(Icons.phone_outlined),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.user.email,
              style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: auth.isLoading || _uploadingAvatar ? null : _save,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
              child: auth.isLoading || _uploadingAvatar
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(loc.translate('save')),
            ),
            TextButton(
              onPressed: auth.isLoading ? null : () => Navigator.pop(context),
              child: Text(loc.translate('cancel')),
            ),
          ],
        ),
      ),
    );
  }
}
