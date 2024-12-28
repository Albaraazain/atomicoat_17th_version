// lib/core/config/route_config.dart
import 'package:atomicoat_17th_version/features/auth/data/models/user_model.dart';
import 'package:atomicoat_17th_version/features/auth/providers/auth_provider.dart';
import 'package:atomicoat_17th_version/features/auth/screens/login_screen.dart';
import 'package:atomicoat_17th_version/features/auth/screens/registration_screen.dart';
import 'package:atomicoat_17th_version/features/machine/data/models/machine_model.dart';
import 'package:atomicoat_17th_version/features/machine/screens/machine_details_screen.dart';
import 'package:atomicoat_17th_version/features/machine/screens/machine_list_screen.dart';
import 'package:atomicoat_17th_version/features/machine/screens/machine_users_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RouteConfig {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(
          builder: (_) => AuthWrapper(),
        );

      case '/login':
        return MaterialPageRoute(
          builder: (_) => LoginScreen(),
        );

      case '/register':
        return MaterialPageRoute(
          builder: (_) => RegistrationScreen(),
        );

      case '/machines':
        return MaterialPageRoute(
          builder: (_) => MachineListScreen(),
        );

      case '/machine/details':
        final machine = settings.arguments as MachineModel;
        return MaterialPageRoute(
          builder: (_) => MachineDetailsScreen(machine: machine),
        );

      case '/machine/users':
        final machine = settings.arguments as MachineModel;
        return MaterialPageRoute(
          builder: (_) => MachineUsersScreen(machine: machine),
        );

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('Route not found!'),
            ),
          ),
        );
    }
  }
}

// lib/core/screens/auth_wrapper.dart
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