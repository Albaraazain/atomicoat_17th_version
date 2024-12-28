// lib/features/auth/screens/registration_screen.dart
import 'package:atomicoat_17th_version/features/auth/providers/auth_provider.dart';
import 'package:flutter/material.dart';

class RegistrationScreen extends StatefulWidget {
  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _machineSerialController = TextEditingController();
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Register')),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          return SingleChildScrollView(
            padding: EdgeInsets.all(24),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Create Account',
                        style: Theme.of(context).textTheme.headlineSmall,
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 24),
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Full Name',
                          prefixIcon: Icon(Icons.person),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your name';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || !value.contains('@')) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: Icon(Icons.lock),
                          suffixIcon: IconButton(
                            icon: Icon(_obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _machineSerialController,
                        decoration: InputDecoration(
                          labelText: 'Machine Serial Number',
                          prefixIcon: Icon(Icons.precision_manufacturing),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter machine serial number';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 24),
                      if (authProvider.state.error != null)
                        Padding(
                          padding: EdgeInsets.only(bottom: 16),
                          child: Text(
                            authProvider.state.error!,
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ElevatedButton(
                        onPressed: authProvider.state.isLoading
                            ? null
                            : _handleRegistration,
                        child: authProvider.state.isLoading
                            ? CircularProgressIndicator()
                            : Text('Register'),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _handleRegistration() async {
    if (_formKey.currentState!.validate()) {
      try {
        await context.read<AuthProvider>().register(
          _emailController.text,
          _passwordController.text,
          _nameController.text,
          _machineSerialController.text,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Registration successful. Please wait for admin approval.'),
            duration: Duration(seconds: 5),
          ),
        );

        Navigator.pop(context);
      } catch (e) {
        // Error is handled by the provider and shown in UI
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _machineSerialController.dispose();
    super.dispose();
  }
}