// lib/core/screens/auth_wrapper.dart
import 'package:atomicoat_17th_version/core/screens/access_denied_screen.dart';
import 'package:atomicoat_17th_version/core/screens/home_screen.dart';
import 'package:atomicoat_17th_version/core/screens/loading_screen.dart';
import 'package:atomicoat_17th_version/core/screens/pending_approval_screen.dart';
import 'package:atomicoat_17th_version/features/auth/data/models/user_model.dart';
import 'package:atomicoat_17th_version/features/auth/providers/auth_provider.dart';
import 'package:atomicoat_17th_version/features/auth/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        if (authProvider.state.isLoading) {
          return LoadingScreen();
        }

        if (!authProvider.isAuthenticated) {
          return LoginScreen();
        }

        final user = authProvider.currentUser!;
        switch (user.status) {
          case UserStatus.pending:
            return PendingApprovalScreen();
          case UserStatus.active:
            return HomeScreen();
          case UserStatus.inactive:
          case UserStatus.denied:
            return AccessDeniedScreen();
          default:
            return LoginScreen();
        }
      },
    );
  }
}