// lib/features/machine/screens/user_management_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class UserManagementScreen extends StatelessWidget {
  final String machineId;

  const UserManagementScreen({required this.machineId});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Color(0xFF121212),
        appBar: AppBar(
          backgroundColor: Color(0xFF1E1E1E),
          title: Text('User Management'),
          bottom: TabBar(
            indicatorColor: Color(0xFF64FFDA),
            tabs: [
              Tab(text: 'Active Users'),
              Tab(text: 'Pending Requests'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _ActiveUsersTab(machineId: machineId),
            _PendingRequestsTab(machineId: machineId),
          ],
        ),
      ),
    );
  }
}

class _ActiveUsersTab extends StatelessWidget {
  final String machineId;

  const _ActiveUsersTab({required this.machineId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .where('machineId', isEqualTo: machineId)
          .where('status', isEqualTo: 'active')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF64FFDA)),
            ),
          );
        }

        if (snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text(
              'No active users',
              style: TextStyle(color: Color(0xFFB0B0B0)),
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final userData = snapshot.data!.docs[index].data() as Map<String, dynamic>;
            final userId = snapshot.data!.docs[index].id;

            return Card(
              color: Color(0xFF1E1E1E),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: EdgeInsets.only(bottom: 12),
              child: ListTile(
                contentPadding: EdgeInsets.all(16),
                leading: CircleAvatar(
                  backgroundColor: Color(0xFF2A2A2A),
                  child: Text(
                    (userData['name'] as String).substring(0, 1).toUpperCase(),
                    style: TextStyle(color: Color(0xFF64FFDA)),
                  ),
                ),
                title: Text(
                  userData['name'] ?? 'Unknown',
                  style: TextStyle(
                    color: Color(0xFFE0E0E0),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userData['email'] ?? '',
                      style: TextStyle(color: Color(0xFFB0B0B0)),
                    ),
                    SizedBox(height: 4),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Color(0xFF2A2A2A),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        userData['role']?.toString().toUpperCase() ?? 'USER',
                        style: TextStyle(
                          color: Color(0xFF64FFDA),
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                trailing: PopupMenuButton(
                  color: Color(0xFF2A2A2A),
                  icon: Icon(Icons.more_vert, color: Color(0xFFE0E0E0)),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      child: ListTile(
                        leading: Icon(Icons.block, color: Colors.redAccent),
                        title: Text(
                          'Deactivate User',
                          style: TextStyle(color: Color(0xFFE0E0E0)),
                        ),
                      ),
                      value: 'deactivate',
                    ),
                    PopupMenuItem(
                      child: ListTile(
                        leading: Icon(Icons.edit, color: Color(0xFF64FFDA)),
                        title: Text(
                          'Change Role',
                          style: TextStyle(color: Color(0xFFE0E0E0)),
                        ),
                      ),
                      value: 'change_role',
                    ),
                  ],
                  onSelected: (value) {
                    switch (value) {
                      case 'deactivate':
                        _showDeactivateDialog(context, userId);
                        break;
                      case 'change_role':
                        _showChangeRoleDialog(context, userId, userData['role']);
                        break;
                    }
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showDeactivateDialog(BuildContext context, String userId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF1E1E1E),
        title: Text(
          'Deactivate User',
          style: TextStyle(color: Color(0xFFE0E0E0)),
        ),
        content: Text(
          'Are you sure you want to deactivate this user? They will no longer have access to the machine.',
          style: TextStyle(color: Color(0xFFB0B0B0)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: Color(0xFF64FFDA)),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(userId)
                  .update({
                'status': 'inactive',
              });
              Navigator.pop(context);
            },
            child: Text('Deactivate'),
          ),
        ],
      ),
    );
  }

  void _showChangeRoleDialog(BuildContext context, String userId, String currentRole) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF1E1E1E),
        title: Text(
          'Change User Role',
          style: TextStyle(color: Color(0xFFE0E0E0)),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(
                'Operator',
                style: TextStyle(color: Color(0xFFE0E0E0)),
              ),
              leading: Radio<String>(
                value: 'operator',
                groupValue: currentRole,
                onChanged: (value) async {
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(userId)
                      .update({'role': value});
                  Navigator.pop(context);
                },
                fillColor: WidgetStateProperty.all(Color(0xFF64FFDA)),
              ),
            ),
            ListTile(
              title: Text(
                'User',
                style: TextStyle(color: Color(0xFFE0E0E0)),
              ),
              leading: Radio<String>(
                value: 'user',
                groupValue: currentRole,
                onChanged: (value) async {
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(userId)
                      .update({'role': value});
                  Navigator.pop(context);
                },
                fillColor: WidgetStateProperty.all(Color(0xFF64FFDA)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PendingRequestsTab extends StatelessWidget {
  final String machineId;

  const _PendingRequestsTab({required this.machineId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .where('machineId', isEqualTo: machineId)
          .where('status', isEqualTo: 'pending')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF64FFDA)),
            ),
          );
        }

        if (snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text(
              'No pending requests',
              style: TextStyle(color: Color(0xFFB0B0B0)),
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final userData = snapshot.data!.docs[index].data() as Map<String, dynamic>;
            final userId = snapshot.data!.docs[index].id;

            return Card(
              color: Color(0xFF1E1E1E),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Color(0xFF2A2A2A),
                          child: Text(
                            (userData['name'] as String).substring(0, 1).toUpperCase(),
                            style: TextStyle(color: Color(0xFF64FFDA)),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                userData['name'] ?? 'Unknown',
                                style: TextStyle(
                                  color: Color(0xFFE0E0E0),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                userData['email'] ?? '',
                                style: TextStyle(color: Color(0xFFB0B0B0)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Request Details',
                      style: TextStyle(
                        color: Color(0xFFE0E0E0),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Requested on: ${_formatDate(userData['createdAt'])}',
                      style: TextStyle(color: Color(0xFFB0B0B0)),
                    ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => _handleRequest(context, userId, false),
                          child: Text(
                            'Deny',
                            style: TextStyle(color: Colors.redAccent),
                          ),
                        ),
                        SizedBox(width: 16),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF64FFDA),
                            foregroundColor: Colors.black,
                          ),
                          onPressed: () => _handleRequest(context, userId, true),
                          child: Text('Approve'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  String _formatDate(Timestamp? timestamp) {
    if (timestamp == null) return 'Unknown';
    return DateFormat('MMM d, yyyy').format(timestamp.toDate());
  }

  Future<void> _handleRequest(BuildContext context, String userId, bool approve) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .update({
        'status': approve ? 'active' : 'denied',
        'updatedAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            approve ? 'User approved successfully' : 'User request denied',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: approve ? Colors.green : Colors.redAccent,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error: ${e.toString()}',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }
}