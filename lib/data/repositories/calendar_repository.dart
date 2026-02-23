import '../models/calendar_event_model.dart';
import '../services/api_service.dart';
import '../../core/constants/app_constants.dart';

class CalendarRepository {
  final ApiService _api;
  CalendarRepository({ApiService? api}) : _api = api ?? ApiService();

  Future<List<CalendarEventModel>> listEvents({
    required DateTime start,
    required DateTime end,
  }) async {
    final resp = await _api.get(
      '${AppConstants.calendarEndpoint}/events',
      queryParameters: {
        'start': start.toIso8601String(),
        'end': end.toIso8601String(),
      },
    );
    final items = resp.data as List<dynamic>;
    return items.map((e) => CalendarEventModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<String> getGoogleAuthUrl() async {
    final resp = await _api.get('${AppConstants.googleEndpoint}/auth');
    return (resp.data as Map<String, dynamic>)['auth_url'] as String;
  }

  Future<void> connectGoogle(String code) async {
    await _api.post('${AppConstants.googleEndpoint}/callback', data: {'code': code});
  }

  Future<void> disconnectGoogle() async {
    await _api.delete('${AppConstants.googleEndpoint}/disconnect');
  }
}
