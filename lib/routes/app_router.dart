/// App Router Configuration Template
///
/// This file configures declarative routing using go_router.
/// Provides centralized route management with deep linking support.
/// Uncomment when ready to implement navigation.

import 'package:flutter/material.dart';
import 'package:nox_ai/core/constants/app_routes.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Feature-based screen imports
// ─────────────────────────────────────────────────────────────────────────────
import 'package:nox_ai/features/splash/screens/splash_screen.dart';
import 'package:nox_ai/features/onboarding/screens/onboarding_how_it_works_screen.dart';
import 'package:nox_ai/features/onboarding/screens/onboarding_meet_agent_screen.dart';
import 'package:nox_ai/features/onboarding/screens/onboarding_stay_in_control_screen.dart';
import 'package:nox_ai/features/auth/screens/create_account_screen.dart';
import 'package:nox_ai/features/auth/screens/email_verification_screen.dart';
import 'package:nox_ai/features/auth/screens/otp_verification_screen.dart';
import 'package:nox_ai/features/home/screens/home_screen.dart';
import 'package:nox_ai/features/tasks/screens/tasks_screen.dart';
import 'package:nox_ai/features/calls/screens/call_logs_screen.dart';
import 'package:nox_ai/features/calls/screens/call_detail_screen.dart';
import 'package:nox_ai/features/memories/screens/memories_screen.dart';
import 'package:nox_ai/features/calendar/screens/calendar_screen.dart';
import 'package:nox_ai/features/notifications/screens/notifications_screen.dart';
import 'package:nox_ai/features/profile/screens/profile_settings_screen.dart';

/// Route generator for MaterialApp.onGenerateRoute
///
/// This is the current routing implementation using Navigator 1.0.
/// Works fine for the demo but consider go_router for production.
Route<dynamic>? onGenerateRoute(RouteSettings settings) {
  switch (settings.name) {
    case AppRoutes.splash:
      return MaterialPageRoute(builder: (_) => const SplashScreen());
    case AppRoutes.onboardingHowItWorks:
      return MaterialPageRoute(
        builder: (_) => const OnboardingHowItWorksScreen(),
      );
    case AppRoutes.onboardingMeetAgent:
      return MaterialPageRoute(
        builder: (_) => const OnboardingMeetAgentScreen(),
      );
    case AppRoutes.onboardingStayInControl:
      return MaterialPageRoute(
        builder: (_) => const OnboardingStayInControlScreen(),
      );
    case AppRoutes.createAccount:
      return MaterialPageRoute(builder: (_) => const CreateAccountScreen());
    case AppRoutes.emailVerification:
      return MaterialPageRoute(builder: (_) => const EmailVerificationScreen());
    case AppRoutes.otpVerification:
      return MaterialPageRoute(builder: (_) => const OtpVerificationScreen());
    case AppRoutes.home:
      return MaterialPageRoute(builder: (_) => const HomeScreen());
    case AppRoutes.tasks:
      return MaterialPageRoute(builder: (_) => const TasksScreen());
    case AppRoutes.callLogs:
      return MaterialPageRoute(builder: (_) => const CallLogsScreen());
    case AppRoutes.callDetail:
      final callData = settings.arguments as Map<String, dynamic>? ?? {};
      return MaterialPageRoute(
        builder: (_) => CallDetailScreen(callData: callData),
      );
    case AppRoutes.memories:
      return MaterialPageRoute(builder: (_) => const MemoriesScreen());
    case AppRoutes.calendar:
      return MaterialPageRoute(builder: (_) => const CalendarScreen());
    case AppRoutes.notifications:
      return MaterialPageRoute(builder: (_) => const NotificationsScreen());
    case AppRoutes.profileSettings:
      return MaterialPageRoute(builder: (_) => const ProfileSettingsScreen());
    default:
      return MaterialPageRoute(
        builder: (_) => Scaffold(
          body: Center(child: Text('Route not found: ${settings.name}')),
        ),
      );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PRODUCTION: go_router Configuration (uncomment when ready)
// ─────────────────────────────────────────────────────────────────────────────

// import 'package:go_router/go_router.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../providers/auth_provider.dart';
// 
// /// Router provider for dependency injection
// final routerProvider = Provider<GoRouter>((ref) {
//   final authState = ref.watch(authStateProvider);
//   
//   return GoRouter(
//     initialLocation: AppRoutes.splash,
//     debugLogDiagnostics: true,
//     
//     // Redirect logic based on auth state
//     redirect: (context, state) {
//       final isAuthenticated = authState.isAuthenticated;
//       final isOnboarding = state.matchedLocation.startsWith('/onboarding');
//       final isAuth = state.matchedLocation.startsWith('/auth');
//       
//       // If not authenticated and trying to access protected routes
//       if (!isAuthenticated && !isOnboarding && !isAuth && state.matchedLocation != AppRoutes.splash) {
//         return AppRoutes.onboardingHowItWorks;
//       }
//       
//       // If authenticated and on auth/onboarding pages, redirect to home
//       if (isAuthenticated && (isOnboarding || isAuth)) {
//         return AppRoutes.home;
//       }
//       
//       return null; // No redirect
//     },
//     
//     routes: [
//       // Splash
//       GoRoute(
//         path: AppRoutes.splash,
//         builder: (context, state) => const SplashScreen(),
//       ),
//       
//       // Onboarding flow
//       GoRoute(
//         path: AppRoutes.onboardingHowItWorks,
//         builder: (context, state) => const OnboardingHowItWorksScreen(),
//       ),
//       GoRoute(
//         path: AppRoutes.onboardingMeetAgent,
//         builder: (context, state) => const OnboardingMeetAgentScreen(),
//       ),
//       GoRoute(
//         path: AppRoutes.onboardingStayInControl,
//         builder: (context, state) => const OnboardingStayInControlScreen(),
//       ),
//       
//       // Auth flow
//       GoRoute(
//         path: AppRoutes.createAccount,
//         builder: (context, state) => const CreateAccountScreen(),
//       ),
//       GoRoute(
//         path: AppRoutes.emailVerification,
//         builder: (context, state) {
//           final email = state.extra as String?;
//           return EmailVerificationScreen(email: email);
//         },
//       ),
//       GoRoute(
//         path: AppRoutes.otpVerification,
//         builder: (context, state) => const OtpVerificationScreen(),
//       ),
//       
//       // Main app shell with bottom navigation
//       ShellRoute(
//         builder: (context, state, child) => AppShell(child: child),
//         routes: [
//           GoRoute(
//             path: AppRoutes.home,
//             pageBuilder: (context, state) => NoTransitionPage(
//               child: const HomeScreen(),
//             ),
//           ),
//           GoRoute(
//             path: AppRoutes.tasks,
//             pageBuilder: (context, state) => NoTransitionPage(
//               child: const TasksScreen(),
//             ),
//           ),
//           GoRoute(
//             path: AppRoutes.callLogs,
//             pageBuilder: (context, state) => NoTransitionPage(
//               child: const CallLogsScreen(),
//             ),
//             routes: [
//               GoRoute(
//                 path: ':id',
//                 builder: (context, state) {
//                   final callId = state.pathParameters['id']!;
//                   return CallDetailScreen(callId: callId);
//                 },
//               ),
//             ],
//           ),
//           GoRoute(
//             path: AppRoutes.calendar,
//             pageBuilder: (context, state) => NoTransitionPage(
//               child: const CalendarScreen(),
//             ),
//           ),
//           GoRoute(
//             path: AppRoutes.profileSettings,
//             pageBuilder: (context, state) => NoTransitionPage(
//               child: const ProfileSettingsScreen(),
//             ),
//           ),
//         ],
//       ),
//       
//       // Standalone screens
//       GoRoute(
//         path: AppRoutes.memories,
//         builder: (context, state) => const MemoriesScreen(),
//       ),
//       GoRoute(
//         path: AppRoutes.notifications,
//         builder: (context, state) => const NotificationsScreen(),
//       ),
//     ],
//     
//     // Error handling
//     errorBuilder: (context, state) => Scaffold(
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const Icon(Icons.error_outline, size: 64, color: Colors.red),
//             const SizedBox(height: 16),
//             Text('Page not found: ${state.matchedLocation}'),
//             const SizedBox(height: 16),
//             ElevatedButton(
//               onPressed: () => context.go(AppRoutes.home),
//               child: const Text('Go Home'),
//             ),
//           ],
//         ),
//       ),
//     ),
//   );
// });
// 
// /// App shell for persistent bottom navigation
// class AppShell extends StatelessWidget {
//   final Widget child;
//   
//   const AppShell({super.key, required this.child});
//   
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: child,
//       // Bottom nav is handled in each screen for now
//       // Can be centralized here for production
//     );
//   }
// }
