import 'package:flutter/material.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:hive/hive.dart';
import '../services/weather_service.dart';
import 'routes_screen.dart';

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

  String _formatHour(int h) => h.toString().padLeft(2, '0');

  String _buildOutfitAdvice(List<HourlyWeather> hours) {
    if (hours.isEmpty) return 'Brak danych pogodowych.';

    final avgTemp = hours.map((h) => h.temperature).reduce((a, b) => a + b) / hours.length;
    final avgWind = hours.map((h) => h.windSpeed).reduce((a, b) => a + b) / hours.length;
    final avgPrecip = hours.map((h) => h.precipitation).reduce((a, b) => a + b) / hours.length;

    if (avgTemp < 5) return 'Spodnie termiczne + kurtka biegowa + rękawiczki + czapka';
    if (avgTemp < 10) {
      if (avgPrecip >= 0.5) return 'Kurtka przeciwdeszczowa + długie spodnie + bluza';
      return 'Długie spodnie + bluza z kapturem';
    }
    if (avgTemp < 15) {
      if (avgPrecip >= 0.5) return 'Kurtka przeciwdeszczowa + długie spodnie';
      if (avgWind >= 20) return 'Długie spodnie + koszulka z długim rękawem + wiatrówka';
      return 'Długie spodnie + koszulka z długim rękawem';
    }
    if (avgTemp < 20) {
      if (avgPrecip >= 0.5) return 'Kurtka przeciwdeszczowa + krótkie spodenki';
      if (avgWind >= 20) return 'Krótkie spodenki + koszulka z długim rękawem + wiatrówka';
      return 'Krótkie spodenki + koszulka z długim rękawem';
    }
    if (avgTemp < 25) {
      if (avgPrecip >= 0.5) return 'Kurtka przeciwdeszczowa + krótkie spodenki';
      if (avgWind >= 20) return 'Krótkie spodenki + koszulka z krótkim rękawem + wiatrówka';
      return 'Krótkie spodenki + koszulka z krótkim rękawem';
    }
    if (avgPrecip >= 0.5) return 'Kurtka przeciwdeszczowa + krótkie spodenki';
    if (avgWind >= 25) return 'Krótkie spodenki + koszulka z krótkim rękawem + wiatrówka';
    return 'Krótkie spodenki + koszulka z krótkim rękawem + czapka z daszkiem';
  }

  Color _airQualityColor(String label) {
    switch (label) {
      case 'Dobry':
        return const Color(0xFF00E676);
      case 'Umiarkowany':
        return const Color(0xFFFFB300);
      default:
        return const Color(0xFFEF5350);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hours = weatherData.getWindowHours(startHour, endHour);
    final outfitAdvice = _buildOutfitAdvice(hours);
    final airLabel = weatherData.airQuality.label;
    final airColor = _airQualityColor(airLabel);

    final currentHour = weatherData.getCurrentHour();
    final currentWind = currentHour?.windSpeed ?? 0;
    final currentTemp = currentHour?.temperature ?? 15;
    final currentRainLabel = currentHour?.rainLabel ?? 'Brak';
    final now = DateTime.now().hour;

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F0F0F),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$windowName ${_formatHour(startHour)}:00–${_formatHour(endHour)}:00',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
              ),
            ),
            const Text(
              'Szczegóły warunków treningowych',
              style: TextStyle(color: Color(0xFFFFB300), fontSize: 12),
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
              'PROGNOZA GODZINOWA',
              style: TextStyle(
                  color: Colors.white54,
                  fontSize: 12,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.w600,
              ),
          ),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(
                    children: const [
                      SizedBox(width: 50, child: Text('GODZ.', style: TextStyle(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.w600))),
                      Expanded(child: Text('TEMP', style: TextStyle(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.w600))),
                      Expanded(child: Text('WIATR', style: TextStyle(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.w600))),
                      Expanded(child: Text('OPADY', style: TextStyle(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.w600))),
                    ],
                  ),
                ),
                const Divider(color: Colors.white12, height: 1),
                ...hours.asMap().entries.map((entry) {
                  final h = entry.value;
                  final isEven = entry.key % 2 == 0;
                  return Container(
                    color: isEven ? Colors.transparent : Colors.white.withValues(alpha: 0.02),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 50,
                          child: Text(
                              '${_formatHour(h.hour)}:00',
                              style: const TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500),
                          ),
                        ),
                        Expanded(
                            child: Row(children: [
                              const Icon(Icons.thermostat, color: Color(0xFFEF5350), size: 14),
                              const SizedBox(width: 4),
                              Text('${h.temperature.toStringAsFixed(0)}°C', style: const TextStyle(color: Colors.white, fontSize: 14)),
                        ]),
                        ),
                        Expanded(
                            child: Row(children: [
                              const Icon(Icons.air, color: Color(0xFF90CAF9), size: 14),
                              const SizedBox(width: 4),
                              Text('${h.windSpeed.toStringAsFixed(0)} km/h', style: const TextStyle(color: Colors.white, fontSize: 14)),
                        ]),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                h.rainLabel,
                                style: TextStyle(
                                  color: h.isRaining ? Colors.white : Colors.white38,
                                  fontSize: 13,
                                ),
                              ),
                              if (h.isRaining)
                                Text(
                                  '${h.precipitationProbability}% szansy',
                                  style: const TextStyle(color: Colors.white38, fontSize: 11),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),

          const SizedBox(height: 20),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(Icons.air_outlined, color: Colors.white54, size: 22),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                        'Jakość Powietrza',
                        style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    Text(
                        'PM2.5: ${weatherData.airQuality.pm25.toStringAsFixed(1)} µg/m³',
                        style: const TextStyle(color: Colors.white54, fontSize: 13),
                    ),
                  ],
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: airColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: airColor.withValues(alpha: 0.5)),
                  ),
                  child: Text(
                      airLabel.toUpperCase(),
                      style: TextStyle(
                          color: airColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                      ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF00E676).withValues(alpha: 0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                    'REKOMENDACJA',
                    style: TextStyle(
                        color: Color(0xFF00E676),
                        fontSize: 11,
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.w600,
                    ),
                ),
                const SizedBox(height: 10),
                const Row(
                  children: [
                    Icon(Icons.checkroom, color: Colors.white70, size: 20),
                    SizedBox(width: 8),
                    Text(
                        'Jak się ubrać?',
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                    outfitAdvice,
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          ElevatedButton(
            onPressed: () async {
              await FirebaseAnalytics.instance.logEvent(name: 'route_selected');
              final profileBox = Hive.box('profile');
              final counts = Map<String, int>.from(
                profileBox.get('windowCounts', defaultValue: <String, int>{}),
              );
              counts[windowName] = (counts[windowName] ?? 0) + 1;
              await profileBox.put('windowCounts', counts);
              if (context.mounted) {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) => RoutesScreen(
                      currentWindSpeed: currentWind,
                      currentTemperature: currentTemp,
                      currentRainLabel: currentRainLabel,
                      currentHourLabel: now,
                      fromDetails: true,
                    ),
                    transitionsBuilder: (context, animation, secondaryAnimation, child) {
                      return SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(1.0, 0.0),
                          end: Offset.zero,
                        ).animate(CurvedAnimation(parent: animation, curve: Curves.easeInOut)),
                        child: child,
                      );
                    },
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00E676),
              foregroundColor: Colors.black,
              minimumSize: const Size(double.infinity, 54),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: const Text(
                'Wybierz trasę pod aktualne warunki',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}