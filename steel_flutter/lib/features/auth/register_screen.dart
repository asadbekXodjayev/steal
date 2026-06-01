import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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

    return Scaffold(
      backgroundColor: SteelOpsColors.background,
      appBar: SteelAppBar(
        title: 'CREATE ACCOUNT',
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
                  label: 'Email',
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.email],
                  enabled: !auth.isBusy,
                ),
                const SizedBox(height: 12),
                SteelTextField(
                  controller: _passwordCtrl,
                  label: 'Password',
                  obscureText: true,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.newPassword],
                  enabled: !auth.isBusy,
                ),
                const SizedBox(height: 12),
                SteelTextField(
                  controller: _passwordConfirmCtrl,
                  label: 'Confirm password',
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
                SteelPrimaryButton(
                  label: 'Create account',
                  isLoading: auth.isBusy,
                  onPressed: _onRegister,
                ),
                const SizedBox(height: 10),
                SteelLinkButton(
                  label: 'Already have an account? Sign in',
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

  void _onRegister() {
    ref.read(authProvider.notifier).register(
          email: _emailCtrl.text.trim(),
          password: _passwordCtrl.text,
          passwordConfirm: _passwordConfirmCtrl.text,
        );
  }
}
