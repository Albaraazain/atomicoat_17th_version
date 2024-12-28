// lib/features/machine/widgets/machine_card.dart
import 'package:atomicoat_17th_version/features/machine/data/models/machine_model.dart';
import 'package:flutter/material.dart';

class MachineCard extends StatelessWidget {
  final MachineModel machine;
  final VoidCallback onTap;
  final bool isSuperAdmin;
  final bool isAdmin;

  const MachineCard({
    required this.machine,
    required this.onTap,
    required this.isSuperAdmin,
    required this.isAdmin,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        onTap: onTap,
        leading: Icon(Icons.precision_manufacturing),
        title: Text(machine.serialNumber),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${machine.labName} - ${machine.labInstitution}'),
            Text('Status: ${machine.status}'),
          ],
        ),
        trailing: _buildTrailingActions(context),
      ),
    );
  }

  Widget _buildTrailingActions(BuildContext context) {
    if (!isSuperAdmin && !isAdmin) return SizedBox();

    return PopupMenuButton(
      itemBuilder: (context) => [
        if (isSuperAdmin) ...[
          PopupMenuItem(
            value: 'assign_admin',
            child: Text('Assign Admin'),
          ),
          PopupMenuItem(
            value: 'delete',
            child: Text('Delete Machine'),
          ),
        ],
        if (isAdmin) ...[
          PopupMenuItem(
            value: 'manage_users',
            child: Text('Manage Users'),
          ),
          PopupMenuItem(
            value: 'view_requests',
            child: Text('View Requests'),
          ),
        ],
      ],
      onSelected: (value) {
        switch (value) {
          case 'assign_admin':
            _showAssignAdminDialog(context);
            break;
          case 'delete':
            _showDeleteConfirmation(context);
            break;
          case 'manage_users':
            _navigateToUserManagement(context);
            break;
          case 'view_requests':
            _navigateToRequestsManagement(context);
            break;
        }
      },
    );
  }

  void _showAssignAdminDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AssignAdminDialog(machine: machine),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Machine'),
        content: Text('Are you sure you want to delete this machine?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<MachineProvider>().deleteMachine(machine.id);
              Navigator.pop(context);
            },
            child: Text('Delete'),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
          ),
        ],
      ),
    );
  }

  void _navigateToUserManagement(BuildContext context) {
    Navigator.pushNamed(
      context,
      '/machine/users',
      arguments: machine,
    );
  }

  void _navigateToRequestsManagement(BuildContext context) {
    Navigator.pushNamed(
      context,
      '/machine/requests',
      arguments: machine,
    );
  }
}
