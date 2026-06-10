import 'package:flutter/material.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import '../services/weather_service.dart';
import 'details_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final WeatherService _weatherService = WeatherService();
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  Future<WeatherData>? _weatherFuture;

  @override
  void initState() {
    super.initState();
    _weatherFuture = _weatherService.fetchAll();
  }

  Future<void> _refresh() async {
    await _analytics.logEvent(name: 'manual_refresh');
    setState(() {
      _weatherFuture = _weatherService.fetchAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F0F0F),
        elevation: 0,
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFF00E676),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.directions_run, color: Colors.black, size: 20),
            ),
            const SizedBox(width: 8),
            RichText(
              text: const TextSpan(
                children: [
                  TextSpan(
                    text: 'Run',
                    style: TextStyle(
                      color: Color(0xFF00E676),
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text: 'Cast',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              children: [
                Icon(Icons.location_on, color: Color(0xFF00E676), size: 14),
                SizedBox(width: 4),
                Text(
                  'Kraków',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
      body: FutureBuilder<WeatherData>(
        future: _weatherFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF00E676)),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.wifi_off, color: Colors.white38, size: 64),
                    const SizedBox(height: 16),
                    const Text(
                      'Nie udało się pobrać danych pogodowych.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Sprawdź połączenie z internetem.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white38, fontSize: 14),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _refresh,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00E676),
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Spróbuj ponownie'),
                    ),
                  ],
                ),
              ),
            );
          }

          final data = snapshot.data!;

          return RefreshIndicator(
            onRefresh: _refresh,
            color: const Color(0xFF00E676),
            backgroundColor: const Color(0xFF1E1E1E),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text(
                  'Kiedy rozpocząć bieg?',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Wybierz optymalne okno treningowe',
                  style: TextStyle(color: Colors.white54, fontSize: 14),
                ),
                const SizedBox(height: 24),
                _TrainingWindowCard(
                  label: 'RANO',
                  timeRange: '6:00 – 12:00',
                  startHour: 6,
                  endHour: 12,
                  icon: Icons.wb_sunny,
                  iconColor: const Color(0xFFFFB300),
                  data: data,
                  onTap: () => _navigateToDetails(context, 'Rano', 6, 12, data),
                ),
                const SizedBox(height: 12),
                _TrainingWindowCard(
                  label: 'POPOŁUDNIE',
                  timeRange: '12:00 – 18:00',
                  startHour: 12,
                  endHour: 18,
                  icon: Icons.cloud,
                  iconColor: const Color(0xFF90CAF9),
                  data: data,
                  onTap: () => _navigateToDetails(context, 'Popołudnie', 12, 18, data),
                ),
                const SizedBox(height: 12),
                _TrainingWindowCard(
                  label: 'WIECZÓR',
                  timeRange: '18:00 – 23:00',
                  startHour: 18,
                  endHour: 23,
                  icon: Icons.nights_stay,
                  iconColor: const Color(0xFF7E57C2),
                  data: data,
                  onTap: () => _navigateToDetails(context, 'Wieczór', 18, 23, data),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _navigateToDetails(
    BuildContext context,
    String windowName,
    int startHour,
    int endHour,
    WeatherData data,
  ) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => DetailsScreen(
          windowName: windowName,
          startHour: startHour,
          endHour: endHour,
          weatherData: data,
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
}

class _TrainingWindowCard extends StatelessWidget {
  final String label;
  final String timeRange;
  final int startHour;
  final int endHour;
  final IconData icon;
  final Color iconColor;
  final WeatherData data;
  final VoidCallback onTap;

  const _TrainingWindowCard({
    required this.label,
    required this.timeRange,
    required this.startHour,
    required this.endHour,
    required this.icon,
    required this.iconColor,
    required this.data,
    required this.onTap,
  });

  Color _comfortColor(int score) {
    if (score >= 80) return const Color(0xFF00E676);
    if (score >= 60) return const Color(0xFFFFB300);
    return const Color(0xFFEF5350);
  }

  String _comfortBadge(int score) {
    if (score >= 80) return 'Świetnie';
    if (score >= 60) return 'OK';
    return 'Słabo';
  }

  Widget _comfortIcon(int score) {
    if (score >= 80) {
      return const Icon(Icons.thumb_up, color: Color(0xFF00E676), size: 20);
    }
    if (score >= 60) {
      return const Icon(Icons.warning_amber, color: Color(0xFFFFB300), size: 20);
    }
    return const Icon(Icons.warning, color: Color(0xFFEF5350), size: 20);
  }

  @override
  Widget build(BuildContext context) {
    final score = data.calculateComfort(startHour, endHour);
    final hours = data.getWindowHours(startHour, endHour);

    double avgTemp = 0;
    if (hours.isNotEmpty) {
      avgTemp = hours.map((h) => h.temperature).reduce((a, b) => a + b) / hours.length;
    }

    final Color comfortColor = _comfortColor(score);
    final String descLabel = data.comfortLabel(score);

    String subtitleText = '${avgTemp.toStringAsFixed(0)}°C śr.';
    final hours20 = hours.where((h) => h.windSpeed >= 20).toList();
    if (hours20.isNotEmpty) {
      final avgWind = hours.map((h) => h.windSpeed).reduce((a, b) => a + b) / hours.length;
      subtitleText = 'Silny wiatr ${avgWind.toStringAsFixed(0)} km/h';
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: comfortColor.withValues(alpha: 0.25),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: iconColor, size: 28),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      timeRange,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '$score%',
                      style: TextStyle(
                        color: comfortColor,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    _comfortIcon(score),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(color: Colors.white12, height: 1),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  descLabel,
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: comfortColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: comfortColor.withValues(alpha: 0.4)),
                  ),
                  child: Text(
                    _comfortBadge(score),
                    style: TextStyle(
                      color: comfortColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              subtitleText,
              style: const TextStyle(color: Colors.white38, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
