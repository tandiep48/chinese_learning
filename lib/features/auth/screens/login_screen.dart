/// Auth module — the login screen.
///
/// Web-matched sign-in card ported from `yi-chinese-manage/app/learner/login/page.tsx`
/// (`AuthProvider.login`). On submit it calls [AuthNotifier.login]; success flips
/// auth status and the router redirect lands the user on home, failure is caught
/// locally and shown in the inline alert box.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api/api_exception.dart';
import '../../../core/theme/app_theme.dart';
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
      await ref
          .read(authNotifierProvider.notifier)
          .login(_usernameController.text.trim(), _passwordController.text);
      // On success the router redirects; nothing else to do here.
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(
        () => _error = e.message.isNotEmpty ? e.message : l10n.loginFailed,
      );
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

    return Scaffold(
      backgroundColor: BrandColors.card,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: LoginStyles.pagePadding,
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: LoginStyles.maxCardWidth,
              ),
              child: Container(
                padding: LoginStyles.cardPadding,
                decoration: LoginStyles.cardDecoration,
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        l10n.loginTitle,
                        style: LoginStyles.headingStyle,
                        textAlign: TextAlign.center,
                      ),
                      LoginStyles.headingGap,
                      Text(
                        l10n.loginUsernameLabel,
                        style: LoginStyles.labelStyle,
                      ),
                      LoginStyles.labelGap,
                      TextFormField(
                        controller: _usernameController,
                        style: LoginStyles.inputTextStyle,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.username],
                        enabled: !_submitting,
                        decoration: LoginStyles.inputDecoration(),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? l10n.loginFieldRequired
                            : null,
                      ),
                      LoginStyles.fieldGap,
                      Text(
                        l10n.loginPasswordLabel,
                        style: LoginStyles.labelStyle,
                      ),
                      LoginStyles.labelGap,
                      TextFormField(
                        controller: _passwordController,
                        style: LoginStyles.inputTextStyle,
                        obscureText: true,
                        textInputAction: TextInputAction.done,
                        autofillHints: const [AutofillHints.password],
                        enabled: !_submitting,
                        onFieldSubmitted: (_) => _submit(),
                        decoration: LoginStyles.inputDecoration(),
                        validator: (v) => (v == null || v.isEmpty)
                            ? l10n.loginFieldRequired
                            : null,
                      ),
                      if (_error != null) ...[
                        LoginStyles.fieldGap,
                        Container(
                          padding: LoginStyles.errorBoxPadding,
                          decoration: LoginStyles.errorBoxDecoration,
                          child: Text(
                            _error!,
                            style: LoginStyles.errorTextStyle,
                          ),
                        ),
                      ],
                      LoginStyles.fieldGap,
                      SizedBox(
                        height: LoginStyles.submitHeight,
                        child: FilledButton(
                          style: LoginStyles.submitButtonStyle,
                          onPressed: _submitting ? null : _submit,
                          child: _submitting
                              ? const SizedBox(
                                  height: LoginStyles.spinnerSize,
                                  width: LoginStyles.spinnerSize,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: BrandColors.card,
                                  ),
                                )
                              : Text(l10n.loginSubmit),
                        ),
                      ),
                      LoginStyles.headingGap,
                      Align(
                        alignment: Alignment.center,
                        child: Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              '${l10n.noAccountPrompt} ',
                              style: LoginStyles.footerPromptStyle,
                            ),
                            GestureDetector(
                              onTap: _submitting
                                  ? null
                                  : () => context.go('/register'),
                              child: Text(
                                l10n.registerHere,
                                style: LoginStyles.footerLinkStyle,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
