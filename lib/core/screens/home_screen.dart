import 'package:atomicoat_17th_version/features/shared/widgets/main_drawer.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      drawer: MainDrawer(),
      body: const Center(
        child: Text('Welcome to Atomicoat'),
      ),
    );
  }
}