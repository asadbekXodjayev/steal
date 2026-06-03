import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/models.dart';
import '../features/auth/auth_provider.dart';
import '../features/auth/login_screen.dart';
import '../features/auth/register_screen.dart';
import '../features/home/root_gate.dart';
import '../features/library/exercise_detail_screen.dart';
import '../features/programs/quick_session_screen.dart';
import '../features/therapy/session_screen.dart';
import '../features/onboarding/onboarding_screen.dart';

class SteelRoutes {
  static const login = 'login';
  static const register = 'register';
  static const home = 'home';
  static const therapySession = 'therapySession';
  static const quickSession = 'quickSession';

  static const loginPath = '/login';
  static const registerPath = '/register';
  static const homePath = '/';
  static const therapySessionPath = '/workout/session';
  static const quickSessionPath = '/workout/quick';

  static const onboarding = 'onboarding';
  static const onboardingPath = '/onboarding';

  static const exerciseDetail = 'exerciseDetail';
  static const exerciseDetailPath = '/exercises/:id';

  /// Build a concrete path to an exercise detail page.
  static String exerciseDetailPathFor(String id) => '/exercises/$id';
}

final routerProvider = Provider<GoRouter>((ref) {
  final routerNotifier = RouterNotifier(ref);
  ref.onDispose(routerNotifier.dispose);

  return GoRouter(
    initialLocation: SteelRoutes.homePath,
    refreshListenable: routerNotifier,
    redirect: (context, state) {
      final auth = ref.read(authProvider);
      final isAuth = auth.status == AuthStatus.authenticated;
      final isUnknown = auth.status == AuthStatus.unknown;

      final location = state.matchedLocation;
      final atLogin = location == SteelRoutes.loginPath;
      final atRegister = location == SteelRoutes.registerPath;
      final atHome = location == SteelRoutes.homePath;
      final atSession = location == SteelRoutes.therapySessionPath;

      if (isUnknown) return null;

      if (!isAuth) {
        if (atSession) return SteelRoutes.loginPath;
        if (!(atHome || atLogin || atRegister)) return SteelRoutes.homePath;
        return null;
      }

      if (isAuth && (atLogin || atRegister)) return SteelRoutes.homePath;

      return null;
    },
    routes: [
      GoRoute(
        name: SteelRoutes.home,
        path: SteelRoutes.homePath,
        builder: (context, state) => const RootGate(),
      ),
      GoRoute(
        name: SteelRoutes.therapySession,
        path: SteelRoutes.therapySessionPath,
        builder: (context, state) => const SessionScreen(),
      ),
      GoRoute(
        name: SteelRoutes.quickSession,
        path: SteelRoutes.quickSessionPath,
        builder: (context, state) => const QuickSessionScreen(),
      ),
      GoRoute(
        name: SteelRoutes.login,
        path: SteelRoutes.loginPath,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        name: SteelRoutes.register,
        path: SteelRoutes.registerPath,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        name: SteelRoutes.onboarding,
        path: SteelRoutes.onboardingPath,
        builder: (context, state) => OnboardingScreen(
          onComplete: () => context.go(SteelRoutes.homePath),
        ),
      ),
      GoRoute(
        name: SteelRoutes.exerciseDetail,
        path: SteelRoutes.exerciseDetailPath,
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          final extra = state.extra;
          return ExerciseDetailScreen(
            id: id,
            initial: extra is ExerciseCatalogItem ? extra : null,
          );
        },
      ),
    ],
  );
});

class RouterNotifier extends ChangeNotifier {
  RouterNotifier(this.ref) {
    _sub = ref.listen<AuthState>(
      authProvider,
      (previous, next) => notifyListeners(),
    );
  }

  final Ref ref;
  late final ProviderSubscription<AuthState> _sub;

  @override
  void dispose() {
    _sub.close();
    super.dispose();
  }
}
