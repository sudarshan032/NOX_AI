import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/constants/app_constants.dart';

class SecureStorageService {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock_this_device),
  );

  static Future<void> saveAccessToken(String token) =>
      _storage.write(key: AppConstants.accessTokenKey, value: token);

  static Future<String?> getAccessToken() =>
      _storage.read(key: AppConstants.accessTokenKey);

  static Future<void> saveRefreshToken(String token) =>
      _storage.write(key: AppConstants.refreshTokenKey, value: token);

  static Future<String?> getRefreshToken() =>
      _storage.read(key: AppConstants.refreshTokenKey);

  static Future<void> saveUserId(String id) =>
      _storage.write(key: AppConstants.userIdKey, value: id);

  static Future<String?> getUserId() =>
      _storage.read(key: AppConstants.userIdKey);

  static Future<void> savePhone(String phone) =>
      _storage.write(key: AppConstants.phoneKey, value: phone);

  static Future<String?> getPhone() =>
      _storage.read(key: AppConstants.phoneKey);

  static Future<void> clearAll() => _storage.deleteAll();

  static Future<bool> hasValidAuth() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }
}
