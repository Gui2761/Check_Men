import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/exam.dart';

class UserExamsProvider with ChangeNotifier {
  String? _userId;
  Box<ExamDay>? _userExamsBox;
  Box<Exam>? _examsBox; // <--- NOVA BOX PARA EXAMS INDIVIDUAIS

  final List<String> meses = [
    'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho', 
    'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro',
  ];

  Map<String, List<ExamDay>> _cachedExams = {};

  Future<void> initializeForUser(String? userId) async {
    if (userId == null || userId.isEmpty) {
      _userId = null;
      await _userExamsBox?.close();
      _userExamsBox = null;
      await _examsBox?.close(); // Fechar a nova box de exames
      _examsBox = null;
      _cachedExams = {};
      notifyListeners();
      return;
    }

    if (_userId != userId || 
        (_userExamsBox != null && !_userExamsBox!.isOpen) || 
        (_examsBox != null && !_examsBox!.isOpen)) { // Verifica a nova box
      
      if (_userExamsBox != null && _userExamsBox!.isOpen) {
        await _userExamsBox!.close();
      }
      if (_examsBox != null && _examsBox!.isOpen) { // Fechar a nova box de exames
        await _examsBox!.close();
      }

      _userId = userId;
      final userExamsBoxName = 'user_exams_$userId';
      _userExamsBox = await Hive.openBox<ExamDay>(userExamsBoxName);
      _examsBox = await Hive.openBox<Exam>('exams_box'); // <--- ABRIR A NOVA BOX AQUI

      _loadExamsFromHive();
      notifyListeners();
    }
  }

  void _loadExamsFromHive() {
    _cachedExams = {};
    if (_userExamsBox == null || _examsBox == null) return; // Verificar a nova box
    
    for (String month in meses) {
      final List<ExamDay> monthExams = [];
      // Iterar sobre os valores e filtrar pelo mês (se a chave do ExamDay for 'dia-mes')
      _userExamsBox!.values.forEach((examDay) {
        final keyForDay = '${examDay.day}-$month';
        if (_userExamsBox!.containsKey(keyForDay)) { // Verifica se esta ExamDay pertence a esta month string
           monthExams.add(examDay);
        }
      });
      monthExams.sort((a, b) => a.day.compareTo(b.day));
      _cachedExams[month] = monthExams;
    }
  }

  int monthToNumber(String monthName) {
    return meses.indexOf(monthName) + 1;
  }

  List<ExamDay> getExamsForMonth(String month) {
    return _cachedExams[month] ?? [];
  }

  void addExam(String month, int day, String name, String observation, String recorrencia) {
    if (_userExamsBox == null || _examsBox == null) return; // Verificar a nova box

    final key = '$day-$month';
    ExamDay? examDay = _userExamsBox!.get(key);
    
    final newExam = Exam(nome: name, observacao: observation, recorrencia: recorrencia);
    // IMPORTANTE: Adicione o newExam à Box<Exam> primeiro!
    _examsBox!.add(newExam); // Adiciona e atribui uma chave automática ao Exam

    if (examDay == null) {
      examDay = ExamDay(day: day, exams: HiveList(_examsBox!)); // <--- HiveList agora referencia a `_examsBox`
      examDay.exams.add(newExam);
      _userExamsBox!.put(key, examDay);
    } else {
      examDay.exams.add(newExam);
      examDay.save();
    }
    _loadExamsFromHive();
    notifyListeners();
  }

  void updateExam(String month, int oldDay, int examIndex, Exam updatedExam, int newDay) {
    if (_userExamsBox == null || _examsBox == null) return; // Verificar a nova box

    if (oldDay != newDay) {
      removeExam(month, oldDay, examIndex);
      addExam(month, newDay, updatedExam.nome, updatedExam.observacao, updatedExam.recorrencia);
    } else {
      final key = '$oldDay-$month';
      final examDay = _userExamsBox!.get(key);
      if (examDay != null && examIndex < examDay.exams.length) {
        final existingExam = examDay.exams[examIndex];
        // Atualiza as propriedades do objeto existente
        existingExam.nome = updatedExam.nome;
        existingExam.observacao = updatedExam.observacao;
        existingExam.recorrencia = updatedExam.recorrencia;
        existingExam.concluido = updatedExam.concluido;
        
        existingExam.save(); // <--- Salvar o Exam individualmente, pois ele está em `_examsBox`
        examDay.save(); // Salvar o ExamDay também para garantir que as referências estejam OK.
        notifyListeners();
      }
    }
  }

  void removeExam(String month, int day, int examIndex) {
    if (_userExamsBox == null || _examsBox == null) return; // Verificar a nova box

    final key = '$day-$month';
    final examDay = _userExamsBox!.get(key);
    if (examDay != null && examIndex < examDay.exams.length) {
      final examToRemove = examDay.exams[examIndex];
      examDay.exams.removeAt(examIndex);
      examToRemove.delete(); // <--- EXCLUIR O EXAM DA SUA PRÓPRIA BOX
      
      if (examDay.exams.isEmpty) {
        _userExamsBox!.delete(key);
      } else {
        examDay.save();
      }
      _loadExamsFromHive();
      notifyListeners();
    }
  }

  void toggleExamCompletion(String month, int day, int examIndex) {
    if (_userExamsBox == null || _examsBox == null) return; // Verificar a nova box

    final key = '$day-$month';
    final examDay = _userExamsBox!.get(key);
    if (examDay != null && examIndex < examDay.exams.length) {
      final exam = examDay.exams[examIndex];
      exam.concluido = !exam.concluido;
      exam.save(); // <--- Salvar o Exam individualmente
      // examDay.save(); // Não é estritamente necessário se o ExamDay não mudou, mas pode ser redundante e seguro.
      notifyListeners();
    }
  }

  Future<void> closeUserBox() async {
    _userId = null;
    _cachedExams = {};
    await _userExamsBox?.close();
    _userExamsBox = null;
    await _examsBox?.close(); // Fechar a nova box de exames
    _examsBox = null;
    notifyListeners();
  }
}