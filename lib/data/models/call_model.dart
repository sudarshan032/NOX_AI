/// Call Model Template
/// 
/// This file contains models for call logs and call details.
/// Uncomment when implementing call history feature.

// ─────────────────────────────────────────────────────────────────────────────
// PRODUCTION: Call Models (uncomment when ready)
// ─────────────────────────────────────────────────────────────────────────────

// import 'package:equatable/equatable.dart';
// import 'package:json_annotation/json_annotation.dart';
// 
// part 'call_model.g.dart';
// 
// enum CallType { incoming, outgoing, missed }
// 
// enum CallStatus { completed, missed, declined, busy }
// 
// @JsonSerializable()
// class CallModel extends Equatable {
//   final String id;
//   final String contactName;
//   final String? contactPhone;
//   final String? contactAvatarUrl;
//   final CallType type;
//   final CallStatus status;
//   final Duration duration;
//   final DateTime timestamp;
//   final String? summary;
//   final List<TranscriptEntry>? transcript;
//   final List<String>? actionItems;
//   final bool isFlagged;
// 
//   const CallModel({
//     required this.id,
//     required this.contactName,
//     this.contactPhone,
//     this.contactAvatarUrl,
//     required this.type,
//     required this.status,
//     required this.duration,
//     required this.timestamp,
//     this.summary,
//     this.transcript,
//     this.actionItems,
//     this.isFlagged = false,
//   });
// 
//   factory CallModel.fromJson(Map<String, dynamic> json) =>
//       _$CallModelFromJson(json);
// 
//   Map<String, dynamic> toJson() => _$CallModelToJson(this);
// 
//   @override
//   List<Object?> get props => [
//         id,
//         contactName,
//         contactPhone,
//         type,
//         status,
//         duration,
//         timestamp,
//         isFlagged,
//       ];
// }
// 
// @JsonSerializable()
// class TranscriptEntry extends Equatable {
//   final String speaker; // 'user', 'contact', 'agent'
//   final String text;
//   final DateTime timestamp;
// 
//   const TranscriptEntry({
//     required this.speaker,
//     required this.text,
//     required this.timestamp,
//   });
// 
//   factory TranscriptEntry.fromJson(Map<String, dynamic> json) =>
//       _$TranscriptEntryFromJson(json);
// 
//   Map<String, dynamic> toJson() => _$TranscriptEntryToJson(this);
// 
//   @override
//   List<Object?> get props => [speaker, text, timestamp];
// }
