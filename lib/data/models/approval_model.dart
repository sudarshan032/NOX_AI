class ApprovalModel {
  final String id;
  final String taskId;
  final List<dynamic> options;
  final String? action;
  final DateTime expiresAt;
  final DateTime createdAt;

  ApprovalModel({
    required this.id,
    required this.taskId,
    required this.options,
    this.action,
    required this.expiresAt,
    required this.createdAt,
  });

  factory ApprovalModel.fromJson(Map<String, dynamic> json) => ApprovalModel(
        id: json['id'] as String,
        taskId: json['task_id'] as String,
        options: json['options'] as List<dynamic>? ?? [],
        action: json['action'] as String?,
        expiresAt: DateTime.parse(json['expires_at'] as String),
        createdAt: DateTime.parse(json['created_at'] as String),
      );

  bool get isPending => action == null;
  bool get isExpired => DateTime.now().isAfter(expiresAt);
}
