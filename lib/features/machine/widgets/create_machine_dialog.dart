// lib/features/machine/widgets/create_machine_dialog.dart
import 'package:atomicoat_17th_version/features/machine/data/models/machine_model.dart';
import 'package:atomicoat_17th_version/features/machine/providers/machine_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CreateMachineDialog extends StatefulWidget {
  @override
  _CreateMachineDialogState createState() => _CreateMachineDialogState();
}

class _CreateMachineDialogState extends State<CreateMachineDialog> {
  final _formKey = GlobalKey<FormState>();
  final _serialController = TextEditingController();
  final _locationController = TextEditingController();
  final _labNameController = TextEditingController();
  final _labInstitutionController = TextEditingController();
  String? _selectedAdminId;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Create New Machine'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _serialController,
                decoration: InputDecoration(
                  labelText: 'Serial Number',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter serial number';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _locationController,
                decoration: InputDecoration(
                  labelText: 'Location',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter location';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _labNameController,
                decoration: InputDecoration(
                  labelText: 'Lab Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter lab name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _labInstitutionController,
                decoration: InputDecoration(
                  labelText: 'Institution',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter institution';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              _buildAdminSelector(),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _handleSubmit,
          child: _isLoading
              ? SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text('Create'),
        ),
      ],
    );
  }

  Widget _buildAdminSelector() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'admin')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return CircularProgressIndicator();
        }

        List<DropdownMenuItem<String>> adminItems = [];
        for (var doc in snapshot.data!.docs) {
          final userData = doc.data() as Map<String, dynamic>;
          adminItems.add(DropdownMenuItem(
            value: doc.id,
            child: Text(userData['name'] ?? 'Unknown'),
          ));
        }

        return DropdownButtonFormField<String>(
          value: _selectedAdminId,
          decoration: InputDecoration(
            labelText: 'Assign Admin',
            border: OutlineInputBorder(),
          ),
          items: adminItems,
          onChanged: (value) {
            setState(() {
              _selectedAdminId = value;
            });
          },
          validator: (value) {
            if (value == null) {
              return 'Please select an admin';
            }
            return null;
          },
        );
      },
    );
  }

  Future<void> _handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final newMachine = MachineModel(
          id: '',  // Will be set by Firestore
          serialNumber: _serialController.text,
          location: _locationController.text,
          labName: _labNameController.text,
          labInstitution: _labInstitutionController.text,
          adminId: _selectedAdminId!,
          status: 'active',
          createdAt: DateTime.now(),
        );

        await context.read<MachineProvider>().createMachine(newMachine);
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _serialController.dispose();
    _locationController.dispose();
    _labNameController.dispose();
    _labInstitutionController.dispose();
    super.dispose();
  }
}