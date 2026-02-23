import '../models/call_model.dart';
import '../services/api_service.dart';
import '../../core/constants/app_constants.dart';

class CallsRepository {
  final ApiService _api;
  CallsRepository({ApiService? api}) : _api = api ?? ApiService();

  Future<List<CallModel>> listCalls({
    String? direction,
    String? status,
    int limit = 50,
  }) async {
    final resp = await _api.get(
      AppConstants.callsEndpoint,
      queryParameters: {
        if (direction != null) 'direction': direction,
        if (status != null) 'status': status,
        'limit': limit,
      },
    );
    final items = resp.data as List<dynamic>;
    return items.map((e) => CallModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<CallModel> getCall(String callId) async {
    final resp = await _api.get('${AppConstants.callsEndpoint}/$callId');
    return CallModel.fromJson(resp.data as Map<String, dynamic>);
  }

  Future<Map<String, dynamic>> makeOutboundCall({
    required String phoneNumber,
    Map<String, dynamic> context = const {},
    String serviceType = 'general',
  }) async {
    final resp = await _api.post(
      '${AppConstants.callsEndpoint}/outbound',
      data: {
        'phone_number': phoneNumber,
        'context': context,
        'service_type': serviceType,
      },
    );
    return resp.data as Map<String, dynamic>;
  }

  Future<TranscriptModel?> getTranscript(String callId) async {
    try {
      final resp = await _api.get('${AppConstants.callsEndpoint}/$callId/transcript');
      return TranscriptModel.fromJson(resp.data as Map<String, dynamic>);
    } on ApiException catch (e) {
      if (e.statusCode == 404) return null;
      rethrow;
    }
  }
}
