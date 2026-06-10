import 'package:flutter/material.dart';

// Ekran tras
class RoutesScreen extends StatelessWidget {
  final double avgWindSpeed;
  final double avgTemperature;

  const RoutesScreen({
    super.key,
    this.avgWindSpeed = 0,
    this.avgTemperature = 15,
  });

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF0F0F0F),
      body: Center(
        child: Text('Trasy', style: TextStyle(color: Colors.white54)),
      ),
    );
  }
}
