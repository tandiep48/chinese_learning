/// Auth module — the login screen.
///
/// Native Material sign-in form. On submit it calls [AuthNotifier.login];
/// success flips auth status and the router redirect lands the user on home,
/// failure is caught locally and shown inline (global auth state is untouched).
/// Ported from the web login flow (`yi-chinese-manage` login page +
/// `AuthProvider.login`).
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_exception.dart';
import '../../../l10n/app_localizations.dart';
import '../providers/auth_provider.dart';
import '../styles/login_styles.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context);
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      await ref.read(authNotifierProvider.notifier).login(
            _usernameController.text.trim(),
            _passwordController.text,
          );
      // On success the router redirects; nothing else to do here.
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _error = e.message.isNotEmpty ? e.message : l10n.loginFailed);
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = l10n.loginFailed);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: LoginStyles.pagePadding,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: LoginStyles.maxFormWidth),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      l10n.loginTitle,
                      style: theme.textTheme.displaySmall,
                      textAlign: TextAlign.center,
                    ),
                    LoginStyles.titleGap,
                    TextFormField(
                      controller: _usernameController,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.username],
                      enabled: !_submitting,
                      decoration: InputDecoration(
                        labelText: l10n.loginUsernameLabel,
                        border: const OutlineInputBorder(),
                      ),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? l10n.loginFieldRequired : null,
                    ),
                    LoginStyles.fieldGap,
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      textInputAction: TextInputAction.done,
                      autofillHints: const [AutofillHints.password],
                      enabled: !_submitting,
                      onFieldSubmitted: (_) => _submit(),
                      decoration: InputDecoration(
                        labelText: l10n.loginPasswordLabel,
                        border: const OutlineInputBorder(),
                      ),
                      validator: (v) =>
                          (v == null || v.isEmpty) ? l10n.loginFieldRequired : null,
                    ),
                    if (_error != null) ...[
                      LoginStyles.fieldGap,
                      Text(
                        _error!,
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(color: theme.colorScheme.error),
                      ),
                    ],
                    LoginStyles.titleGap,
                    SizedBox(
                      height: LoginStyles.submitHeight,
                      child: FilledButton(
                        onPressed: _submitting ? null : _submit,
                        child: _submitting
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Text(l10n.loginSubmit),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
