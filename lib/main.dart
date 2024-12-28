// lib/main.dart
import 'package:atomicoat_17th_version/app.dart';
import 'package:atomicoat_17th_version/features/auth/data/repositories/auth_repository.dart';
import 'package:atomicoat_17th_version/features/auth/providers/auth_provider.dart';
import 'package:atomicoat_17th_version/features/machine/data/repositories/machine_repository.dart';
import 'package:atomicoat_17th_version/features/machine/providers/machine_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(AuthRepository()),
        ),
        ChangeNotifierProxyProvider<AuthProvider, MachineProvider>(
          create: (context) => MachineProvider(
            MachineRepository(FirebaseFirestore.instance),
            context.read<AuthProvider>(),
          ),
          update: (context, authProvider, previous) => MachineProvider(
            MachineRepository(FirebaseFirestore.instance),
            authProvider,
          ),
        ),
      ],
      child: MyApp(),
    ),
  );
}