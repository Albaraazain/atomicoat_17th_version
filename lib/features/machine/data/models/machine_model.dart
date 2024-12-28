class MachineModel {
  final String id;
  final String serialNumber;
  final String location;
  final String labName;
  final String labInstitution;
  final String adminId;
  final List<String> authorizedUsers;
  final String status;
  final DateTime createdAt;
  final DateTime? lastMaintenance;

  MachineModel({
    required this.id,
    required this.serialNumber,
    required this.location,
    required this.labName,
    required this.labInstitution,
    required this.adminId,
    this.authorizedUsers = const [],
    required this.status,
    required this.createdAt,
    this.lastMaintenance,
  });

  factory MachineModel.fromJson(Map<String, dynamic> json) {
    return MachineModel(
      id: json['id'] as String,
      serialNumber: json['serialNumber'] as String,
      location: json['location'] as String,
      labName: json['labName'] as String,
      labInstitution: json['labInstitution'] as String,
      adminId: json['adminId'] as String,
      authorizedUsers: List<String>.from(json['authorizedUsers'] ?? []),
      status: json['status'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastMaintenance: json['lastMaintenance'] != null
          ? DateTime.parse(json['lastMaintenance'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'serialNumber': serialNumber,
    'location': location,
    'labName': labName,
    'labInstitution': labInstitution,
    'adminId': adminId,
    'authorizedUsers': authorizedUsers,
    'status': status,
    'createdAt': createdAt.toIso8601String(),
    'lastMaintenance': lastMaintenance?.toIso8601String(),
  };
}