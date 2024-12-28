// lib/features/machine/data/repositories/machine_repository.dart
import 'package:atomicoat_17th_version/features/auth/data/models/user_model.dart';
import 'package:atomicoat_17th_version/features/machine/data/models/machine_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MachineRepository {
  final FirebaseFirestore _firestore;

  MachineRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // Creates new machine and assigns admin
  Future<void> createMachine(MachineModel machine) async {
    final batch = _firestore.batch();

    // Create machine document
    final machineRef = _firestore.collection('machines').doc();
    batch.set(machineRef, machine.toJson());

    // Update admin's user document with machineId
    final adminRef = _firestore.collection('users').doc(machine.adminId);
    batch.update(adminRef, {
      'machineId': machineRef.id,
      'role': 'admin'
    });

    await batch.commit();
  }

  Future<void> addUserToMachine(String machineId, String userId) async {
    await _firestore.collection('machines').doc(machineId).update({
      'authorizedUsers': FieldValue.arrayUnion([userId])
    });
  }

  // Get machines based on user role
  Stream<List<MachineModel>> getMachinesStream(String userId, UserRole role) {
    if (role == UserRole.superAdmin) {
      return _firestore.collection('machines').snapshots().map((snapshot) =>
          snapshot.docs.map((doc) => MachineModel.fromJson(doc.data())).toList());
    } else {
      return _firestore
          .collection('machines')
          .where('authorizedUsers', arrayContains: userId)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => MachineModel.fromJson(doc.data()))
              .toList());
    }
  }
}
