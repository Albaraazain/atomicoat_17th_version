// lib/features/machine/providers/machine_provider.dart
import 'dart:async';

import 'package:atomicoat_17th_version/features/auth/providers/auth_provider.dart';
import 'package:atomicoat_17th_version/features/machine/data/models/machine_model.dart';
import 'package:atomicoat_17th_version/features/machine/data/repositories/machine_repository.dart';
import 'package:atomicoat_17th_version/features/machine/providers/machine_state.dart';
import 'package:flutter/foundation.dart';

class MachineProvider with ChangeNotifier {
  final MachineRepository _machineRepository;
  final AuthProvider _authProvider;
  MachineState _state = MachineState();
  StreamSubscription? _machineSubscription;

  MachineProvider(this._machineRepository, this._authProvider) {
    _initializeMachineStream();
  }

  MachineState get state => _state;
  List<MachineModel> get machines => _state.machines;
  MachineModel? get selectedMachine => _state.selectedMachine;

  void _updateState({
    bool? isLoading,
    List<MachineModel>? machines,
    MachineModel? selectedMachine,
    String? error,
  }) {
    _state = _state.copyWith(
      isLoading: isLoading,
      machines: machines,
      selectedMachine: selectedMachine,
      error: error,
    );
    notifyListeners();
  }

  void _initializeMachineStream() {
    _machineSubscription?.cancel();
    if (_authProvider.currentUser != null) {
      _machineSubscription = _machineRepository
          .getMachinesStream(
            _authProvider.currentUser!.id,
            _authProvider.currentUser!.role,
          )
          .listen(
            (machines) => _updateState(machines: machines),
            onError: (error) => _updateState(error: error.toString()),
          );
    }
  }

  Future<void> createMachine(MachineModel machine) async {
    try {
      _updateState(isLoading: true, error: null);
      await _machineRepository.createMachine(machine);
      _updateState(isLoading: false);
    } catch (e) {
      _updateState(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> updateMachineStatus(String machineId, String status) async {
    try {
      _updateState(isLoading: true, error: null);
      await _machineRepository.updateMachineStatus(machineId, status);
      _updateState(isLoading: false);
    } catch (e) {
      _updateState(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  void selectMachine(MachineModel machine) {
    _updateState(selectedMachine: machine);
  }

  @override
  void dispose() {
    _machineSubscription?.cancel();
    super.dispose();
  }
}
