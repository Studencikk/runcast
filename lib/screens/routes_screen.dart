import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/route_model.dart';

// Ekran tras
class RoutesScreen extends StatefulWidget {
  final double currentWindSpeed;
  final double currentTemperature;
  final String currentRainLabel;
  final int currentHourLabel;
  final bool fromDetails;

  const RoutesScreen({
    super.key,
    this.currentWindSpeed = 0,
    this.currentTemperature = 15,
    this.currentRainLabel = 'Brak',
    this.currentHourLabel = 0,
    this.fromDetails = false,
  });

  @override
  State<RoutesScreen> createState() => _RoutesScreenState();
}

class _RoutesScreenState extends State<RoutesScreen> {
  late Box<RunRoute> _routesBox;

  @override
  void initState() {
    super.initState();
    _routesBox = Hive.box<RunRoute>('routes');
  }

  bool _isRecommended(RunRoute route) {
    if (widget.currentWindSpeed >= 20 && route.isShelteredFromWind) return true;
    if (widget.currentTemperature >= 25 && route.isShaded) return true;
    return false;
  }

  String _recommendedReason(RunRoute route) {
    if (widget.currentWindSpeed >= 20 && route.isShelteredFromWind) {
      return 'Rekomendowana na ten wiatr';
    }
    if (widget.currentTemperature >= 25 && route.isShaded) {
      return 'Rekomendowana – zacieniona przy upale';
    }
    return '';
  }

  List<String> _buildTags(RunRoute route) {
    final tags = <String>[];
    if (route.isShelteredFromWind) tags.add('Osłonięta');
    if (route.isShaded) tags.add('Zacieniona');
    if (route.isForest) tags.add('Las');
    if (route.isAsphalt) tags.add('Asfalt');
    if (route.isUrban) tags.add('Zabudowana');
    return tags;
  }

  void _showRouteDialog({RunRoute? existing}) {
    final nameController = TextEditingController(text: existing?.name ?? '');
    final distanceController = TextEditingController(
        text: existing != null ? existing.distanceKm.toStringAsFixed(0) : '');
    bool isShelteredFromWind = existing?.isShelteredFromWind ?? false;
    bool isShaded = existing?.isShaded ?? false;
    bool isAsphalt = existing?.isAsphalt ?? false;
    bool isForest = existing?.isForest ?? false;
    bool isUrban = existing?.isUrban ?? false;
    final isEditing = existing != null;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(isEditing ? 'Edytuj trasę' : 'Dodaj nową trasę',
              style: const TextStyle(color: Colors.white)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: nameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Nazwa trasy',
                    labelStyle: const TextStyle(color: Colors.white54),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.white24),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFF00E676)),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: distanceController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Długość (km)',
                    labelStyle: const TextStyle(color: Colors.white54),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.white24),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFF00E676)),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Cechy trasy:', style: TextStyle(color: Colors.white70, fontSize: 13)),
                const SizedBox(height: 4),
                _CheckboxRow(label: 'Osłonięta od wiatru', value: isShelteredFromWind,
                    onChanged: (v) => setDialogState(() => isShelteredFromWind = v!)),
                _CheckboxRow(label: 'Zacieniona', value: isShaded,
                    onChanged: (v) => setDialogState(() => isShaded = v!)),
                _CheckboxRow(label: 'Asfalt', value: isAsphalt,
                    onChanged: (v) => setDialogState(() => isAsphalt = v!)),
                _CheckboxRow(label: 'Las / tereny zielone', value: isForest,
                    onChanged: (v) => setDialogState(() => isForest = v!)),
                _CheckboxRow(label: 'Tereny zabudowane', value: isUrban,
                    onChanged: (v) => setDialogState(() => isUrban = v!)),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Anuluj', style: TextStyle(color: Colors.white54)),
            ),
            ElevatedButton(
              onPressed: () {
                final name = nameController.text.trim();
                final distance = double.tryParse(distanceController.text.trim()) ?? 0;
                if (name.isEmpty || distance <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Podaj nazwę i poprawną odległość.',
                        style: TextStyle(color: Colors.white)),
                    backgroundColor: Color(0xFF1E1E1E),
                  ));
                  return;
                }
                if (isEditing) {
                  existing.name = name;
                  existing.distanceKm = distance;
                  existing.isShelteredFromWind = isShelteredFromWind;
                  existing.isShaded = isShaded;
                  existing.isAsphalt = isAsphalt;
                  existing.isForest = isForest;
                  existing.isUrban = isUrban;
                  existing.save();
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Zaktualizowano: $name',
                        style: const TextStyle(color: Colors.white)),
                    backgroundColor: const Color(0xFF1E1E1E),
                  ));
                } else {
                  _routesBox.add(RunRoute(
                    name: name, distanceKm: distance,
                    isShelteredFromWind: isShelteredFromWind, isShaded: isShaded,
                    isAsphalt: isAsphalt, isForest: isForest, isUrban: isUrban,
                  ));
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Dodano trasę: $name',
                        style: const TextStyle(color: Colors.white)),
                    backgroundColor: const Color(0xFF1E1E1E),
                  ));
                }
                setState(() {});
                Navigator.pop(ctx);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00E676),
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text(isEditing ? 'Zapisz' : 'Dodaj'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final routes = _routesBox.values.toList();

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F0F0F),
        elevation: 0,
        leading: Navigator.canPop(context)
            ? IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        )
            : null,
        title: const Text('Wybierz Trasę',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          // Pasek aktualnych warunków
          if (widget.fromDetails)
            Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A), borderRadius: BorderRadius.circular(12)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Aktualne warunki (${widget.currentHourLabel}:00):',
                    style: const TextStyle(color: Colors.white38, fontSize: 11,
                        letterSpacing: 1, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Row(children: [
                    const Icon(Icons.air, color: Color(0xFF90CAF9), size: 15),
                    const SizedBox(width: 5),
                    Text('${widget.currentWindSpeed.toStringAsFixed(0)} km/h',
                        style: const TextStyle(color: Colors.white70, fontSize: 13)),
                    const SizedBox(width: 14),
                    const Icon(Icons.thermostat, color: Color(0xFFEF5350), size: 15),
                    const SizedBox(width: 5),
                    Text('${widget.currentTemperature.toStringAsFixed(0)}°C',
                        style: const TextStyle(color: Colors.white70, fontSize: 13)),
                    const SizedBox(width: 14),
                    const Icon(Icons.water_drop, color: Color(0xFF7986CB), size: 15),
                    const SizedBox(width: 5),
                    Text(widget.currentRainLabel,
                        style: const TextStyle(color: Colors.white70, fontSize: 13)),
                  ]),
                ],
              ),
            ),

          Expanded(
            child: routes.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.route, color: Colors.white12, size: 64),
                  SizedBox(height: 16),
                  Text('Brak tras.', style: TextStyle(color: Colors.white38, fontSize: 16)),
                  SizedBox(height: 4),
                  Text('Dodaj pierwszą używając przycisku poniżej.',
                      style: TextStyle(color: Colors.white24, fontSize: 13)),
                ],
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              itemCount: routes.length,
              itemBuilder: (context, index) {
                final route = routes[index];
                final recommended = widget.fromDetails && _isRecommended(route);
                final reason = recommended ? _recommendedReason(route) : '';
                final tags = _buildTags(route);

                return Dismissible(
                  key: ValueKey(route.key),
                  // Usuwanie trasy
                  direction: widget.fromDetails
                      ? DismissDirection.none
                      : DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                        color: const Color(0xFFEF5350),
                        borderRadius: BorderRadius.circular(16)),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  confirmDismiss: (_) async {
                    return await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        backgroundColor: const Color(0xFF1E1E1E),
                        title: const Text('Usuń trasę',
                            style: TextStyle(color: Colors.white)),
                        content: Text('Czy na pewno chcesz usunąć "${route.name}"?',
                            style: const TextStyle(color: Colors.white70)),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: const Text('Anuluj',
                                style: TextStyle(color: Colors.white54)),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            child: const Text('Usuń',
                                style: TextStyle(color: Color(0xFFEF5350))),
                          ),
                        ],
                      ),
                    ) ?? false;
                  },
                  onDismissed: (_) {
                    final name = route.name;
                    _routesBox.delete(route.key);
                    setState(() {});
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Usunięto: $name',
                          style: const TextStyle(color: Colors.white)),
                      backgroundColor: const Color(0xFF1E1E1E),
                    ));
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: recommended
                          ? const Color(0xFF00E676).withValues(alpha: 0.08)
                          : const Color(0xFF1A1A1A),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: recommended
                            ? const Color(0xFF00E676).withValues(alpha: 0.5)
                            : Colors.white.withValues(alpha: 0.06),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 40, height: 40,
                              decoration: BoxDecoration(
                                color: route.isForest
                                    ? const Color(0xFF2E7D32).withValues(alpha: 0.3)
                                    : const Color(0xFF1565C0).withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                route.isForest ? Icons.park : Icons.location_city,
                                color: route.isForest
                                    ? const Color(0xFF66BB6A)
                                    : const Color(0xFF64B5F6),
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(route.name,
                                  style: const TextStyle(color: Colors.white,
                                      fontSize: 16, fontWeight: FontWeight.bold)),
                            ),
                            Text('${route.distanceKm.toStringAsFixed(0)} km',
                                style: const TextStyle(color: Colors.white54, fontSize: 13)),
                            // Edycja trasy
                            if (!widget.fromDetails) ...[
                              const SizedBox(width: 10),
                              GestureDetector(
                                onTap: () => _showRouteDialog(existing: route),
                                child: const Icon(Icons.edit_outlined,
                                    color: Colors.white38, size: 18),
                              ),
                            ],
                          ],
                        ),
                        if (tags.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 6, runSpacing: 6,
                            children: tags.map((tag) => Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.07),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(tag,
                                  style: const TextStyle(color: Colors.white54, fontSize: 12)),
                            )).toList(),
                          ),
                        ],
                        if (recommended) ...[
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: const Color(0xFF00E676).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.check_circle,
                                    color: Color(0xFF00E676), size: 14),
                                const SizedBox(width: 6),
                                Text(reason,
                                    style: const TextStyle(color: Color(0xFF00E676),
                                        fontSize: 12, fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Dodawanie trasy
          if (!widget.fromDetails)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              child: OutlinedButton.icon(
                onPressed: () => _showRouteDialog(),
                icon: const Icon(Icons.add, color: Color(0xFF00E676)),
                label: const Text('Dodaj nową trasę',
                    style: TextStyle(color: Color(0xFF00E676), fontWeight: FontWeight.w600)),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  side: const BorderSide(color: Color(0xFF00E676), width: 1),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _CheckboxRow extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool?> onChanged;

  const _CheckboxRow({required this.label, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Checkbox(
          value: value,
          onChanged: onChanged,
          activeColor: const Color(0xFF00E676),
          checkColor: Colors.black,
          side: const BorderSide(color: Colors.white38),
        ),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 14)),
      ],
    );
  }
}