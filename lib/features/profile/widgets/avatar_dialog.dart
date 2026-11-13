/// Profile module — the avatar upload dialog.
///
/// Ported from `AvatarModal.tsx` + `useProfile`: pick one image (png / jpeg /
/// webp / gif), upload it to `POST /api/user/avatar`, then refresh the signed-in
/// user so the header shows the new picture.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/api/api_exception.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/providers/auth_provider.dart';
import '../data/profile_repository.dart';
import '../styles/profile_styles.dart';

Future<void> showAvatarDialog(BuildContext context) {
  return showDialog<void>(
    context: context,
    builder: (_) => const _AvatarDialog(),
  );
}

class _AvatarDialog extends ConsumerStatefulWidget {
  const _AvatarDialog();

  @override
  ConsumerState<_AvatarDialog> createState() => _AvatarDialogState();
}

class _AvatarDialogState extends ConsumerState<_AvatarDialog> {
  XFile? _file;
  String _message = '';
  bool _error = false;
  bool _busy = false;

  Future<void> _pick() async {
    final file = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
    );
    if (file != null && mounted) {
      setState(() {
        _file = file;
        _message = '';
      });
    }
  }

  Future<void> _upload() async {
    final l10n = AppLocalizations.of(context);
    final file = _file;
    if (file == null) {
      setState(() {
        _message = l10n.profileChooseAvatarFirst;
        _error = true;
      });
      return;
    }
    setState(() {
      _busy = true;
      _message = l10n.profileUploading;
      _error = false;
    });
    final repo = ref.read(profileRepositoryProvider);
    try {
      await repo.uploadAvatar(file.path, file.name);
      // Refresh the signed-in user so the header picks up the new avatar.
      final user = await repo.getProfileSummary();
      if (!mounted) return;
      ref.read(authNotifierProvider.notifier).setUser(user);
      setState(() {
        _message = l10n.profileAvatarUpdated;
        _error = false;
      });
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _message = e.message;
          _error = true;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _message = l10n.profileUploadFailed;
          _error = true;
        });
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.profileUploadAvatar),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          OutlinedButton.icon(
            onPressed: _busy ? null : _pick,
            icon: const Icon(Icons.photo_library_outlined),
            label: Text(
              _file?.name ?? l10n.profileChooseImage,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          ProfileStyles.gap12,
          FilledButton(
            onPressed: _busy ? null : _upload,
            child: Text(l10n.profileUploadAvatar),
          ),
          if (_message.isNotEmpty) ...[
            ProfileStyles.gap8,
            Text(
              _message,
              style: TextStyle(
                color: _error ? BrandColors.dangerText : BrandColors.mutedText,
              ),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(MaterialLocalizations.of(context).closeButtonLabel),
        ),
      ],
    );
  }
}
