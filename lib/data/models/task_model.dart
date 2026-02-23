class TaskModel {
  final String id;
  final String? serviceType;
  final String? businessName;
  final String? phoneNumber;
  final String description;
  final String status;
  final String? preferredDate;
  final String? preferredTime;
  final String? location;
  final DateTime createdAt;

  TaskModel({
    required this.id,
    this.serviceType,
    this.businessName,
    this.phoneNumber,
    required this.description,
    required this.status,
    this.preferredDate,
    this.preferredTime,
    this.location,
    required this.createdAt,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) => TaskModel(
        id: json['id'] as String,
        serviceType: json['service_type'] as String?,
        businessName: json['business_name'] as String?,
        phoneNumber: json['phone_number'] as String?,
        description: json['description'] as String? ?? '',
        status: json['status'] as String? ?? 'created',
        preferredDate: json['preferred_date'] as String?,
        preferredTime: json['preferred_time'] as String?,
        location: json['location'] as String?,
        createdAt: DateTime.parse(json['created_at'] as String),
      );

  String get displayTitle => businessName ?? serviceType ?? 'Task';
  bool get isActive => ['created', 'calling', 'awaiting_approval'].contains(status);
  bool get isCompleted => status == 'completed';
}
