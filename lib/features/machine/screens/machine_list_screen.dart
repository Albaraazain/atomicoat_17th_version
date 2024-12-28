// lib/features/machine/screens/machine_list_screen.dart
import 'package:atomicoat_17th_version/features/auth/data/models/user_model.dart';
import 'package:atomicoat_17th_version/features/auth/providers/auth_provider.dart';
import 'package:atomicoat_17th_version/features/machine/data/models/machine_model.dart';
import 'package:atomicoat_17th_version/features/machine/providers/machine_provider.dart';
import 'package:atomicoat_17th_version/features/machine/widgets/create_machine_dialog.dart';
import 'package:atomicoat_17th_version/features/machine/widgets/machine_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MachineListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, MachineProvider>(
      builder: (context, authProvider, machineProvider, _) {
        final isSuperAdmin = authProvider.currentUser?.role == UserRole.superAdmin;
        final isAdmin = authProvider.currentUser?.role == UserRole.admin;

        return Scaffold(
          appBar: AppBar(
            title: Text(isSuperAdmin ? 'All Machines' : 'My Machine'),
          ),
          // Only super admin can create new machines
          floatingActionButton: isSuperAdmin
              ? FloatingActionButton(
                  onPressed: () => _showCreateMachineDialog(context),
                  child: Icon(Icons.add),
                )
              : null,
          body: _buildMachineList(
            context,
            machineProvider.machines,
            isSuperAdmin,
            isAdmin,
          ),
        );
      },
    );
  }

  Widget _buildMachineList(
    BuildContext context,
    List<MachineModel> machines,
    bool isSuperAdmin,
    bool isAdmin,
  ) {
    if (machines.isEmpty) {
      return Center(
        child: Text('No machines found'),
      );
    }

    return ListView.builder(
      itemCount: machines.length,
      itemBuilder: (context, index) {
        final machine = machines[index];
        return MachineCard(
          machine: machine,
          onTap: () => Navigator.pushNamed(
            context,
            '/machine/details',
            arguments: machine,
          ),
          isSuperAdmin: isSuperAdmin,
          isAdmin: isAdmin && machine.adminId == context.read<AuthProvider>().currentUser?.id,
        );
      },
    );
  }

  void _showCreateMachineDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => CreateMachineDialog(),
    );
  }
}
