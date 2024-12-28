// lib/features/machine/widgets/change_admin_dialog.dart
import 'package:atomicoat_17th_version/features/machine/data/models/machine_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ChangeAdminDialog extends StatefulWidget {
  final MachineModel machine;

  const ChangeAdminDialog({required this.machine});

  @override
  _ChangeAdminDialogState createState() => _ChangeAdminDialogState();
}

class _ChangeAdminDialogState extends State<ChangeAdminDialog> {
  String? _selectedAdminId;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Change Machine Admin'),
      content: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .where('role', isEqualTo: 'admin')
            .where('machineId', isNull: true) // Admins not assigned to any machine
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('Error loading admins');
          }

          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final admins = snapshot.data!.docs;
          if (admins.isEmpty) {
            return Text('No available admins found');
          }

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: _selectedAdminId,
                decoration: InputDecoration(
                  labelText: 'Select New Admin',
                  border: OutlineInputBorder(),
                ),
                items: admins.map((admin) {
                  final adminData = admin.data() as Map<String, dynamic>;
                  return DropdownMenuItem(
                    value: admin.id,
                    child: Text('${adminData['name']} (${adminData['email']})'),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedAdminId = value;
                  });
                },
              ),
            ],
          );
        },
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _selectedAdminId == null || _isLoading
              ? null
              : _handleChangeAdmin,
          child: _isLoading
              ? SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text('Change Admin'),
        ),
      ],
    );
  }

  Future<void> _handleChangeAdmin() async {
    setState(() => _isLoading = true);
    try {
      final batch = FirebaseFirestore.instance.batch();

      // Remove machine assignment from current admin
      batch.update(
        FirebaseFirestore.instance.collection('users').doc(widget.machine.adminId),
        {
          'machineId': null,
          'role': 'user',
        },
      );

      // Assign machine to new admin
      batch.update(
        FirebaseFirestore.instance.collection('users').doc(_selectedAdminId),
        {
          'machineId': widget.machine.id,
          'role': 'admin',
        },
      );

      // Update machine's admin
      batch.update(
        FirebaseFirestore.instance.collection('machines').doc(widget.machine.id),
        {
          'adminId': _selectedAdminId,
        },
      );

      await batch.commit();
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to change admin: ${e.toString()}')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }
}