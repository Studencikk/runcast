import 'package:flutter/material.dart';

// Ekran profilu
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF0F0F0F),
      body: Center(
        child: Text('Profil', style: TextStyle(color: Colors.white54)),
      ),
    );
  }
}
