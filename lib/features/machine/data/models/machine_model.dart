import 'package:cloud_firestore/cloud_firestore.dart';

class MachineModel {
  final String id;
  final String serialNumber;
  final String location;
  final String status;
  final DateTime? lastMaintenance;
  final List<String> authorizedUsers;
  final String? adminId;

  MachineModel({
    required this.id,
    required this.serialNumber,
    required this.location,
    required this.status,
    this.lastMaintenance,
    required this.authorizedUsers,
    this.adminId,
  });

  factory MachineModel.fromMap(Map<String, dynamic> map, String id) {
    return MachineModel(
      id: id,
      serialNumber: map['serialNumber'] ?? '',
      location: map['location'] ?? '',
      status: map['status'] ?? 'inactive',
      lastMaintenance: (map['lastMaintenance'] as Timestamp?)?.toDate(),
      authorizedUsers: List<String>.from(map['authorizedUsers'] ?? []),
      adminId: map['adminId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'serialNumber': serialNumber,
      'location': location,
      'status': status,
      'lastMaintenance': lastMaintenance != null ? Timestamp.fromDate(lastMaintenance!) : null,
      'authorizedUsers': authorizedUsers,
      'adminId': adminId,
    };
  }

  MachineModel copyWith({
    String? id,
    String? serialNumber,
    String? location,
    String? status,
    DateTime? lastMaintenance,
    List<String>? authorizedUsers,
    String? adminId,
  }) {
    return MachineModel(
      id: id ?? this.id,
      serialNumber: serialNumber ?? this.serialNumber,
      location: location ?? this.location,
      status: status ?? this.status,
      lastMaintenance: lastMaintenance ?? this.lastMaintenance,
      authorizedUsers: authorizedUsers ?? this.authorizedUsers,
      adminId: adminId ?? this.adminId,
    );
  }
}