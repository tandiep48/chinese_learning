/// Profile module — the change-password form.
///
/// Ported from `PasswordForm.tsx` + `useProfile`: two password fields validated
/// client-side (required, must match), then `POST /api/user/change-password`.
/// A status line shows progress, success or the server's message; the fields
/// clear on success.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_exception.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../data/profile_repository.dart';
import '../styles/profile_styles.dart';

class PasswordForm extends ConsumerStatefulWidget {
  const PasswordForm({super.key});

  @override
  ConsumerState<PasswordForm> createState() => _PasswordFormState();
}

class _PasswordFormState extends ConsumerState<PasswordForm> {
  final _new = TextEditingController();
  final _confirm = TextEditingController();
  String _message = '';
  bool _error = false;
  bool _busy = false;

  @override
  void dispose() {
    _new.dispose();
    _confirm.dispose();
    super.dispose();
  }

  void _status(String text, {bool error = false}) => setState(() {
    _message = text;
    _error = error;
  });

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context);
    if (_new.text.isEmpty) {
      _status(l10n.profilePasswordRequired, error: true);
      return;
    }
    if (_new.text != _confirm.text) {
      _status(l10n.profilePasswordMismatch, error: true);
      return;
    }
    setState(() => _busy = true);
    _status(l10n.profilePasswordUpdating);
    try {
      await ref
          .read(profileRepositoryProvider)
          .changePassword(_new.text, _confirm.text);
      if (!mounted) return;
      _new.clear();
      _confirm.clear();
      _status(l10n.profilePasswordUpdated);
    } on ApiException catch (e) {
      if (mounted) _status(e.message, error: true);
    } catch (_) {
      if (mounted) _status(l10n.profilePasswordFailed, error: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      decoration: ProfileStyles.cardDecoration,
      padding: ProfileStyles.cardPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _new,
            obscureText: true,
            autofillHints: const [AutofillHints.newPassword],
            decoration: InputDecoration(labelText: l10n.profileNewPassword),
          ),
          ProfileStyles.gap12,
          TextField(
            controller: _confirm,
            obscureText: true,
            autofillHints: const [AutofillHints.newPassword],
            decoration: InputDecoration(labelText: l10n.profileConfirmPassword),
            onSubmitted: (_) => _busy ? null : _submit(),
          ),
          ProfileStyles.gap16,
          FilledButton(
            onPressed: _busy ? null : _submit,
            child: Text(l10n.profileChangePassword),
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
    );
  }
}
