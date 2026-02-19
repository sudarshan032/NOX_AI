/// User Model Template
/// 
/// This file contains the User model and related DTOs (Data Transfer Objects).
/// Uncomment when implementing user authentication.

// ─────────────────────────────────────────────────────────────────────────────
// PRODUCTION: User Model (uncomment when ready)
// ─────────────────────────────────────────────────────────────────────────────

// import 'package:equatable/equatable.dart';
// import 'package:json_annotation/json_annotation.dart';
// 
// part 'user_model.g.dart';
// 
// @JsonSerializable()
// class UserModel extends Equatable {
//   final String id;
//   final String email;
//   final String? name;
//   final String? phone;
//   final String? avatarUrl;
//   final bool isEmailVerified;
//   final bool isPhoneVerified;
//   final DateTime createdAt;
//   final DateTime? updatedAt;
// 
//   const UserModel({
//     required this.id,
//     required this.email,
//     this.name,
//     this.phone,
//     this.avatarUrl,
//     required this.isEmailVerified,
//     required this.isPhoneVerified,
//     required this.createdAt,
//     this.updatedAt,
//   });
// 
//   factory UserModel.fromJson(Map<String, dynamic> json) =>
//       _$UserModelFromJson(json);
// 
//   Map<String, dynamic> toJson() => _$UserModelToJson(this);
// 
//   UserModel copyWith({
//     String? id,
//     String? email,
//     String? name,
//     String? phone,
//     String? avatarUrl,
//     bool? isEmailVerified,
//     bool? isPhoneVerified,
//     DateTime? createdAt,
//     DateTime? updatedAt,
//   }) {
//     return UserModel(
//       id: id ?? this.id,
//       email: email ?? this.email,
//       name: name ?? this.name,
//       phone: phone ?? this.phone,
//       avatarUrl: avatarUrl ?? this.avatarUrl,
//       isEmailVerified: isEmailVerified ?? this.isEmailVerified,
//       isPhoneVerified: isPhoneVerified ?? this.isPhoneVerified,
//       createdAt: createdAt ?? this.createdAt,
//       updatedAt: updatedAt ?? this.updatedAt,
//     );
//   }
// 
//   @override
//   List<Object?> get props => [
//         id,
//         email,
//         name,
//         phone,
//         avatarUrl,
//         isEmailVerified,
//         isPhoneVerified,
//         createdAt,
//         updatedAt,
//       ];
// }
// 
// /// Authentication tokens
// @JsonSerializable()
// class AuthTokens extends Equatable {
//   final String accessToken;
//   final String refreshToken;
//   final DateTime expiresAt;
// 
//   const AuthTokens({
//     required this.accessToken,
//     required this.refreshToken,
//     required this.expiresAt,
//   });
// 
//   factory AuthTokens.fromJson(Map<String, dynamic> json) =>
//       _$AuthTokensFromJson(json);
// 
//   Map<String, dynamic> toJson() => _$AuthTokensToJson(this);
// 
//   bool get isExpired => DateTime.now().isAfter(expiresAt);
// 
//   @override
//   List<Object?> get props => [accessToken, refreshToken, expiresAt];
// }
