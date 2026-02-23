import '../models/user_model.dart';
import '../services/api_service.dart';
import '../../core/constants/app_constants.dart';

class UserRepository {
  final ApiService _api;
  UserRepository({ApiService? api}) : _api = api ?? ApiService();

  Future<UserModel> getMe() async {
    final resp = await _api.get('${AppConstants.usersEndpoint}/me');
    return UserModel.fromJson(resp.data as Map<String, dynamic>);
  }

  Future<UserModel> updateMe({String? name, String? email}) async {
    final resp = await _api.put(
      '${AppConstants.usersEndpoint}/me',
      data: {
        if (name != null) 'name': name,
        if (email != null) 'email': email,
      },
    );
    return UserModel.fromJson(resp.data as Map<String, dynamic>);
  }

  Future<UserModel> toggleAgent(bool enabled) async {
    final resp = await _api.put(
      '${AppConstants.usersEndpoint}/me/agent-toggle',
      data: {'enabled': enabled},
    );
    return UserModel.fromJson(resp.data as Map<String, dynamic>);
  }
}
