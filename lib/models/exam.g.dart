// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exam.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ExamAdapter extends TypeAdapter<Exam> {
  @override
  final int typeId = 0;

  @override
  Exam read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Exam(
      nome: fields[0] as String,
      observacao: fields[1] as String,
      recorrencia: fields[2] as String,
      concluido: fields[3] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Exam obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.nome)
      ..writeByte(1)
      ..write(obj.observacao)
      ..writeByte(2)
      ..write(obj.recorrencia)
      ..writeByte(3)
      ..write(obj.concluido);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExamAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ExamDayAdapter extends TypeAdapter<ExamDay> {
  @override
  final int typeId = 1;

  @override
  ExamDay read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ExamDay(
      day: fields[0] as int,
      exams: (fields[1] as HiveList).castHiveList(),
    );
  }

  @override
  void write(BinaryWriter writer, ExamDay obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.day)
      ..writeByte(1)
      ..write(obj.exams);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExamDayAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
