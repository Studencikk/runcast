// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'route_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RunRouteAdapter extends TypeAdapter<RunRoute> {
  @override
  final int typeId = 0;

  @override
  RunRoute read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RunRoute(
      name: fields[0] as String,
      distanceKm: fields[1] as double,
      isShelteredFromWind: fields[2] as bool,
      isShaded: fields[3] as bool,
      isAsphalt: fields[4] as bool,
      isForest: fields[5] as bool,
      isUrban: fields[6] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, RunRoute obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.distanceKm)
      ..writeByte(2)
      ..write(obj.isShelteredFromWind)
      ..writeByte(3)
      ..write(obj.isShaded)
      ..writeByte(4)
      ..write(obj.isAsphalt)
      ..writeByte(5)
      ..write(obj.isForest)
      ..writeByte(6)
      ..write(obj.isUrban);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RunRouteAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
