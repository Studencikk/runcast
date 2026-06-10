import 'package:flutter/material.dart';
import '../services/weather_service.dart';

// Ekran szczegółów
class DetailsScreen extends StatelessWidget {
  final String windowName;
  final int startHour;
  final int endHour;
  final WeatherData weatherData;

  const DetailsScreen({
    super.key,
    required this.windowName,
    required this.startHour,
    required this.endHour,
    required this.weatherData,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F0F0F),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          windowName,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: const Center(
        child: Text('Szczegóły', style: TextStyle(color: Colors.white54)),
      ),
    );
  }
}
