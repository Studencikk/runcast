import 'package:hive/hive.dart';

part 'route_model.g.dart';

@HiveType(typeId: 0)
class RunRoute extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  double distanceKm;

  @HiveField(2)
  bool isShelteredFromWind;

  @HiveField(3)
  bool isShaded;

  @HiveField(4)
  bool isAsphalt;

  @HiveField(5)
  bool isForest;

  @HiveField(6)
  bool isUrban;

  RunRoute({
    required this.name,
    required this.distanceKm,
    this.isShelteredFromWind = false,
    this.isShaded = false,
    this.isAsphalt = false,
    this.isForest = false,
    this.isUrban = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'distanceKm': distanceKm,
      'isShelteredFromWind': isShelteredFromWind,
      'isShaded': isShaded,
      'isAsphalt': isAsphalt,
      'isForest': isForest,
      'isUrban': isUrban,
    };
  }

  factory RunRoute.fromMap(Map<String, dynamic> map) {
    return RunRoute(
      name: map['name'],
      distanceKm: map['distanceKm'],
      isShelteredFromWind: map['isShelteredFromWind'] ?? false,
      isShaded: map['isShaded'] ?? false,
      isAsphalt: map['isAsphalt'] ?? false,
      isForest: map['isForest'] ?? false,
      isUrban: map['isUrban'] ?? false,
    );
  }
}
