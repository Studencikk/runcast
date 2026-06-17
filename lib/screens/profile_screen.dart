import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import '../models/route_model.dart';

// Ekran profilu
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Box _profileBox;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _goalController = TextEditingController();
  double _weeklyGoalKm = 20;
  double _weeklyProgressKm = 0;

  @override
  void initState() {
    super.initState();
    _profileBox = Hive.box('profile');
    _loadProfile();
  }

  void _loadProfile() {
    _nameController.text = _profileBox.get('name', defaultValue: '');
    _weeklyGoalKm = _profileBox.get('weeklyGoalKm', defaultValue: 20.0).toDouble();
    _goalController.text = _weeklyGoalKm.toStringAsFixed(0);
    _checkWeekReset();
    _weeklyProgressKm = _profileBox.get('weeklyProgressKm', defaultValue: 0.0).toDouble();
  }

  // Reset tygodniowy
  void _checkWeekReset() {
    final lastReset = _profileBox.get('weekStart');
    final now = DateTime.now();
    if (lastReset == null) {
      _profileBox.put('weekStart', now.toIso8601String());
      return;
    }
    final lastDate = DateTime.parse(lastReset);
    if (now.difference(lastDate).inDays >= 7) {
      _profileBox.put('weekStart', now.toIso8601String());
      _profileBox.put('weeklyProgressKm', 0.0);
    }
  }

  // Poziom zaawansowania
  String get _level {
    if (_weeklyGoalKm < 25) return 'Początkujący';
    if (_weeklyGoalKm <= 60) return 'Średniozaaw.';
    return 'Zaawansowany';
  }

  void _addProgress(double km) {
    setState(() {
      _weeklyProgressKm = (_weeklyProgressKm + km).clamp(0, double.infinity);
    });
    _profileBox.put('weeklyProgressKm', _weeklyProgressKm);
  }

  // Aktualizacja celu
  void _updateGoalFromInput(String value) {
    final parsed = double.tryParse(value);
    if (parsed != null && parsed >= 0) {
      setState(() => _weeklyGoalKm = parsed);
    }
  }

  Future<void> _saveProfile() async {
    await _profileBox.put('name', _nameController.text.trim());
    await _profileBox.put('weeklyGoalKm', _weeklyGoalKm);

    await FirebaseAnalytics.instance.logEvent(name: 'save_profile');

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profil zapisany!', style: TextStyle(color: Colors.white)),
          backgroundColor: Color(0xFF1E1E1E),
        ),
      );
    }
  }

  // Najczęściej wybierana pora dnia
  String _favoriteTime() {
    final counts = Map<String, int>.from(
      _profileBox.get('windowCounts', defaultValue: <String, int>{}),
    );
    if (counts.isEmpty) return 'Brak danych';
    final sorted = counts.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    return sorted.first.key;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _goalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final savedRouteCount = Hive.box<RunRoute>('routes').length;
    final progressRatio = _weeklyGoalKm > 0 ? (_weeklyProgressKm / _weeklyGoalKm).clamp(0.0, 1.0) : 0.0;

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F0F0F),
        elevation: 0,
        title: const Text(
          'Mój Profil',
          style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Avatar
          Center(
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: const Color(0xFF00E676),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF00E676).withValues(alpha: 0.3), width: 4),
              ),
              child: const Icon(Icons.directions_run, color: Colors.black, size: 56),
            ),
          ),

          const SizedBox(height: 24),

          // Imię
          const Text(
            'IMIĘ',
            style: TextStyle(color: Colors.white38, fontSize: 11, letterSpacing: 1.5, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(color: const Color(0xFF1A1A1A), borderRadius: BorderRadius.circular(12)),
            child: TextField(
              controller: _nameController,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              decoration: const InputDecoration(
                hintText: 'Jan',
                hintStyle: TextStyle(color: Colors.white24),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
          ),

          const SizedBox(height: 20),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(color: const Color(0xFF1A1A1A), borderRadius: BorderRadius.circular(12)),
            child: Row(
              children: [
                const Icon(Icons.military_tech, color: Color(0xFFFFB300), size: 20),
                const SizedBox(width: 10),
                const Text('Poziom', style: TextStyle(color: Colors.white70, fontSize: 14)),
                const Spacer(),
                Text(_level, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Cel tygodniowy
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: const Color(0xFF1A1A1A), borderRadius: BorderRadius.circular(16)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.flag_circle, color: Color(0xFFFF6B35), size: 20),
                    const SizedBox(width: 8),
                    const Text('Cel Tygodniowy',
                        style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                    const Spacer(),
                    SizedBox(
                      width: 70,
                      child: TextField(
                        controller: _goalController,
                        textAlign: TextAlign.right,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(
                          color: Color(0xFF00E676),
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: const InputDecoration(
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                          border: InputBorder.none,
                          suffixText: ' km',
                          suffixStyle: TextStyle(color: Color(0xFF00E676), fontSize: 14),
                        ),
                        onChanged: _updateGoalFromInput,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),
                // Pasek progresu
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progressRatio,
                    minHeight: 8,
                    backgroundColor: Colors.white12,
                    color: const Color(0xFF00E676),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${_weeklyProgressKm.toStringAsFixed(0)} / ${_weeklyGoalKm.toStringAsFixed(0)} km',
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),

                const SizedBox(height: 14),
                const Text('Dodaj przebiegnięte km:', style: TextStyle(color: Colors.white38, fontSize: 12)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _ProgressButton(label: '-5', onTap: () => _addProgress(-5)),
                    const SizedBox(width: 8),
                    _ProgressButton(label: '-1', onTap: () => _addProgress(-1)),
                    const SizedBox(width: 8),
                    _ProgressButton(label: '+1', onTap: () => _addProgress(1)),
                    const SizedBox(width: 8),
                    _ProgressButton(label: '+5', onTap: () => _addProgress(5)),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Statystyki
          Row(
            children: [
              Expanded(child: _StatCard(value: '$savedRouteCount', label: 'Trasy')),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  value: _favoriteTime(),
                  label: 'Ulubiony czas',
                  valueColor: const Color(0xFFFFB300),
                  icon: Icons.wb_sunny,
                ),
              ),
            ],
          ),

          const SizedBox(height: 28),

          ElevatedButton.icon(
            onPressed: _saveProfile,
            icon: const Icon(Icons.save, size: 20),
            label: const Text('Zapisz Profil', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00E676),
              foregroundColor: Colors.black,
              minimumSize: const Size(double.infinity, 54),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),

          const SizedBox(height: 12),
          const Center(
            child: Text('Dane zapisane lokalnie', style: TextStyle(color: Colors.white24, fontSize: 12)),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _ProgressButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _ProgressButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF252525),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white12),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final Color valueColor;
  final IconData? icon;

  const _StatCard({
    required this.value,
    required this.label,
    this.valueColor = Colors.white,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFF1A1A1A), borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, color: valueColor, size: 16),
                const SizedBox(width: 4),
              ],
              Text(value, style: TextStyle(color: valueColor, fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: Colors.white38, fontSize: 13)),
        ],
      ),
    );
  }
}