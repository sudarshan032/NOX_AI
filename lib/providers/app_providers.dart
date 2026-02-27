import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/user_model.dart';
import '../data/models/task_model.dart';
import '../data/models/call_model.dart';
import '../data/models/memory_model.dart';
import '../data/models/calendar_event_model.dart';
import '../data/models/approval_model.dart';
import '../data/repositories/auth_repository.dart';
import '../data/repositories/user_repository.dart';
import '../data/repositories/tasks_repository.dart';
import '../data/repositories/calls_repository.dart';
import '../data/repositories/memory_repository.dart';
import '../data/repositories/calendar_repository.dart';
import '../data/repositories/approvals_repository.dart';
import '../data/repositories/daily_brief_repository.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Repository Providers
// ─────────────────────────────────────────────────────────────────────────────

final authRepositoryProvider = Provider<AuthRepository>((ref) => AuthRepository());
final userRepositoryProvider = Provider<UserRepository>((ref) => UserRepository());
final tasksRepositoryProvider = Provider<TasksRepository>((ref) => TasksRepository());
final callsRepositoryProvider = Provider<CallsRepository>((ref) => CallsRepository());
final memoryRepositoryProvider = Provider<MemoryRepository>((ref) => MemoryRepository());
final calendarRepositoryProvider = Provider<CalendarRepository>((ref) => CalendarRepository());
final approvalsRepositoryProvider = Provider<ApprovalsRepository>((ref) => ApprovalsRepository());
final dailyBriefRepositoryProvider = Provider<DailyBriefRepository>((ref) => DailyBriefRepository());

// ─────────────────────────────────────────────────────────────────────────────
// Auth State
// ─────────────────────────────────────────────────────────────────────────────

class AuthState {
  final UserModel? user;
  final bool isLoading;
  final bool initialized;
  final String? error;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.initialized = false,
    this.error,
  });

  bool get isAuthenticated => user != null;

  AuthState copyWith({
    UserModel? user,
    bool? isLoading,
    bool? initialized,
    String? error,
    bool clearUser = false,
  }) =>
      AuthState(
        user: clearUser ? null : user ?? this.user,
        isLoading: isLoading ?? this.isLoading,
        initialized: initialized ?? this.initialized,
        error: error,
      );
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _auth;
  final UserRepository _user;

  AuthNotifier(this._auth, this._user) : super(const AuthState()) {
    _initialize();
  }

  Future<void> _initialize() async {
    final isAuth = await _auth.isAuthenticated();
    debugPrint('[AUTH] _initialize: isAuth=$isAuth');
    if (isAuth) {
      try {
        final user = await _user.getMe();
        debugPrint('[AUTH] _initialize: getMe OK, user=${user.id}');
        state = AuthState(user: user, initialized: true);
        return;
      } catch (e) {
        debugPrint('[AUTH] _initialize: getMe FAILED: $e - signing out');
        await _auth.signOut();
      }
    }
    state = const AuthState(initialized: true);
  }

  Future<String?> sendOtp(String phone) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final otp = await _auth.sendOtp(phone);
      state = state.copyWith(isLoading: false);
      return otp;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> verifyOtp(String phone, String otp) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      debugPrint('[AUTH] verifyOtp: calling _auth.verifyOtp...');
      await _auth.verifyOtp(phone, otp);     // saves tokens
      debugPrint('[AUTH] verifyOtp: tokens saved, calling getMe...');
      final user = await _user.getMe();      // fetch profile using saved token
      debugPrint('[AUTH] verifyOtp: getMe OK, user=${user.id}, setting state');
      state = AuthState(user: user, initialized: true);
    } catch (e) {
      debugPrint('[AUTH] verifyOtp FAILED: $e');
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> signInWithGoogle() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      debugPrint('[AUTH] signInWithGoogle: starting...');
      await _auth.signInWithGoogle();
      debugPrint('[AUTH] signInWithGoogle: tokens saved, calling getMe...');
      final user = await _user.getMe();
      debugPrint('[AUTH] signInWithGoogle: getMe OK, user=${user.id}');
      state = AuthState(user: user, initialized: true);
    } catch (e) {
      debugPrint('[AUTH] signInWithGoogle FAILED: $e');
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    state = const AuthState(initialized: true);
  }

  void clearError() => state = state.copyWith(error: null);
}

final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    ref.watch(authRepositoryProvider),
    ref.watch(userRepositoryProvider),
  );
});

// ─────────────────────────────────────────────────────────────────────────────
// User Provider (current user profile)
// ─────────────────────────────────────────────────────────────────────────────

final currentUserProvider = FutureProvider<UserModel>((ref) async {
  return ref.watch(userRepositoryProvider).getMe();
});

// ─────────────────────────────────────────────────────────────────────────────
// Tasks
// ─────────────────────────────────────────────────────────────────────────────

final tasksProvider = FutureProvider.family<List<TaskModel>, String?>((ref, status) async {
  return ref.watch(tasksRepositoryProvider).listTasks(status: status);
});

// ─────────────────────────────────────────────────────────────────────────────
// Calls
// ─────────────────────────────────────────────────────────────────────────────

final callsProvider = FutureProvider.family<List<CallModel>, String?>((ref, direction) async {
  return ref.watch(callsRepositoryProvider).listCalls(direction: direction);
});

final transcriptProvider = FutureProvider.family<TranscriptModel?, String>((ref, callId) async {
  return ref.watch(callsRepositoryProvider).getTranscript(callId);
});

// ─────────────────────────────────────────────────────────────────────────────
// Calendar
// ─────────────────────────────────────────────────────────────────────────────

class DateRange {
  final DateTime start;
  final DateTime end;
  DateRange(this.start, this.end);
}

final calendarEventsProvider = FutureProvider.family<List<CalendarEventModel>, DateRange>(
  (ref, range) async {
    return ref.watch(calendarRepositoryProvider).listEvents(start: range.start, end: range.end);
  },
);

// ─────────────────────────────────────────────────────────────────────────────
// Memories
// ─────────────────────────────────────────────────────────────────────────────

final memoriesProvider = FutureProvider<List<MemoryModel>>((ref) async {
  return ref.watch(memoryRepositoryProvider).listMemories();
});

// ─────────────────────────────────────────────────────────────────────────────
// Approvals
// ─────────────────────────────────────────────────────────────────────────────

final approvalsProvider = FutureProvider<List<ApprovalModel>>((ref) async {
  return ref.watch(approvalsRepositoryProvider).listApprovals();
});

// ─────────────────────────────────────────────────────────────────────────────
// Daily Brief
// ─────────────────────────────────────────────────────────────────────────────

final dailyBriefProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  return ref.watch(dailyBriefRepositoryProvider).getTodayBrief();
});
