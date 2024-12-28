// lib/features/auth/screens/login_screen.dart
import 'package:atomicoat_17th_version/features/auth/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          return Center(
            child: SingleChildScrollView(
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
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'ALD System Login',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        SizedBox(height: 24),
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
                        SizedBox(height: 24),
                        if (authProvider.state.error != null)
                          Padding(
                            padding: EdgeInsets.only(bottom: 16),
                            child: Text(
                              authProvider.state.error!,
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: authProvider.state.isLoading
                                ? null
                                : _handleLogin,
                            child: authProvider.state.isLoading
                                ? CircularProgressIndicator()
                                : Text('Login'),
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 16),
                            ),
                          ),
                        ),
                        SizedBox(height: 16),
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/register');
                          },
                          child: Text('Need an account? Register'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      try {
        await context.read<AuthProvider>().signIn(
          _emailController.text,
          _passwordController.text,
        );
      } catch (e) {
        // Error is handled by the provider and shown in UI
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}