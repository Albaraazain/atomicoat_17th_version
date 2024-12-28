// lib/features/machine/widgets/edit_machine_dialog.dart
import 'package:atomicoat_17th_version/features/machine/data/models/machine_model.dart';
import 'package:atomicoat_17th_version/features/machine/providers/machine_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EditMachineDialog extends StatefulWidget {
  final MachineModel machine;

  const EditMachineDialog({required this.machine});

  @override
  _EditMachineDialogState createState() => _EditMachineDialogState();
}

class _EditMachineDialogState extends State<EditMachineDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _locationController;
  late String _status;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _locationController = TextEditingController(text: widget.machine.location);
    _status = widget.machine.status;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Edit Machine'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Serial number display (non-editable)
              TextFormField(
                initialValue: widget.machine.serialNumber,
                enabled: false,
                decoration: InputDecoration(
                  labelText: 'Serial Number',
                  border: OutlineInputBorder(),
                ),
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
              DropdownButtonFormField<String>(
                value: _status,
                decoration: InputDecoration(
                  labelText: 'Status',
                  border: OutlineInputBorder(),
                ),
                items: ['active', 'maintenance', 'inactive']
                    .map((status) => DropdownMenuItem(
                          value: status,
                          child: Text(status.toUpperCase()),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _status = value;
                    });
                  }
                },
              ),
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
              : Text('Save Changes'),
        ),
      ],
    );
  }

  Future<void> _handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final updatedMachine = widget.machine.copyWith(
          location: _locationController.text,
          status: _status,
        );

        await context.read<MachineProvider>().updateMachine(updatedMachine);
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
    _locationController.dispose();
    super.dispose();
  }
}