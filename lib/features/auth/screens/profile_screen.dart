// lib/features/auth/screens/profile_screen.dart
import 'package:atomicoat_17th_version/features/auth/data/models/user_model.dart';
import 'package:atomicoat_17th_version/features/auth/providers/auth_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        final user = authProvider.currentUser;

        return Scaffold(
          backgroundColor: Color(0xFF121212),
          appBar: AppBar(
            backgroundColor: Color(0xFF1E1E1E),
            title: Text('Profile'),
            elevation: 0,
          ),
          body: SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProfileHeader(user),
                SizedBox(height: 24),
                _buildMachineInfo(user),
                SizedBox(height: 24),
                _buildActivitySection(user),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileHeader(UserModel? user) {
    return Card(
      color: Color(0xFF1E1E1E),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: Color(0xFF2A2A2A),
              child: Text(
                user?.name.substring(0, 1).toUpperCase() ?? 'U',
                style: TextStyle(
                  fontSize: 28,
                  color: Color(0xFFE0E0E0),
                ),
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user?.name ?? 'User',
                    style: TextStyle(
                      color: Color(0xFFE0E0E0),
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    user?.email ?? '',
                    style: TextStyle(
                      color: Color(0xFFB0B0B0),
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 8),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Color(0xFF2A2A2A),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      user?.role.toString().split('.').last.toUpperCase() ?? 'USER',
                      style: TextStyle(
                        color: Color(0xFF64FFDA),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMachineInfo(UserModel? user) {
    if (user?.machineId == null) return SizedBox();

    return Card(
      color: Color(0xFF1E1E1E),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('machines')
            .doc(user!.machineId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final machineData = snapshot.data!.data() as Map<String, dynamic>;
          return Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Machine Access',
                  style: TextStyle(
                    color: Color(0xFFE0E0E0),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16),
                _buildInfoRow(
                  'Serial Number:',
                  machineData['serialNumber'] ?? 'N/A',
                ),
                _buildInfoRow(
                  'Location:',
                  machineData['location'] ?? 'N/A',
                ),
                _buildInfoRow(
                  'Lab Name:',
                  machineData['labName'] ?? 'N/A',
                ),
                _buildInfoRow(
                  'Institution:',
                  machineData['labInstitution'] ?? 'N/A',
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _getStatusColor(machineData['status']),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        machineData['status']?.toString().toUpperCase() ?? 'OFFLINE',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'active':
        return Colors.green;
      case 'maintenance':
        return Colors.orange;
      case 'error':
        return Colors.red;
      default:
        return Colors.grey;
    }
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
              style: TextStyle(
                color: Color(0xFFB0B0B0),
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: Color(0xFFE0E0E0),
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivitySection(UserModel? user) {
    return Card(
      color: Color(0xFF1E1E1E),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent Activity',
              style: TextStyle(
                color: Color(0xFFE0E0E0),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('activity_logs')
                  .where('userId', isEqualTo: user?.id)
                  .orderBy('timestamp', descending: true)
                  .limit(5)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Text(
                      'No recent activity',
                      style: TextStyle(
                        color: Color(0xFFB0B0B0),
                        fontSize: 14,
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final activity = snapshot.data!.docs[index].data()
                        as Map<String, dynamic>;
                    return _buildActivityItem(activity);
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(Map<String, dynamic> activity) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Color(0xFF2A2A2A),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getActivityIcon(activity['type']),
              color: Color(0xFF64FFDA),
              size: 20,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity['description'] ?? '',
                  style: TextStyle(
                    color: Color(0xFFE0E0E0),
                    fontSize: 14,
                  ),
                ),
                Text(
                  _formatTimestamp(activity['timestamp']),
                  style: TextStyle(
                    color: Color(0xFFB0B0B0),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getActivityIcon(String? type) {
    switch (type) {
      case 'login':
        return Icons.login;
      case 'experiment':
        return Icons.science;
      case 'recipe':
        return Icons.book;
      case 'maintenance':
        return Icons.build;
      default:
        return Icons.circle;
    }
  }

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return '';
    return timeago.format(timestamp.toDate());
  }
}