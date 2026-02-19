import 'package:flutter/material.dart';

import 'package:nox_ai/app.dart';

// ─────────────────────────────────────────────────────────────────────────────
// PRODUCTION IMPORTS (uncomment when ready)
// ─────────────────────────────────────────────────────────────────────────────
// import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  // ─────────────────────────────────────────────────────────────────────────────
  // PRODUCTION: Initialize services before runApp (uncomment when ready)
  // ─────────────────────────────────────────────────────────────────────────────
  // WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp(); // If using Firebase
  // await Hive.initFlutter();       // If using Hive

  runApp(const App());

  // ─────────────────────────────────────────────────────────────────────────────
  // PRODUCTION: Wrap with ProviderScope for Riverpod (uncomment when ready)
  // ─────────────────────────────────────────────────────────────────────────────
  // runApp(
  //   const ProviderScope(
  //     child: App(),
  //   ),
  // );
}
