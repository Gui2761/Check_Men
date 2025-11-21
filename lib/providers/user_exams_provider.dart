import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/exam.dart';

class UserExamsProvider with ChangeNotifier {
  String? _userId;
  Box<ExamDay>? _userExamsBox;
  Box<Exam>? _examsBox;

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
      await _examsBox?.close();
      _examsBox = null;
      _cachedExams = {};
      notifyListeners();
      return;
    }

    if (_userId != userId || 
        (_userExamsBox != null && !_userExamsBox!.isOpen) || 
        (_examsBox != null && !_examsBox!.isOpen)) {
      
      if (_userExamsBox != null && _userExamsBox!.isOpen) {
        await _userExamsBox!.close();
      }
      if (_examsBox != null && _examsBox!.isOpen) {
        await _examsBox!.close();
      }

      _userId = userId;
      final userExamsBoxName = 'user_exams_$userId';
      _userExamsBox = await Hive.openBox<ExamDay>(userExamsBoxName);
      _examsBox = await Hive.openBox<Exam>('exams_box');

      _loadExamsFromHive();
      notifyListeners();
    }
  }

  void _loadExamsFromHive() {
    _cachedExams = {};
    if (_userExamsBox == null || _examsBox == null) return;
    
    for (String month in meses) {
      _cachedExams[month] = [];
    }

    for (var key in _userExamsBox!.keys) {
      if (key is String) {
        final parts = key.split('-');
        if (parts.length == 2) {
          final day = int.tryParse(parts[0]);
          final month = parts[1];
          
          if (day != null && meses.contains(month)) {
            final examDay = _userExamsBox!.get(key);
            if (examDay != null) {
              _cachedExams[month]?.add(examDay);
            }
          }
        }
      }
    }

    for (String month in meses) {
      _cachedExams[month]?.sort((a, b) => a.day.compareTo(b.day));
    }
  }

  int monthToNumber(String monthName) {
    return meses.indexOf(monthName) + 1;
  }

  List<ExamDay> getExamsForMonth(String month) {
    return _cachedExams[month] ?? [];
  }

  // 🟢 ATUALIZADO: Removemos o argumento 'recorrencia'
  void addExam(String month, int day, String name, String observation) {
    if (_userExamsBox == null || _examsBox == null) return;

    final key = '$day-$month';
    ExamDay? examDay = _userExamsBox!.get(key);
    
    // Passamos "Padrão" fixo para manter compatibilidade com o banco de dados
    final newExam = Exam(nome: name, observacao: observation, recorrencia: "Padrão");
    _examsBox!.add(newExam); 

    if (examDay == null) {
      examDay = ExamDay(day: day, exams: HiveList(_examsBox!)); 
      examDay.exams.add(newExam);
      _userExamsBox!.put(key, examDay);
    } else {
      examDay.exams.add(newExam);
      examDay.save();
    }
    _loadExamsFromHive();
    notifyListeners();
  }

  // 🟢 ATUALIZADO: Removemos a edição de recorrencia
  void updateExam(String month, int oldDay, int examIndex, Exam updatedExam, int newDay) {
    if (_userExamsBox == null || _examsBox == null) return;

    if (oldDay != newDay) {
      removeExam(month, oldDay, examIndex);
      addExam(month, newDay, updatedExam.nome, updatedExam.observacao);
    } else {
      final key = '$oldDay-$month';
      final examDay = _userExamsBox!.get(key);
      if (examDay != null && examIndex < examDay.exams.length) {
        final existingExam = examDay.exams[examIndex];
        existingExam.nome = updatedExam.nome;
        existingExam.observacao = updatedExam.observacao;
        // existingExam.recorrencia = updatedExam.recorrencia; // Ignora atualização disso
        existingExam.concluido = updatedExam.concluido;
        
        existingExam.save();
        examDay.save();
        notifyListeners();
      }
    }
  }

  void removeExam(String month, int day, int examIndex) {
    if (_userExamsBox == null || _examsBox == null) return;

    final key = '$day-$month';
    final examDay = _userExamsBox!.get(key);
    if (examDay != null && examIndex < examDay.exams.length) {
      final examToRemove = examDay.exams[examIndex];
      examDay.exams.removeAt(examIndex);
      examToRemove.delete(); 
      
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
    if (_userExamsBox == null || _examsBox == null) return;

    final key = '$day-$month';
    final examDay = _userExamsBox!.get(key);
    if (examDay != null && examIndex < examDay.exams.length) {
      final exam = examDay.exams[examIndex];
      exam.concluido = !exam.concluido;
      exam.save(); 
      notifyListeners();
    }
  }

  Future<void> closeUserBox() async {
    _userId = null;
    _cachedExams = {};
    await _userExamsBox?.close();
    _userExamsBox = null;
    await _examsBox?.close();
    _examsBox = null;
    notifyListeners();
  }
}