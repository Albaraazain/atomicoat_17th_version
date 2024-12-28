import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AssignAdminDialog extends StatelessWidget {
  final String machineId;

  const AssignAdminDialog({
    Key? key,
    required this.machineId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Assign Admin'),
      content: SizedBox(
        width: double.maxFinite,
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .where('role', isEqualTo: 'admin')
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            }

            if (snapshot.data!.docs.isEmpty) {
              return Center(child: Text('No admins found'));
            }

            return ListView.builder(
              shrinkWrap: true,
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                final userData = snapshot.data!.docs[index].data() as Map<String, dynamic>;
                final userId = snapshot.data!.docs[index].id;

                return ListTile(
                  leading: Icon(Icons.person),
                  title: Text(userData['name'] ?? 'Unknown'),
                  subtitle: Text(userData['email'] ?? ''),
                  onTap: () => _assignAdmin(context, userId),
                );
              },
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
      ],
    );
  }

  Future<void> _assignAdmin(BuildContext context, String adminId) async {
    try {
      await FirebaseFirestore.instance
          .collection('machines')
          .doc(machineId)
          .update({'adminId': adminId});
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to assign admin')),
      );
    }
  }
}