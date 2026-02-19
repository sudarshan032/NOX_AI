import 'package:flutter/material.dart';

import 'package:nox_ai/core/theme/app_theme.dart';
import 'package:nox_ai/core/theme/theme_provider.dart';
import 'package:nox_ai/features/splash/screens/splash_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
// PRODUCTION IMPORTS (uncomment when ready)
// ─────────────────────────────────────────────────────────────────────────────
// import 'package:nox_ai/routes/app_router.dart';

/// Root application widget
///
/// Configures MaterialApp with theme support and initial routing.
/// In production, replace Navigator 1.0 with GoRouter for declarative routing.
class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ThemeProvider(),
      builder: (context, child) {
        return MaterialApp(
          title: 'Demo App',
          debugShowCheckedModeBanner: false,
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: ThemeProvider().themeMode,
          home: const SplashScreen(),
          // ─────────────────────────────────────────────────────────────────
          // PRODUCTION: Use GoRouter for navigation (uncomment when ready)
          // ─────────────────────────────────────────────────────────────────
          // routerConfig: appRouter,
        );
      },
    );
  }
}
