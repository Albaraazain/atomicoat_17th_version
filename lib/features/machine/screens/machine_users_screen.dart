// lib/features/machine/screens/machine_users_screen.dart
import 'package:atomicoat_17th_version/features/machine/data/models/machine_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MachineUsersScreen extends StatelessWidget {
  final MachineModel machine;

  const MachineUsersScreen({required this.machine});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Machine Users'),
          bottom: TabBar(
            tabs: [
              Tab(text: 'Active Users'),
              Tab(text: 'Pending Requests'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _ActiveUsersTab(machine: machine),
            _PendingRequestsTab(machine: machine),
          ],
        ),
      ),
    );
  }
}

class _ActiveUsersTab extends StatelessWidget {
  final MachineModel machine;

  const _ActiveUsersTab({required this.machine});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .where('machineId', isEqualTo: machine.id)
          .where('status', isEqualTo: 'active')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No active users'));
        }

        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final userData = snapshot.data!.docs[index].data() as Map<String, dynamic>;
            final userId = snapshot.data!.docs[index].id;

            return ListTile(
              leading: Icon(Icons.person),
              title: Text(userData['name'] ?? 'Unknown'),
              subtitle: Text(userData['email'] ?? ''),
              trailing: PopupMenuButton(
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'deactivate',
                    child: Text('Deactivate User'),
                  ),
                  PopupMenuItem(
                    value: 'remove',
                    child: Text('Remove User'),
                  ),
                ],
                onSelected: (value) async {
                  switch (value) {
                    case 'deactivate':
                      await _deactivateUser(context, userId);
                      break;
                    case 'remove':
                      await _removeUser(context, userId);
                      break;
                  }
                },
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _deactivateUser(BuildContext context, String userId) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .update({'status': 'inactive'});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to deactivate user')),
      );
    }
  }

  Future<void> _removeUser(BuildContext context, String userId) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .update({
            'machineId': null,
            'status': 'inactive'
          });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to remove user')),
      );
    }
  }
}

class _PendingRequestsTab extends StatelessWidget {
  final MachineModel machine;

  const _PendingRequestsTab({required this.machine});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .where('machineId', isEqualTo: machine.id)
          .where('status', isEqualTo: 'pending')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No pending requests'));
        }

        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final userData = snapshot.data!.docs[index].data() as Map<String, dynamic>;
            final userId = snapshot.data!.docs[index].id;

            return ListTile(
              leading: Icon(Icons.person_outline),
              title: Text(userData['name'] ?? 'Unknown'),
              subtitle: Text(userData['email'] ?? ''),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.check, color: Colors.green),
                    onPressed: () => _approveRequest(context, userId),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.red),
                    onPressed: () => _denyRequest(context, userId),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _approveRequest(BuildContext context, String userId) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .update({'status': 'active'});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to approve request')),
      );
    }
  }

  Future<void> _denyRequest(BuildContext context, String userId) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .update({'status': 'denied'});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to deny request')),
      );
    }
  }
}