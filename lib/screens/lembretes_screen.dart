import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Para formatação de data e nome do mês
import 'package:provider/provider.dart'; // Para acessar o UserExamsProvider

// Importações dos widgets e modelos personalizados
import '../widgets/lembretes/month_selector.dart';
import '../widgets/lembretes/search_bar.dart';
import '../widgets/lembretes/exam_card.dart';
import '../utils/app_extensions.dart'; // Para a extensão .capitalize()
import '../providers/user_exams_provider.dart';
import '../models/exam.dart'; // Para os modelos Exam e ExamDay

// 🟢 NOVAS IMPORTAÇÕES
import '../services/api_service.dart';
import '../providers/auth_provider.dart';

class LembretesScreen extends StatefulWidget {
  const LembretesScreen({super.key});

  @override
  State<LembretesScreen> createState() => _LembretesScreenState();
}

class _LembretesScreenState extends State<LembretesScreen> {
  // Listas de meses para o seletor
  final List<String> meses = [
    'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho', 
    'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro',
  ];
  
  // Mapa para saber o número de dias em cada mês (simplificado)
  final Map<String, int> diasPorMes = {
    'Janeiro': 31, 'Fevereiro': 28, 'Março': 31, 'Abril': 30, 'Maio': 31, 'Junho': 30, 
    'Julho': 31, 'Agosto': 31, 'Setembro': 30, 'Outubro': 31, 'Novembro': 30, 'Dezembro': 31,
  };

  // Variáveis de estado para o mês atual e o termo de pesquisa
  String mesAtual = 'Fevereiro'; 
  String termoDePesquisa = '';

  @override
  void initState() {
    super.initState();
    // Define o mês inicial como o mês atual do sistema
    mesAtual = DateFormat('MMMM', 'pt_BR').format(DateTime.now()).capitalize();
    
    // Fallback caso o locale do sistema não retorne o nome do mês como esperado
    if (!meses.contains(mesAtual)) {
      final now = DateTime.now();
      mesAtual = meses[now.month - 1];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserExamsProvider>(
      builder: (context, userExamsProvider, child) {
        // Obtém os exames do mês atual do provider
        List<ExamDay> examesDoMes = userExamsProvider.getExamsForMonth(mesAtual);
        // Aplica o filtro de pesquisa
        List<ExamDay> examesFiltrados = _filtrarExames(examesDoMes);

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: const Color(0xFF007BFF), 
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
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
                // Seletor de mês
                MonthSelector(
                  meses: meses,
                  mesAtual: mesAtual,
                  onChangeMonth: _changeMonth,
                ),
                const SizedBox(height: 16),
                // Barra de pesquisa
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
                      icon: const Icon(Icons.add_circle, color: Color(0xFF1A75B4), size: 30),
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
                          : 'Nenhum resultado encontrado para "$termoDePesquisa".', 
                        style: const TextStyle(fontSize: 16, color: Colors.grey),
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

  // 🟢 MÉTODO ATUALIZADO PARA AGENDAR NOTIFICAÇÃO
  void _showAddExamDialog(BuildContext context) {
    final nomeController = TextEditingController();
    final diaController = TextEditingController();
    final observacaoController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Adicionar Novo Exame'),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(controller: nomeController, decoration: const InputDecoration(labelText: 'Nome do Exame')),
            TextField(controller: diaController, decoration: InputDecoration(labelText: 'Dia (1-${diasPorMes[mesAtual]})'), keyboardType: TextInputType.number),
            TextField(controller: observacaoController, decoration: const InputDecoration(labelText: 'Observação (Opcional)'), keyboardType: TextInputType.multiline, maxLines: null),
          ]),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar')),
            TextButton(
              onPressed: () async {
                final nome = nomeController.text;
                final dia = int.tryParse(diaController.text);
                
                if (nome.isEmpty) {
                  _showAlertDialog('Erro', 'Por favor, insira o nome do exame.');
                  return;
                }
                if (dia == null || !_isDayValidForMonth(dia, mesAtual)) {
                  _showAlertDialog('Erro', 'O dia é inválido para $mesAtual. Por favor, insira um dia entre 1 e ${diasPorMes[mesAtual]}.');
                  return;
                }

                // 1. Salvar Localmente (Provider)
                Provider.of<UserExamsProvider>(context, listen: false).addExam(
                  mesAtual, dia, nome, observacaoController.text, 'Mensal'
                );

                // 2. Agendar Notificação no Backend (Nova Lógica)
                try {
                  final authProvider = Provider.of<AuthProvider>(context, listen: false);
                  final token = authProvider.accessToken;

                  if (token != null) {
                    // Calcula a data completa
                    final int monthIndex = meses.indexOf(mesAtual) + 1;
                    final int currentYear = DateTime.now().year;
                    
                    // Ajuste simples: se o mês já passou, assume que é para o próximo ano (opcional)
                    int year = currentYear;
                    if (monthIndex < DateTime.now().month || (monthIndex == DateTime.now().month && dia < DateTime.now().day)) {
                       // Se quiser agendar pro ano que vem descomente abaixo, 
                       // por enquanto deixamos no ano atual para o teste funcionar.
                       // year = currentYear + 1; 
                    }

                    final DateTime examDate = DateTime(year, monthIndex, dia);
                    
                    // Chama o serviço
                    await ApiService().scheduleExam(token, nome, examDate);
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Lembrete salvo e notificação agendada!")),
                    );
                  }
                } catch (e) {
                  print("Erro ao agendar no backend: $e");
                }

                Navigator.of(context).pop();
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
    String recorrenciaSelecionada = exameParaEditar.recorrencia;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateSB) {
            return AlertDialog(
              title: const Text('Editar Exame'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(controller: nomeController, decoration: const InputDecoration(labelText: 'Nome do Exame')),
                    TextField(controller: diaController, decoration: InputDecoration(labelText: 'Dia (1-${diasPorMes[mesAtual]})'), keyboardType: TextInputType.number),
                    TextField(controller: observacaoController, decoration: const InputDecoration(labelText: 'Observações'), maxLines: null),
                    const SizedBox(height: 16),
                    const Text('Recorrência do Exame'),
                    Wrap(
                      spacing: 8.0,
                      children: ['Mensal', 'Semanal', 'Anual'].map((recorrencia) {
                        return ChoiceChip(
                          label: Text(recorrencia),
                          selected: recorrenciaSelecionada == recorrencia,
                          onSelected: (selected) => setStateSB(() => recorrenciaSelecionada = recorrencia),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar')),
                TextButton(
                  onPressed: () {
                    final novoNome = nomeController.text;
                    final novoDia = int.tryParse(diaController.text);
                     if (novoNome.isEmpty) {
                      _showAlertDialog('Erro', 'Por favor, insira o nome do exame.');
                      return;
                    }
                    if (novoDia == null || !_isDayValidForMonth(novoDia, mesAtual)) {
                      _showAlertDialog('Erro', 'O dia é inválido para $mesAtual. Por favor, insira um dia entre 1 e ${diasPorMes[mesAtual]}.');
                      return;
                    }

                    final updatedExam = Exam(
                      nome: novoNome,
                      observacao: observacaoController.text,
                      recorrencia: recorrenciaSelecionada,
                      concluido: exameParaEditar.concluido,
                    );

                    Provider.of<UserExamsProvider>(context, listen: false).updateExam(
                      mesAtual, dia, exameIndex, updatedExam, novoDia
                    );
                    Navigator.of(context).pop();
                  },
                  child: const Text('Salvar'),
                ),
              ],
            );
          },
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