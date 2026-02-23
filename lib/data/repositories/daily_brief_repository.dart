import '../services/api_service.dart';
import '../../core/constants/app_constants.dart';

class DailyBriefRepository {
  final ApiService _api;
  DailyBriefRepository({ApiService? api}) : _api = api ?? ApiService();

  Future<Map<String, dynamic>> getTodayBrief() async {
    final resp = await _api.get('${AppConstants.dailyBriefEndpoint}/today');
    return resp.data as Map<String, dynamic>;
  }
}
