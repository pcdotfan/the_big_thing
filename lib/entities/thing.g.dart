// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'thing.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ThingAdapter extends TypeAdapter<Thing> {
  @override
  final int typeId = 1;

  @override
  Thing read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Thing(
      fields[0] as String,
      fields[1] as String,
      fields[2] as int,
      fields[3] as DateTime,
      fields[4] as bool,
      fields[5] as int,
      audioPath: fields[6] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Thing obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.content)
      ..writeByte(2)
      ..write(obj.color)
      ..writeByte(3)
      ..write(obj.dueDate)
      ..writeByte(4)
      ..write(obj.sticky)
      ..writeByte(5)
      ..write(obj.folderId)
      ..writeByte(6)
      ..write(obj.audioPath);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ThingAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
