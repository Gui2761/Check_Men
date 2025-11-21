import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../widgets/lembretes/month_selector.dart';
import '../widgets/lembretes/search_bar.dart';
import '../widgets/lembretes/exam_card.dart';
import '../utils/app_extensions.dart'; 
import '../providers/user_exams_provider.dart';
import '../models/exam.dart'; 
import '../services/api_service.dart';
import '../providers/auth_provider.dart';

class LembretesScreen extends StatefulWidget {
  const LembretesScreen({super.key});

  @override
  State<LembretesScreen> createState() => _LembretesScreenState();
}

class _LembretesScreenState extends State<LembretesScreen> {
  final List<String> meses = [
    'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho', 
    'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro',
  ];
  
  final Map<String, int> diasPorMes = {
    'Janeiro': 31, 'Fevereiro': 28, 'Março': 31, 'Abril': 30, 'Maio': 31, 'Junho': 30, 
    'Julho': 31, 'Agosto': 31, 'Setembro': 30, 'Outubro': 31, 'Novembro': 30, 'Dezembro': 31,
  };

  String mesAtual = 'Fevereiro'; 
  String termoDePesquisa = '';

  @override
  void initState() {
    super.initState();
    mesAtual = DateFormat('MMMM', 'pt_BR').format(DateTime.now()).capitalize();
    if (!meses.contains(mesAtual)) {
      final now = DateTime.now();
      mesAtual = meses[now.month - 1];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserExamsProvider>(
      builder: (context, userExamsProvider, child) {
        List<ExamDay> examesDoMes = userExamsProvider.getExamsForMonth(mesAtual);
        List<ExamDay> examesFiltrados = _filtrarExames(examesDoMes);

        return Scaffold(
          backgroundColor: const Color(0xFFF5F7FA),
          appBar: AppBar(
            backgroundColor: const Color(0xFF007BFF), 
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: const Text('Lembretes', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                MonthSelector(
                  meses: meses,
                  mesAtual: mesAtual,
                  onChangeMonth: _changeMonth,
                ),
                const SizedBox(height: 16),
                LembretesSearchBar(
                  onChanged: (value) => setState(() => termoDePesquisa = value),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Exames', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    IconButton(
                      onPressed: () => _showAddExamDialog(context),
                      icon: const Icon(Icons.add_circle, color: Color(0xFF007BFF), size: 36),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (examesFiltrados.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Text(
                        termoDePesquisa.isEmpty 
                          ? 'Nenhum exame agendado para $mesAtual.' 
                          : 'Nenhum resultado encontrado.', 
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                else
                  ...examesFiltrados.map((examDay) {
                    final List<Exam> examsOfDay = examDay.exams.cast<Exam>(); 

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDia(examDay.day),
                        const SizedBox(height: 8),
                        ...examsOfDay.asMap().entries.map((entry) {
                          int exameIndex = entry.key;
                          Exam exame = entry.value;
                           return ExamCard(
                            exame: exame.toMap(),
                            onToggle: () => _toggleChecklist(examDay.day, exameIndex),
                            onEdit: () => _showEditDialog(context, examDay.day, exameIndex, exame),
                            onRemove: () => _removeExame(examDay.day, exameIndex),
                          );
                        }),
                        const SizedBox(height: 16),
                      ],
                    );
                  }),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDia(int dia) {
    return Text('Dia $dia', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold));
  }

  List<ExamDay> _filtrarExames(List<ExamDay> exames) {
    if (termoDePesquisa.isEmpty) return exames;
    final termoLowerCase = termoDePesquisa.toLowerCase();
    
    List<ExamDay> resultados = [];
    for (var examDay in exames) {
      final filteredExams = examDay.exams.where((exam) {
        return exam.nome.toLowerCase().contains(termoLowerCase);
      }).toList();
      
      if (filteredExams.isNotEmpty) {
        resultados.add(ExamDay(day: examDay.day, exams: filteredExams as dynamic)); 
      }
    }
    return resultados;
  }

  void _changeMonth(int newIndex) {
    setState(() => mesAtual = meses[newIndex]);
  }

  void _toggleChecklist(int dia, int exameIndex) {
    final userExamsProvider = Provider.of<UserExamsProvider>(context, listen: false);
    userExamsProvider.toggleExamCompletion(mesAtual, dia, exameIndex);
  }

  void _removeExame(int dia, int exameIndex) {
    final userExamsProvider = Provider.of<UserExamsProvider>(context, listen: false);
    userExamsProvider.removeExam(mesAtual, dia, exameIndex);
  }
  
  bool _isDayValidForMonth(int day, String monthName) {
    final maxDays = diasPorMes[monthName];
    if (maxDays == null) return false;
    return day >= 1 && day <= maxDays;
  }

  // 🟢 DIALOGO SIMPLIFICADO: Sem opção de recorrência
  void _showAddExamDialog(BuildContext context) {
    final nomeController = TextEditingController();
    final diaController = TextEditingController();
    final observacaoController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Adicionar Novo Exame'),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(controller: nomeController, decoration: const InputDecoration(labelText: 'Nome do Exame')),
            TextField(
              controller: diaController, 
              decoration: InputDecoration(labelText: 'Dia (1-${diasPorMes[mesAtual]})'), 
              keyboardType: TextInputType.number
            ),
            TextField(
              controller: observacaoController, 
              decoration: const InputDecoration(labelText: 'Observação (Opcional)'), 
              keyboardType: TextInputType.multiline, 
              maxLines: null
            ),
          ]),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(), 
              child: const Text('Cancelar')
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF007BFF),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () async {
                final nome = nomeController.text;
                final dia = int.tryParse(diaController.text);
                
                if (nome.isEmpty) {
                  _showAlertDialog('Erro', 'Por favor, insira o nome do exame.');
                  return;
                }
                if (dia == null || !_isDayValidForMonth(dia, mesAtual)) {
                  _showAlertDialog('Erro', 'Dia inválido para $mesAtual.');
                  return;
                }

                // 1. Salva Localmente (Hive)
                Provider.of<UserExamsProvider>(context, listen: false).addExam(
                  mesAtual, dia, nome, observacaoController.text
                );

                Navigator.of(context).pop();

                // 2. Agenda Notificação no Backend
                try {
                  final authProvider = Provider.of<AuthProvider>(context, listen: false);
                  final token = authProvider.accessToken;

                  if (token != null) {
                    final int monthIndex = meses.indexOf(mesAtual) + 1;
                    final int currentYear = DateTime.now().year;
                    final DateTime examDate = DateTime(currentYear, monthIndex, dia);
                    
                    // 🟢 Sem parâmetro de recorrência
                    await ApiService().scheduleExam(token, nome, examDate);
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Lembrete salvo e notificação agendada!"),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  print("Erro ao agendar no backend: $e");
                }
              },
              child: const Text('Adicionar'),
            ),
          ],
        );
      },
    );
  }
  
  void _showEditDialog(BuildContext context, int dia, int exameIndex, Exam exameParaEditar) {
    final nomeController = TextEditingController(text: exameParaEditar.nome);
    final diaController = TextEditingController(text: dia.toString());
    final observacaoController = TextEditingController(text: exameParaEditar.observacao);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Editar Exame'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nomeController, decoration: const InputDecoration(labelText: 'Nome do Exame')),
                TextField(controller: diaController, decoration: InputDecoration(labelText: 'Dia (1-${diasPorMes[mesAtual]})'), keyboardType: TextInputType.number),
                TextField(controller: observacaoController, decoration: const InputDecoration(labelText: 'Observações'), maxLines: null),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () {
                final novoNome = nomeController.text;
                final novoDia = int.tryParse(diaController.text);
                 if (novoNome.isEmpty) {
                  _showAlertDialog('Erro', 'Por favor, insira o nome do exame.');
                  return;
                }
                if (novoDia == null || !_isDayValidForMonth(novoDia, mesAtual)) {
                  _showAlertDialog('Erro', 'Dia inválido.');
                  return;
                }

                final updatedExam = Exam(
                  nome: novoNome,
                  observacao: observacaoController.text,
                  recorrencia: "Padrão", // Valor fixo interno
                  concluido: exameParaEditar.concluido,
                );

                Provider.of<UserExamsProvider>(context, listen: false).updateExam(
                  mesAtual, dia, exameIndex, updatedExam, novoDia
                );
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF007BFF),
                foregroundColor: Colors.white,
              ),
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );
  }

  void _showAlertDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Ok'),
            ),
          ],
        );
      },
    );
  }
}