// lib/features/machine/providers/machine_provider.dart
import 'dart:async';

import 'package:atomicoat_17th_version/features/auth/providers/auth_provider.dart';
import 'package:atomicoat_17th_version/features/machine/data/models/machine_model.dart';
import 'package:atomicoat_17th_version/features/machine/data/repositories/machine_repository.dart';
import 'package:flutter/foundation.dart';

class MachineProvider extends ChangeNotifier {
  final MachineRepository _repository;
  final AuthProvider _authProvider;
  List<MachineModel> _machines = [];

  MachineProvider(this._repository, this._authProvider) {
    // Initialize machines when auth state changes
    _authProvider.addListener(_loadMachinesOnAuthChange);
  }

  List<MachineModel> get machines => _machines;

  void _loadMachinesOnAuthChange() {
    if (_authProvider.currentUser != null) {
      loadMachines();
    } else {
      _machines = [];
      notifyListeners();
    }
  }

  Future<void> loadMachines() async {
    _machines = await _repository.getMachines();
    notifyListeners();
  }

  Future<void> createMachine({
    required String serialNumber,
    required String location,
    required String status,
    required List<String> authorizedUsers,
  }) async {
    final machine = MachineModel(
      id: '',
      serialNumber: serialNumber,
      location: location,
      status: status,
      authorizedUsers: authorizedUsers,
    );
    await _repository.createMachine(machine);
    await loadMachines();
  }

  Future<void> updateMachine(MachineModel machine) async {
    await _repository.updateMachine(machine);
    await loadMachines();
  }

  Future<void> deleteMachine(String machineId) async {
    await _repository.deleteMachine(machineId);
    await loadMachines();
  }

  Future<void> updateMachineStatus(String machineId, String newStatus) async {
    final machine = _machines.firstWhere((m) => m.id == machineId);
    final updatedMachine = machine.copyWith(status: newStatus);
    await _repository.updateMachine(updatedMachine);
    await loadMachines();
  }

  @override
  void dispose() {
    _authProvider.removeListener(_loadMachinesOnAuthChange);
    super.dispose();
  }
}
