// lib/features/machine/providers/machine_state.dart
import 'package:atomicoat_17th_version/features/machine/data/models/machine_model.dart';

class MachineState {
  final bool isLoading;
  final List<MachineModel> machines;
  final MachineModel? selectedMachine;
  final String? error;

  MachineState({
    this.isLoading = false,
    this.machines = const [],
    this.selectedMachine,
    this.error,
  });

  MachineState copyWith({
    bool? isLoading,
    List<MachineModel>? machines,
    MachineModel? selectedMachine,
    String? error,
  }) {
    return MachineState(
      isLoading: isLoading ?? this.isLoading,
      machines: machines ?? this.machines,
      selectedMachine: selectedMachine ?? this.selectedMachine,
      error: error ?? this.error,
    );
  }
}
