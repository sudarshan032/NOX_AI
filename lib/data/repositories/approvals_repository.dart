import '../models/approval_model.dart';
import '../services/api_service.dart';
import '../../core/constants/app_constants.dart';

class ApprovalsRepository {
  final ApiService _api;
  ApprovalsRepository({ApiService? api}) : _api = api ?? ApiService();

  Future<List<ApprovalModel>> listApprovals() async {
    final resp = await _api.get(AppConstants.approvalsEndpoint);
    final items = resp.data as List<dynamic>;
    return items.map((e) => ApprovalModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> approve(String approvalId, {dynamic selectedOption}) async {
    await _api.post(
      '${AppConstants.approvalsEndpoint}/$approvalId/approve',
      data: selectedOption != null ? {'selected_option': selectedOption} : null,
    );
  }

  Future<void> reject(String approvalId) async {
    await _api.post('${AppConstants.approvalsEndpoint}/$approvalId/reject');
  }
}
