// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vocab_local.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class VocabLocalAdapter extends TypeAdapter<VocabLocal> {
  @override
  final typeId = 0;

  @override
  VocabLocal read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return VocabLocal(
      id: fields[0] as String,
      deckId: fields[1] as String,
      word: fields[2] as String,
      meaning: fields[3] as String,
      example: fields[4] as String?,
      imageUrl: fields[5] as String?,
      audioUrl: fields[6] as String?,
      easinessFactor: (fields[7] as num).toDouble(),
      interval: (fields[8] as num).toInt(),
      repetition: (fields[9] as num).toInt(),
      nextReview: fields[10] as DateTime,
      createdAt: fields[11] as DateTime,
      updatedAt: fields[12] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, VocabLocal obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.deckId)
      ..writeByte(2)
      ..write(obj.word)
      ..writeByte(3)
      ..write(obj.meaning)
      ..writeByte(4)
      ..write(obj.example)
      ..writeByte(5)
      ..write(obj.imageUrl)
      ..writeByte(6)
      ..write(obj.audioUrl)
      ..writeByte(7)
      ..write(obj.easinessFactor)
      ..writeByte(8)
      ..write(obj.interval)
      ..writeByte(9)
      ..write(obj.repetition)
      ..writeByte(10)
      ..write(obj.nextReview)
      ..writeByte(11)
      ..write(obj.createdAt)
      ..writeByte(12)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VocabLocalAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
