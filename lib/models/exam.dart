import 'package:hive/hive.dart';

part 'exam.g.dart';

@HiveType(typeId: 0)
class Exam extends HiveObject { // DEVE SER HiveObject
  @HiveField(0)
  String nome;

  @HiveField(1)
  String observacao;

  @HiveField(2)
  String recorrencia;

  @HiveField(3)
  bool concluido;

  Exam({
    required this.nome,
    this.observacao = '',
    this.recorrencia = 'Mensal',
    this.concluido = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'observacao': observacao,
      'recorrencia': recorrencia,
      'concluido': concluido,
    };
  }
}

@HiveType(typeId: 1)
class ExamDay extends HiveObject { // DEVE SER HiveObject
  @HiveField(0)
  int day;

  @HiveField(1)
  HiveList<Exam> exams; // Ainda um HiveList

  ExamDay({
    required this.day,
    required this.exams,
  });
}