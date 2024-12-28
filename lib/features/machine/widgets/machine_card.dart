// lib/features/machine/widgets/machine_card.dart
import 'package:atomicoat_17th_version/features/machine/data/models/machine_model.dart';
import 'package:atomicoat_17th_version/features/machine/providers/machine_provider.dart';
import 'package:atomicoat_17th_version/features/machine/widgets/assign_admin_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MachineCard extends StatelessWidget {
  final MachineModel machine;
  final VoidCallback onTap;
  final bool isSuperAdmin;
  final bool isAdmin;

  const MachineCard({
    Key? key,
    required this.machine,
    required this.onTap,
    required this.isSuperAdmin,
    required this.isAdmin,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: onTap,
        title: Text(machine.serialNumber),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(machine.location),
            Text('Status: ${machine.status}'),
          ],
        ),
        trailing: isSuperAdmin
            ? PopupMenuButton(
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'assign_admin',
                    child: Text('Assign Admin'),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Text('Delete'),
                  ),
                ],
                onSelected: (value) async {
                  switch (value) {
                    case 'assign_admin':
                      await showDialog(
                        context: context,
                        builder: (context) => AssignAdminDialog(
                          machineId: machine.id,
                        ),
                      );
                      break;
                    case 'delete':
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text('Confirm Delete'),
                          content: Text('Are you sure you want to delete this machine?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: Text('Delete'),
                            ),
                          ],
                        ),
                      );

                      if (confirmed == true) {
                        await context.read<MachineProvider>().deleteMachine(machine.id);
                      }
                      break;
                  }
                },
              )
            : null,
      ),
    );
  }
}
