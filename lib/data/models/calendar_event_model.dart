class CalendarEventModel {
  final String id;
  final String? taskId;
  final String title;
  final String? description;
  final String? location;
  final DateTime startTime;
  final DateTime endTime;
  final String status;

  CalendarEventModel({
    required this.id,
    this.taskId,
    required this.title,
    this.description,
    this.location,
    required this.startTime,
    required this.endTime,
    required this.status,
  });

  factory CalendarEventModel.fromJson(Map<String, dynamic> json) => CalendarEventModel(
        id: json['id'] as String,
        taskId: json['task_id'] as String?,
        title: json['title'] as String,
        description: json['description'] as String?,
        location: json['location'] as String?,
        startTime: DateTime.parse(json['start_time'] as String),
        endTime: DateTime.parse(json['end_time'] as String),
        status: json['status'] as String? ?? 'confirmed',
      );
}
