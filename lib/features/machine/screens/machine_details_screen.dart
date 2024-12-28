// lib/features/machine/screens/machine_details_screen.dart
import 'package:atomicoat_17th_version/features/auth/data/models/user_model.dart';
import 'package:atomicoat_17th_version/features/auth/providers/auth_provider.dart';
import 'package:atomicoat_17th_version/features/machine/data/models/machine_model.dart';
import 'package:atomicoat_17th_version/features/machine/providers/machine_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class MachineDetailsScreen extends StatelessWidget {
  final MachineModel machine;

  const MachineDetailsScreen({required this.machine});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Machine Details'),
        actions: [
          if (context.read<AuthProvider>().currentUser?.role == UserRole.superAdmin)
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: () => _showEditDialog(context),
            ),
        ],
      ),
      body: Consumer<MachineProvider>(
        builder: (context, machineProvider, _) {
          return SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoCard(context),
                SizedBox(height: 16),
                _buildStatusCard(context),
                SizedBox(height: 16),
                _buildAdminCard(context),
                SizedBox(height: 16),
                _buildUsersCard(context),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Machine Information',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Divider(),
            _buildInfoRow('Serial Number:', machine.serialNumber),
            _buildInfoRow('Location:', machine.location),
            _buildInfoRow('Status:', machine.status),
            if (machine.adminId != null)
              _buildInfoRow('Admin ID:', machine.adminId!),
            _buildInfoRow('Authorized Users:', machine.authorizedUsers.length.toString()),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Status',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                _buildStatusChip(machine.status),
              ],
            ),
            Divider(),
            if (machine.lastMaintenance != null)
              _buildInfoRow(
                'Last Maintenance:',
                DateFormat('dd MMM yyyy').format(machine.lastMaintenance!),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Machine Admin',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                if (context.read<AuthProvider>().currentUser?.role == UserRole.superAdmin)
                  TextButton(
                    onPressed: () => _showChangeAdminDialog(context),
                    child: Text('Change Admin'),
                  ),
              ],
            ),
            Divider(),
            FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .doc(machine.adminId)
                  .get(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return CircularProgressIndicator();
                }

                final adminData = snapshot.data!.data() as Map<String, dynamic>;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow('Name:', adminData['name'] ?? 'Unknown'),
                    _buildInfoRow('Email:', adminData['email'] ?? ''),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUsersCard(BuildContext context) {
    final isAdmin = context.read<AuthProvider>().currentUser?.id == machine.adminId;
    final isSuperAdmin = context.read<AuthProvider>().currentUser?.role == UserRole.superAdmin;

    if (!isAdmin && !isSuperAdmin) return SizedBox();

    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Machine Users',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pushNamed(
                    context,
                    '/machine/users',
                    arguments: machine,
                  ),
                  child: Text('Manage Users'),
                ),
              ],
            ),
            Divider(),
            _buildUsersList(),
          ],
        ),
      ),
    );
  }

  Widget _buildUsersList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .where('machineId', isEqualTo: machine.id)
          .where('status', isEqualTo: 'active')
          .limit(5)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return CircularProgressIndicator();
        }

        if (snapshot.data!.docs.isEmpty) {
          return Padding(
            padding: EdgeInsets.all(8),
            child: Text('No active users'),
          );
        }

        return Column(
          children: [
            ...snapshot.data!.docs.map((doc) {
              final userData = doc.data() as Map<String, dynamic>;
              return ListTile(
                leading: Icon(Icons.person),
                title: Text(userData['name'] ?? 'Unknown'),
                subtitle: Text(userData['email'] ?? ''),
              );
            }),
            if (snapshot.data!.docs.length == 5)
              TextButton(
                onPressed: () => Navigator.pushNamed(
                  context,
                  '/machine/users',
                  arguments: machine,
                ),
                child: Text('View All Users'),
              ),
          ],
        );
      },
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'active':
        color = Colors.green;
        break;
      case 'maintenance':
        color = Colors.orange;
        break;
      case 'inactive':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return Chip(
      label: Text(
        status.toUpperCase(),
        style: TextStyle(color: Colors.white),
      ),
      backgroundColor: color,
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context) {
    // Implement machine edit dialog
  }

  void _showChangeAdminDialog(BuildContext context) {
    // Implement change admin dialog
  }
}