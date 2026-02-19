/// Task Model Template
/// 
/// This file contains models for tasks and to-do items.
/// Uncomment when implementing tasks feature.

// ─────────────────────────────────────────────────────────────────────────────
// PRODUCTION: Task Models (uncomment when ready)
// ─────────────────────────────────────────────────────────────────────────────

// import 'package:equatable/equatable.dart';
// import 'package:json_annotation/json_annotation.dart';
// 
// part 'task_model.g.dart';
// 
// enum TaskPriority { low, medium, high, urgent }
// 
// enum TaskStatus { todo, inProgress, completed, cancelled }
// 
// @JsonSerializable()
// class TaskModel extends Equatable {
//   final String id;
//   final String title;
//   final String? description;
//   final TaskPriority priority;
//   final TaskStatus status;
//   final DateTime createdAt;
//   final DateTime? dueDate;
//   final DateTime? completedAt;
//   final String? assignedTo;
//   final String? relatedCallId;
//   final List<String>? tags;
// 
//   const TaskModel({
//     required this.id,
//     required this.title,
//     this.description,
//     required this.priority,
//     required this.status,
//     required this.createdAt,
//     this.dueDate,
//     this.completedAt,
//     this.assignedTo,
//     this.relatedCallId,
//     this.tags,
//   });
// 
//   factory TaskModel.fromJson(Map<String, dynamic> json) =>
//       _$TaskModelFromJson(json);
// 
//   Map<String, dynamic> toJson() => _$TaskModelToJson(this);
// 
//   bool get isOverdue =>
//       dueDate != null &&
//       DateTime.now().isAfter(dueDate!) &&
//       status != TaskStatus.completed;
// 
//   TaskModel copyWith({
//     String? id,
//     String? title,
//     String? description,
//     TaskPriority? priority,
//     TaskStatus? status,
//     DateTime? createdAt,
//     DateTime? dueDate,
//     DateTime? completedAt,
//     String? assignedTo,
//     String? relatedCallId,
//     List<String>? tags,
//   }) {
//     return TaskModel(
//       id: id ?? this.id,
//       title: title ?? this.title,
//       description: description ?? this.description,
//       priority: priority ?? this.priority,
//       status: status ?? this.status,
//       createdAt: createdAt ?? this.createdAt,
//       dueDate: dueDate ?? this.dueDate,
//       completedAt: completedAt ?? this.completedAt,
//       assignedTo: assignedTo ?? this.assignedTo,
//       relatedCallId: relatedCallId ?? this.relatedCallId,
//       tags: tags ?? this.tags,
//     );
//   }
// 
//   @override
//   List<Object?> get props => [
//         id,
//         title,
//         priority,
//         status,
//         createdAt,
//         dueDate,
//         completedAt,
//       ];
// }
