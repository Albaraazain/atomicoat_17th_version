// lib/features/auth/data/models/user_model.dart
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

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json['id'],
    email: json['email'],
    name: json['name'],
    role: UserRole.values.firstWhere(
      (e) => e.toString().split('.').last == json['role'],
    ),
    status: UserStatus.values.firstWhere(
      (e) => e.toString().split('.').last == json['status'],
    ),
    machineId: json['machineId'],
    createdAt: DateTime.parse(json['createdAt']),
  );
}
