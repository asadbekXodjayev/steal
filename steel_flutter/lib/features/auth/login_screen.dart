import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router.dart';
import '../../shared/ops_theme.dart';
import '../../shared/widgets/widgets.dart';
import 'auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: SteelOpsColors.background,
      appBar: AppBar(
        backgroundColor: SteelOpsColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: auth.isBusy ? null : () => context.go(SteelRoutes.homePath),
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
                Text(
                  'ACCESS PORTAL',
                  textAlign: TextAlign.center,
                  style: steelMonoStyle(
                    fontSize: 10,
                    color: SteelOpsColors.inkDim,
                    letterSpacing: 2.5,
                  ),
                ),
                const SizedBox(height: 12),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: 'STEEL',
                        style: steelHeadingStyle(
                          fontSize: 36,
                          color: SteelOpsColors.forge,
                        ),
                      ),
                      TextSpan(
                        text: '  |  SIGN IN',
                        style: steelHeadingStyle(fontSize: 28),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'NO EXCUSES. SHOW UP.',
                  textAlign: TextAlign.center,
                  style: steelMonoStyle(fontSize: 12, letterSpacing: 1.2),
                ),
                const SizedBox(height: 28),
                SteelTextField(
                  controller: _emailCtrl,
                  label: 'Email',
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [
                    AutofillHints.username,
                    AutofillHints.email,
                  ],
                  enabled: !auth.isBusy,
                ),
                const SizedBox(height: 12),
                SteelTextField(
                  controller: _passwordCtrl,
                  label: 'Password',
                  obscureText: true,
                  textInputAction: TextInputAction.done,
                  autofillHints: const [AutofillHints.password],
                  enabled: !auth.isBusy,
                  onSubmitted: (_) => _onLogin(),
                ),
                const SizedBox(height: 16),
                if (auth.errorMessage != null) ...[
                  SteelErrorBanner(message: auth.errorMessage!),
                  const SizedBox(height: 12),
                ],
                SteelPrimaryButton(
                  label: 'Sign In',
                  isLoading: auth.isBusy,
                  onPressed: _onLogin,
                ),
                const SizedBox(height: 10),
                SteelLinkButton(
                  label: 'Create account',
                  enabled: !auth.isBusy,
                  onPressed: () => context.goNamed(SteelRoutes.register),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onLogin() {
    ref.read(authProvider.notifier).login(
          email: _emailCtrl.text.trim(),
          password: _passwordCtrl.text,
        );
  }
}
