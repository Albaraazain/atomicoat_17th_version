// lib/features/auth/data/models/user_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole {
  user,
  operator,
  admin,
  superAdmin
}

enum UserStatus {
  pending,
  active,
  inactive,
  denied
}

class UserModel {
  final String id;
  final String email;
  final String name;
  final UserRole role;
  final UserStatus status;
  final String machineId;  // Reference to assigned machine
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    required this.status,
    required this.machineId,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'name': name,
    'role': role.toString().split('.').last,
    'status': status.toString().split('.').last,
    'machineId': machineId,
    'createdAt': createdAt.toIso8601String(),
  };

  factory UserModel.fromJson(Map<String, dynamic> json) {
    try {
      return UserModel(
        id: json['id'] as String,
        email: json['email'] as String,
        name: json['name'] as String,
        role: UserRole.values.firstWhere(
          (e) => e.toString().split('.').last == (json['role'] as String? ?? 'user'),
          orElse: () => UserRole.user,
        ),
        status: UserStatus.values.firstWhere(
          (e) => e.toString().split('.').last == (json['status'] as String? ?? 'pending'),
          orElse: () => UserStatus.pending,
        ),
        machineId: json['machineId'] as String,
        createdAt: json['createdAt'] is String
          ? DateTime.parse(json['createdAt'] as String)
          : (json['createdAt'] as Timestamp).toDate(),
      );
    } catch (e) {
      print('Error parsing UserModel: $e');
      rethrow;
    }
  }
}
