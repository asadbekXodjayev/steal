import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../../shared/ops_theme.dart';
import '../auth/auth_provider.dart';
import 'operations_dashboard_view.dart';
import 'widgets/ops_bottom_nav.dart';
import '../gear/gear_screen.dart';
import '../programs/programs_screen.dart';
import '../plans/plans_screen.dart';
import '../library/library_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _tabIndex = 0;

  String _operatorName(AuthState auth) {
    final email = auth.email;
    if (email != null && email.contains('@')) {
      return email.split('@').first.toUpperCase();
    }
    final id = auth.userId;
    if (id != null && id.length >= 6) {
      return id.substring(0, 6).toUpperCase();
    }
    return ref.read(tProvider)('profile.OPERATOR');
  }

  String _operatorInitial(AuthState auth) {
    final email = auth.email;
    if (email != null && email.isNotEmpty) {
      return email[0];
    }
    return 'A';
  }

  void _showProfileMenu() {
    final auth = ref.read(authProvider);
    final t = ref.read(tProvider);
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: SteelOpsColors.surface,
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ListTile(
                  title: Text(
                    auth.email ?? auth.userId ?? t('profile.ACCOUNT'),
                    style: const TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    t('profile.OPERATOR'),
                    style: TextStyle(color: SteelOpsColors.muted, fontSize: 12),
                  ),
                ),
                const Divider(color: SteelOpsColors.border),
                ListTile(
                  leading: const Icon(
                    Icons.logout,
                    color: SteelOpsColors.orange,
                  ),
                  title: Text(
                    t('profile.SIGN_OUT'),
                    style: const TextStyle(color: Colors.white),
                  ),
                  onTap: auth.isBusy
                      ? null
                      : () {
                          Navigator.pop(ctx);
                          ref.read(authProvider.notifier).logout();
                        },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);

    final bodies = <Widget>[
      OperationsDashboardView(
        operatorName: _operatorName(auth),
        operatorInitial: _operatorInitial(auth),
        onProfileTap: _showProfileMenu,
      ),
      ProgramsScreen(),
      PlansScreen(),
      LibraryScreen(),
      GearScreen(),
    ];

    return Scaffold(
      backgroundColor: SteelOpsColors.background,
      body: IndexedStack(index: _tabIndex, children: bodies),
      bottomNavigationBar: OpsBottomNav(
        currentIndex: _tabIndex,
        onChanged: (i) => setState(() => _tabIndex = i),
      ),
    );
  }
}
