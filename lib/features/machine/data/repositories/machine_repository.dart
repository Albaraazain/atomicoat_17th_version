// lib/features/machine/data/repositories/machine_repository.dart
import 'package:atomicoat_17th_version/features/machine/data/models/machine_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MachineRepository {
  final FirebaseFirestore _firestore;
  final String _collection = 'machines';

  MachineRepository(this._firestore);

  Future<List<MachineModel>> getMachines() async {
    final snapshot = await _firestore.collection(_collection).get();
    return snapshot.docs
        .map((doc) => MachineModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  Future<void> createMachine(MachineModel machine) async {
    await _firestore.collection(_collection).add(machine.toMap());
  }

  Future<void> updateMachine(MachineModel machine) async {
    await _firestore
        .collection(_collection)
        .doc(machine.id)
        .update(machine.toMap());
  }

  Future<void> deleteMachine(String machineId) async {
    await _firestore.collection(_collection).doc(machineId).delete();
  }
}
