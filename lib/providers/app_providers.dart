/// App Providers Configuration Template
/// 
/// This file configures Riverpod providers for state management.
/// Provides dependency injection and reactive state updates.
/// Uncomment when ready to implement state management.

// ─────────────────────────────────────────────────────────────────────────────
// Current: Simple ChangeNotifier (working)
// ─────────────────────────────────────────────────────────────────────────────

// The app currently uses ChangeNotifier for theme management.
// See: lib/core/theme/app_theme.dart -> ThemeProvider

// ─────────────────────────────────────────────────────────────────────────────
// PRODUCTION: Riverpod Providers (uncomment when ready)
// ─────────────────────────────────────────────────────────────────────────────

// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../data/repositories/auth_repository.dart';
// import '../data/models/user_model.dart';
// 
// // ─────────────────────────────────────────────────────────────────────────────
// // Repository Providers
// // ─────────────────────────────────────────────────────────────────────────────
// 
// /// Auth repository provider
// final authRepositoryProvider = Provider<AuthRepository>((ref) {
//   return AuthRepository();
// });
// 
// // ─────────────────────────────────────────────────────────────────────────────
// // Auth State
// // ─────────────────────────────────────────────────────────────────────────────
// 
// /// Authentication state
// class AuthState {
//   final UserModel? user;
//   final bool isLoading;
//   final String? error;
// 
//   const AuthState({
//     this.user,
//     this.isLoading = false,
//     this.error,
//   });
// 
//   bool get isAuthenticated => user != null;
// 
//   AuthState copyWith({
//     UserModel? user,
//     bool? isLoading,
//     String? error,
//   }) {
//     return AuthState(
//       user: user ?? this.user,
//       isLoading: isLoading ?? this.isLoading,
//       error: error,
//     );
//   }
// }
// 
// /// Auth state notifier
// class AuthNotifier extends StateNotifier<AuthState> {
//   final AuthRepository _authRepository;
// 
//   AuthNotifier(this._authRepository) : super(const AuthState());
// 
//   /// Initialize auth state (check for existing session)
//   Future<void> initialize() async {
//     state = state.copyWith(isLoading: true);
//     
//     final isAuthenticated = await _authRepository.isAuthenticated();
//     if (isAuthenticated) {
//       final user = await _authRepository.getCurrentUser();
//       state = AuthState(user: user);
//     } else {
//       state = const AuthState();
//     }
//   }
// 
//   /// Sign up
//   Future<bool> signUp({
//     required String email,
//     required String password,
//     String? name,
//   }) async {
//     state = state.copyWith(isLoading: true, error: null);
//     
//     final result = await _authRepository.signUp(
//       email: email,
//       password: password,
//       name: name,
//     );
//     
//     if (result.success) {
//       state = AuthState(user: result.user);
//       return true;
//     } else {
//       state = state.copyWith(isLoading: false, error: result.errorMessage);
//       return false;
//     }
//   }
// 
//   /// Sign in
//   Future<bool> signIn({
//     required String email,
//     required String password,
//   }) async {
//     state = state.copyWith(isLoading: true, error: null);
//     
//     final result = await _authRepository.signIn(
//       email: email,
//       password: password,
//     );
//     
//     if (result.success) {
//       state = AuthState(user: result.user);
//       return true;
//     } else {
//       state = state.copyWith(isLoading: false, error: result.errorMessage);
//       return false;
//     }
//   }
// 
//   /// Sign out
//   Future<void> signOut() async {
//     await _authRepository.signOut();
//     state = const AuthState();
//   }
// 
//   /// Clear error
//   void clearError() {
//     state = state.copyWith(error: null);
//   }
// }
// 
// /// Auth state provider
// final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
//   final repository = ref.watch(authRepositoryProvider);
//   return AuthNotifier(repository);
// });
// 
// // ─────────────────────────────────────────────────────────────────────────────
// // Theme State
// // ─────────────────────────────────────────────────────────────────────────────
// 
// /// Theme mode provider
// final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
//   return ThemeModeNotifier();
// });
// 
// class ThemeModeNotifier extends StateNotifier<ThemeMode> {
//   ThemeModeNotifier() : super(ThemeMode.dark);
// 
//   void toggleTheme() {
//     state = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
//   }
// 
//   void setTheme(ThemeMode mode) {
//     state = mode;
//   }
// }
// 
// // ─────────────────────────────────────────────────────────────────────────────
// // Feature-specific providers (add as needed)
// // ─────────────────────────────────────────────────────────────────────────────
// 
// // /// Tasks provider
// // final tasksProvider = StateNotifierProvider<TasksNotifier, TasksState>((ref) {
// //   final repository = ref.watch(tasksRepositoryProvider);
// //   return TasksNotifier(repository);
// // });
// // 
// // /// Calls provider
// // final callsProvider = StateNotifierProvider<CallsNotifier, CallsState>((ref) {
// //   final repository = ref.watch(callsRepositoryProvider);
// //   return CallsNotifier(repository);
// // });
// // 
// // /// Calendar provider
// // final calendarProvider = StateNotifierProvider<CalendarNotifier, CalendarState>((ref) {
// //   final repository = ref.watch(calendarRepositoryProvider);
// //   return CalendarNotifier(repository);
// // });
