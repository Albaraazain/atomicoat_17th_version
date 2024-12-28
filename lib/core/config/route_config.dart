// lib/core/config/route_config.dart
import 'package:atomicoat_17th_version/core/screens/auth_wrapper.dart';
import 'package:atomicoat_17th_version/features/auth/screens/login_screen.dart';
import 'package:atomicoat_17th_version/features/auth/screens/profile_screen.dart';
import 'package:atomicoat_17th_version/features/auth/screens/registration_screen.dart';
import 'package:atomicoat_17th_version/features/machine/data/models/machine_model.dart';
import 'package:atomicoat_17th_version/features/machine/screens/machine_details_screen.dart';
import 'package:atomicoat_17th_version/features/machine/screens/machine_list_screen.dart';
import 'package:atomicoat_17th_version/features/machine/screens/machine_users_screen.dart';
import 'package:flutter/material.dart';

class RouteConfig {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
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

      case '/profile':
        return MaterialPageRoute(
          builder: (_) => ProfileScreen(),
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


