class CallModel {
  final String id;
  final String? taskId;
  final String direction; // inbound | outbound
  final String status;
  final String? phoneNumber;
  final int? durationSeconds;
  final String? recordingUrl;
  final DateTime? startedAt;
  final DateTime createdAt;

  CallModel({
    required this.id,
    this.taskId,
    required this.direction,
    required this.status,
    this.phoneNumber,
    this.durationSeconds,
    this.recordingUrl,
    this.startedAt,
    required this.createdAt,
  });

  factory CallModel.fromJson(Map<String, dynamic> json) => CallModel(
        id: json['id'] as String,
        taskId: json['task_id'] as String?,
        direction: json['direction'] as String? ?? 'outbound',
        status: json['status'] as String? ?? 'completed',
        phoneNumber: json['phone_number'] as String?,
        durationSeconds: json['duration_seconds'] as int?,
        recordingUrl: json['recording_url'] as String?,
        startedAt: json['started_at'] != null ? DateTime.parse(json['started_at'] as String) : null,
        createdAt: DateTime.parse(json['created_at'] as String),
      );

  String get durationDisplay {
    if (durationSeconds == null) return '--';
    final m = durationSeconds! ~/ 60;
    final s = durationSeconds! % 60;
    return '${m}m ${s}s';
  }
}

class TranscriptModel {
  final String id;
  final String callId;
  final String? fullText;
  final String? summary;
  final Map<String, dynamic>? extractedData;
  final Map<String, dynamic>? keyInfo;
  final String? language;

  TranscriptModel({
    required this.id,
    required this.callId,
    this.fullText,
    this.summary,
    this.extractedData,
    this.keyInfo,
    this.language,
  });

  factory TranscriptModel.fromJson(Map<String, dynamic> json) => TranscriptModel(
        id: json['id'] as String,
        callId: json['call_id'] as String,
        fullText: json['full_text'] as String?,
        summary: json['summary'] as String?,
        extractedData: json['extracted_data'] as Map<String, dynamic>?,
        keyInfo: json['key_info'] as Map<String, dynamic>?,
        language: json['language'] as String?,
      );
}
