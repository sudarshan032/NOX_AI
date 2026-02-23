import '../models/task_model.dart';
import '../services/api_service.dart';
import '../../core/constants/app_constants.dart';

class TasksRepository {
  final ApiService _api;
  TasksRepository({ApiService? api}) : _api = api ?? ApiService();

  Future<List<TaskModel>> listTasks({String? status}) async {
    final resp = await _api.get(
      AppConstants.tasksEndpoint,
      queryParameters: {if (status != null) 'status': status},
    );
    final items = resp.data as List<dynamic>;
    return items.map((e) => TaskModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<TaskModel> createTask(Map<String, dynamic> data) async {
    final resp = await _api.post(AppConstants.tasksEndpoint, data: data);
    return TaskModel.fromJson(resp.data as Map<String, dynamic>);
  }

  Future<TaskModel> getTask(String taskId) async {
    final resp = await _api.get('${AppConstants.tasksEndpoint}/$taskId');
    return TaskModel.fromJson(resp.data as Map<String, dynamic>);
  }

  /// Execute (trigger call for) a task
  Future<Map<String, dynamic>> executeTask(String taskId) async {
    final resp = await _api.post('${AppConstants.tasksEndpoint}/$taskId/execute');
    return resp.data as Map<String, dynamic>;
  }

  Future<void> deleteTask(String taskId) async {
    await _api.delete('${AppConstants.tasksEndpoint}/$taskId');
  }

  Future<TaskModel> updateTask(String taskId, Map<String, dynamic> data) async {
    final resp = await _api.put('${AppConstants.tasksEndpoint}/$taskId', data: data);
    return TaskModel.fromJson(resp.data as Map<String, dynamic>);
  }
}
