import '../models/memory_model.dart';
import '../services/api_service.dart';
import '../../core/constants/app_constants.dart';

class MemoryRepository {
  final ApiService _api;
  MemoryRepository({ApiService? api}) : _api = api ?? ApiService();

  Future<List<MemoryModel>> listMemories({String? category}) async {
    final resp = await _api.get(
      AppConstants.memoriesEndpoint,
      queryParameters: {if (category != null) 'category': category},
    );
    final items = resp.data as List<dynamic>;
    return items.map((e) => MemoryModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<MemoryModel> addMemory({
    required String category,
    required String key,
    required String value,
  }) async {
    final resp = await _api.post(
      AppConstants.memoriesEndpoint,
      data: {'category': category, 'key': key, 'value': value},
    );
    return MemoryModel.fromJson(resp.data as Map<String, dynamic>);
  }

  Future<void> deleteMemory(String memoryId) async {
    await _api.delete('${AppConstants.memoriesEndpoint}/$memoryId');
  }

  Future<void> clearAllMemories() async {
    await _api.delete(AppConstants.memoriesEndpoint);
  }

  Future<void> optIn() async {
    await _api.put('${AppConstants.memoriesEndpoint}/opt-in');
  }

  Future<void> optOut() async {
    await _api.put('${AppConstants.memoriesEndpoint}/opt-out');
  }
}
