/// Auth Repository Template
/// 
/// This file handles all authentication-related operations.
/// Implements repository pattern for clean separation of concerns.
/// Uncomment when implementing authentication.

// ─────────────────────────────────────────────────────────────────────────────
// PRODUCTION: Auth Repository Implementation (uncomment when ready)
// ─────────────────────────────────────────────────────────────────────────────

// import '../models/user_model.dart';
// import '../services/api_service.dart';
// import '../services/secure_storage_service.dart';
// import '../../core/constants/app_constants.dart';
// 
// /// Authentication result wrapper
// class AuthResult {
//   final bool success;
//   final UserModel? user;
//   final String? errorMessage;
// 
//   AuthResult.success(this.user)
//       : success = true,
//         errorMessage = null;
// 
//   AuthResult.failure(this.errorMessage)
//       : success = false,
//         user = null;
// }
// 
// /// Repository for authentication operations
// class AuthRepository {
//   final ApiService _apiService;
// 
//   AuthRepository({ApiService? apiService})
//       : _apiService = apiService ?? ApiService();
// 
//   /// Sign up with email and password
//   Future<AuthResult> signUp({
//     required String email,
//     required String password,
//     String? name,
//     String? phone,
//   }) async {
//     try {
//       final response = await _apiService.post(
//         '${AppConstants.authEndpoint}/signup',
//         data: {
//           'email': email,
//           'password': password,
//           if (name != null) 'name': name,
//           if (phone != null) 'phone': phone,
//         },
//       );
// 
//       final data = response.data as Map<String, dynamic>;
//       final user = UserModel.fromJson(data['user']);
//       final tokens = AuthTokens.fromJson(data['tokens']);
// 
//       await SecureStorageService.saveAuthToken(tokens.accessToken);
//       await SecureStorageService.saveRefreshToken(tokens.refreshToken);
// 
//       return AuthResult.success(user);
//     } on ApiException catch (e) {
//       return AuthResult.failure(e.message);
//     } catch (e) {
//       return AuthResult.failure('An unexpected error occurred');
//     }
//   }
// 
//   /// Sign in with email and password
//   Future<AuthResult> signIn({
//     required String email,
//     required String password,
//   }) async {
//     try {
//       final response = await _apiService.post(
//         '${AppConstants.authEndpoint}/login',
//         data: {
//           'email': email,
//           'password': password,
//         },
//       );
// 
//       final data = response.data as Map<String, dynamic>;
//       final user = UserModel.fromJson(data['user']);
//       final tokens = AuthTokens.fromJson(data['tokens']);
// 
//       await SecureStorageService.saveAuthToken(tokens.accessToken);
//       await SecureStorageService.saveRefreshToken(tokens.refreshToken);
// 
//       return AuthResult.success(user);
//     } on ApiException catch (e) {
//       return AuthResult.failure(e.message);
//     } catch (e) {
//       return AuthResult.failure('An unexpected error occurred');
//     }
//   }
// 
//   /// Sign out
//   Future<void> signOut() async {
//     try {
//       await _apiService.post('${AppConstants.authEndpoint}/logout');
//     } finally {
//       await SecureStorageService.clearAuthData();
//     }
//   }
// 
//   /// Request email verification
//   Future<bool> requestEmailVerification(String email) async {
//     try {
//       await _apiService.post(
//         '${AppConstants.authEndpoint}/verify-email/request',
//         data: {'email': email},
//       );
//       return true;
//     } catch (e) {
//       return false;
//     }
//   }
// 
//   /// Verify OTP code
//   Future<AuthResult> verifyOtp({
//     required String email,
//     required String code,
//   }) async {
//     try {
//       final response = await _apiService.post(
//         '${AppConstants.authEndpoint}/verify-otp',
//         data: {
//           'email': email,
//           'code': code,
//         },
//       );
// 
//       final data = response.data as Map<String, dynamic>;
//       final user = UserModel.fromJson(data['user']);
// 
//       return AuthResult.success(user);
//     } on ApiException catch (e) {
//       return AuthResult.failure(e.message);
//     } catch (e) {
//       return AuthResult.failure('Invalid verification code');
//     }
//   }
// 
//   /// Check if user is authenticated
//   Future<bool> isAuthenticated() async {
//     return await SecureStorageService.hasValidAuth();
//   }
// 
//   /// Get current user profile
//   Future<UserModel?> getCurrentUser() async {
//     try {
//       final response = await _apiService.get('${AppConstants.usersEndpoint}/me');
//       return UserModel.fromJson(response.data);
//     } catch (e) {
//       return null;
//     }
//   }
// }
