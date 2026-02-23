import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/app_routes.dart';
import '../providers/app_providers.dart';
import '../features/splash/screens/splash_screen.dart';
import '../features/onboarding/screens/onboarding_how_it_works_screen.dart';
import '../features/onboarding/screens/onboarding_meet_agent_screen.dart';
import '../features/onboarding/screens/onboarding_stay_in_control_screen.dart';
import '../features/auth/screens/create_account_screen.dart';
import '../features/auth/screens/otp_verification_screen.dart';
import '../features/home/screens/home_screen.dart';
import '../features/tasks/screens/tasks_screen.dart';
import '../features/calls/screens/call_logs_screen.dart';
import '../features/calls/screens/call_detail_screen.dart';
import '../features/memories/screens/memories_screen.dart';
import '../features/calendar/screens/calendar_screen.dart';
import '../features/notifications/screens/notifications_screen.dart';
import '../features/profile/screens/profile_settings_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: _AuthChangeNotifier(ref),
    redirect: (context, state) {
      if (!authState.initialized) return null;

      final isAuth = authState.isAuthenticated;
      final loc = state.matchedLocation;
      final isPublic = loc == AppRoutes.splash ||
          loc.startsWith('/onboarding') ||
          loc.startsWith('/auth');

      if (!isAuth && !isPublic) return AppRoutes.createAccount;
      if (isAuth && loc.startsWith('/auth')) return AppRoutes.home;

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (_, __) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboardingHowItWorks,
        builder: (_, __) => const OnboardingHowItWorksScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboardingMeetAgent,
        builder: (_, __) => const OnboardingMeetAgentScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboardingStayInControl,
        builder: (_, __) => const OnboardingStayInControlScreen(),
      ),
      GoRoute(
        path: AppRoutes.createAccount,
        builder: (_, __) => const CreateAccountScreen(),
      ),
      GoRoute(
        path: AppRoutes.otpVerification,
        builder: (_, state) => OtpVerificationScreen(
          phone: state.extra as String? ?? '',
        ),
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (_, __) => const HomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.tasks,
        builder: (_, __) => const TasksScreen(),
      ),
      GoRoute(
        path: AppRoutes.callLogs,
        builder: (_, __) => const CallLogsScreen(),
        routes: [
          GoRoute(
            path: ':id',
            builder: (_, state) => CallDetailScreen(
              callData: {'id': state.pathParameters['id']!},
            ),
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.memories,
        builder: (_, __) => const MemoriesScreen(),
      ),
      GoRoute(
        path: AppRoutes.calendar,
        builder: (_, __) => const CalendarScreen(),
      ),
      GoRoute(
        path: AppRoutes.notifications,
        builder: (_, __) => const NotificationsScreen(),
      ),
      GoRoute(
        path: AppRoutes.profileSettings,
        builder: (_, __) => const ProfileSettingsScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('Page not found: ${state.matchedLocation}')),
    ),
  );
});

/// Bridges Riverpod auth state changes into a Listenable for GoRouter.refreshListenable
class _AuthChangeNotifier extends ChangeNotifier {
  _AuthChangeNotifier(Ref ref) {
    ref.listen(authStateProvider, (_, __) => notifyListeners());
  }
}
