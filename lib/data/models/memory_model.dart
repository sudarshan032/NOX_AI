class MemoryModel {
  final String id;
  final String category;
  final String key;
  final String value;
  final String source;
  final DateTime createdAt;

  MemoryModel({
    required this.id,
    required this.category,
    required this.key,
    required this.value,
    required this.source,
    required this.createdAt,
  });

  factory MemoryModel.fromJson(Map<String, dynamic> json) => MemoryModel(
        id: json['id'] as String,
        category: json['category'] as String? ?? 'general',
        key: json['key'] as String,
        value: json['value'] as String,
        source: json['source'] as String? ?? 'conversation',
        createdAt: DateTime.parse(json['created_at'] as String),
      );
}
