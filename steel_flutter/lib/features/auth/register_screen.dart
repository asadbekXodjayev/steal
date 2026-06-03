import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:steel/l10n/app_localizations.dart';

import '../../core/legal_links.dart';
import '../../core/router.dart';
import '../../shared/ops_theme.dart';
import '../../shared/widgets/widgets.dart';
import 'auth_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _passwordConfirmCtrl = TextEditingController();

  bool _consentGiven = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _passwordConfirmCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    final t = ref.watch(tProvider);

    return Scaffold(
      backgroundColor: SteelOpsColors.background,
      appBar: SteelAppBar(
        title: t('auth.CREATE_ACCOUNT_TITLE'),
        leading: IconButton(
          onPressed: auth.isBusy ? null : () => context.goNamed(SteelRoutes.login),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: SafeArea(
        child: SteelScreenBody(
          scrollable: true,
          child: AutofillGroup(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SteelTextField(
                  controller: _emailCtrl,
                  label: t('auth.EMAIL'),
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.email],
                  enabled: !auth.isBusy,
                ),
                const SizedBox(height: 12),
                SteelTextField(
                  controller: _passwordCtrl,
                  label: t('auth.PASSWORD'),
                  obscureText: true,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.newPassword],
                  enabled: !auth.isBusy,
                ),
                const SizedBox(height: 12),
                SteelTextField(
                  controller: _passwordConfirmCtrl,
                  label: t('auth.CONFIRM_PASSWORD'),
                  obscureText: true,
                  textInputAction: TextInputAction.done,
                  autofillHints: const [AutofillHints.newPassword],
                  enabled: !auth.isBusy,
                  onSubmitted: (_) => _onRegister(),
                ),
                const SizedBox(height: 16),
                if (auth.errorMessage != null) ...[
                  SteelErrorBanner(message: auth.errorMessage!),
                  const SizedBox(height: 12),
                ],
                _consentRow(t),
                const SizedBox(height: 16),
                SteelPrimaryButton(
                  label: t('auth.CREATE_ACCOUNT'),
                  isLoading: auth.isBusy,
                  onPressed: (_consentGiven && !auth.isBusy) ? _onRegister : null,
                ),
                const SizedBox(height: 10),
                SteelLinkButton(
                  label: t('auth.HAVE_ACCOUNT'),
                  enabled: !auth.isBusy,
                  onPressed: () => context.goNamed(SteelRoutes.login),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Required consent: a tappable line with linked Terms / Privacy plus a
  // checkbox the user must tick before "Create account" is enabled.
  Widget _consentRow(String Function(String) t) {
    final linkStyle = steelMonoStyle(
      fontSize: 11,
      color: SteelOpsColors.orange,
      letterSpacing: 0.5,
    ).copyWith(decoration: TextDecoration.underline);
    final baseStyle = steelMonoStyle(
      fontSize: 11,
      color: SteelOpsColors.muted,
      letterSpacing: 0.5,
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 24,
          height: 24,
          child: Checkbox(
            value: _consentGiven,
            onChanged: (v) => setState(() => _consentGiven = v ?? false),
            activeColor: SteelOpsColors.orange,
            checkColor: Colors.white,
            side: BorderSide(color: SteelOpsColors.borderStrong, width: 1.5),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.compact,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _consentGiven = !_consentGiven),
            child: Text.rich(
              TextSpan(
                style: baseStyle,
                children: [
                  TextSpan(text: t('legal.CONSENT_PREFIX')),
                  TextSpan(
                    text: t('legal.CONSENT_TERMS'),
                    style: linkStyle,
                    recognizer: TapGestureRecognizer()
                      ..onTap = () => _openUrl(LegalLinks.termsOfUseUrl, t),
                  ),
                  TextSpan(text: t('legal.CONSENT_AND')),
                  TextSpan(
                    text: t('legal.CONSENT_PRIVACY'),
                    style: linkStyle,
                    recognizer: TapGestureRecognizer()
                      ..onTap = () => _openUrl(LegalLinks.privacyPolicyUrl, t),
                  ),
                  TextSpan(text: t('legal.CONSENT_SUFFIX')),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _openUrl(String url, String Function(String) t) async {
    final ok = await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    );
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: SteelOpsColors.blood,
          content: Text(
            t('legal.OPEN_LINK_FAILED'),
            style: steelMonoStyle(fontSize: 11, color: Colors.white),
          ),
        ),
      );
    }
  }

  void _onRegister() {
    if (!_consentGiven) return;
    ref.read(authProvider.notifier).register(
          email: _emailCtrl.text.trim(),
          password: _passwordCtrl.text,
          passwordConfirm: _passwordConfirmCtrl.text,
        );
  }
}
