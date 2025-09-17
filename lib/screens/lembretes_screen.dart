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

// Não é mais necessário importar 'package:hive/hive.dart'; aqui diretamente
// porque a lógica de persistência e criação de HiveList está no provider.

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
  
  // Mapa para saber o número de dias em cada mês (simplificado, não considera anos bissextos)
  final Map<String, int> diasPorMes = {
    'Janeiro': 31, 'Fevereiro': 28, 'Março': 31, 'Abril': 30, 'Maio': 31, 'Junho': 30, 
    'Julho': 31, 'Agosto': 31, 'Setembro': 30, 'Outubro': 31, 'Novembro': 30, 'Dezembro': 31,
  };

  // Variáveis de estado para o mês atual e o termo de pesquisa
  String mesAtual = 'Fevereiro'; // Valor inicial para evitar null
  String termoDePesquisa = '';

  @override
  void initState() {
    super.initState();
    // Define o mês inicial como o mês atual do sistema, formatado em português e capitalizado
    // Adicionado 'pt_BR' explicitamente para garantir o locale
    mesAtual = DateFormat('MMMM', 'pt_BR').format(DateTime.now()).capitalize();
    
    // Fallback caso o locale do sistema não retorne o nome do mês como esperado
    if (!meses.contains(mesAtual)) {
      final now = DateTime.now();
      mesAtual = meses[now.month - 1];
    }
  }

  @override
  Widget build(BuildContext context) {
    // Usa Consumer para reagir a mudanças no UserExamsProvider
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
              onPressed: () => Navigator.of(context).pop(), // Botão de voltar
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
                  onChangeMonth: _changeMonth, // Callback para mudança de mês
                ),
                const SizedBox(height: 16),
                // Barra de pesquisa
                LembretesSearchBar(
                  onChanged: (value) => setState(() => termoDePesquisa = value), // Atualiza o termo de pesquisa
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Exames', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    IconButton(
                      onPressed: () => _showAddExamDialog(context), // Botão para adicionar novo exame
                      icon: const Icon(Icons.add_circle, color: Color(0xFF1A75B4), size: 30),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Exibe mensagem se não houver exames ou se a pesquisa não retornar resultados
                if (examesFiltrados.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Text(
                        termoDePesquisa.isEmpty 
                          ? 'Nenhum exame agendado para ${mesAtual}.' 
                          : 'Nenhum resultado encontrado para "${termoDePesquisa}".', 
                        style: const TextStyle(fontSize: 16, color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                else
                  // Itera sobre os dias com exames filtrados
                  ...examesFiltrados.map((examDay) {
                    // O cast é essencial aqui. Como _filtrarExames retorna um ExamDay com List<Exam> (dynamic),
                    // precisamos garantir que estamos tratando como List<Exam>.
                    final List<Exam> examsOfDay = examDay.exams.cast<Exam>(); 

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDia(examDay.day), // Exibe o dia
                        const SizedBox(height: 8),
                        // Itera sobre os exames de cada dia
                        ...examsOfDay.asMap().entries.map((entry) {
                          int exameIndex = entry.key;
                          Exam exame = entry.value;
                           return ExamCard(
                            exame: exame.toMap(), // Passa o exame como mapa para o card
                            onToggle: () => _toggleChecklist(examDay.day, exameIndex), // Marca/desmarca
                            onEdit: () => _showEditDialog(context, examDay.day, exameIndex, exame), // Edita exame
                            onRemove: () => _removeExame(examDay.day, exameIndex), // Remove exame
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

  // Widget simples para exibir o dia
  Widget _buildDia(int dia) {
    return Text('Dia $dia', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold));
  }

  // Método para filtrar exames com base no termo de pesquisa
  // IMPORTANTE: Este método não interage diretamente com HiveList para persistência.
  // Ele cria novos objetos ExamDay com List<Exam> (não HiveList) para exibição.
  List<ExamDay> _filtrarExames(List<ExamDay> exames) {
    if (termoDePesquisa.isEmpty) return exames; // Se não há termo, retorna todos
    final termoLowerCase = termoDePesquisa.toLowerCase();
    
    List<ExamDay> resultados = [];
    for (var examDay in exames) {
      // Filtra os exames dentro de cada dia
      final filteredExams = examDay.exams.where((exam) {
        return exam.nome.toLowerCase().contains(termoLowerCase);
      }).toList();
      
      if (filteredExams.isNotEmpty) {
        // Se houver exames filtrados para este dia, cria um novo ExamDay
        // com uma lista simples de Exames (List<Exam>), não um HiveList.
        // O `as dynamic` é um workaround para a tipagem do construtor de ExamDay
        // que espera HiveList, mas para exibição temporária, List<Exam> funciona.
        resultados.add(ExamDay(day: examDay.day, exams: filteredExams as dynamic)); 
      }
    }
    return resultados;
  }

  // Callback para mudança de mês no seletor
  void _changeMonth(int newIndex) {
    setState(() => mesAtual = meses[newIndex]);
  }

  // Marca/desmarca um exame como concluído
  void _toggleChecklist(int dia, int exameIndex) {
    final userExamsProvider = Provider.of<UserExamsProvider>(context, listen: false);
    userExamsProvider.toggleExamCompletion(mesAtual, dia, exameIndex);
  }

  // Remove um exame
  void _removeExame(int dia, int exameIndex) {
    final userExamsProvider = Provider.of<UserExamsProvider>(context, listen: false);
    userExamsProvider.removeExam(mesAtual, dia, exameIndex);
  }
  
  // Verifica se o dia é válido para o mês selecionado
  bool _isDayValidForMonth(int day, String monthName) {
    final maxDays = diasPorMes[monthName];
    if (maxDays == null) return false;
    return day >= 1 && day <= maxDays;
  }

  // Exibe o diálogo para adicionar um novo exame
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
              onPressed: () {
                final nome = nomeController.text;
                final dia = int.tryParse(diaController.text);
                if (nome.isEmpty) {
                  _showAlertDialog('Erro', 'Por favor, insira o nome do exame.');
                  return;
                }
                if (dia == null || !_isDayValidForMonth(dia, mesAtual)) {
                  _showAlertDialog('Erro', 'O dia é inválido para ${mesAtual}. Por favor, insira um dia entre 1 e ${diasPorMes[mesAtual]}.');
                  return;
                }
                // Chama o provider para adicionar o exame
                Provider.of<UserExamsProvider>(context, listen: false).addExam(
                  mesAtual, dia, nome, observacaoController.text, 'Mensal'
                );
                Navigator.of(context).pop();
              },
              child: const Text('Adicionar'),
            ),
          ],
        );
      },
    );
  }
  
  // Exibe o diálogo para editar um exame existente
  void _showEditDialog(BuildContext context, int dia, int exameIndex, Exam exameParaEditar) {
    final nomeController = TextEditingController(text: exameParaEditar.nome);
    final diaController = TextEditingController(text: dia.toString());
    final observacaoController = TextEditingController(text: exameParaEditar.observacao);
    String recorrenciaSelecionada = exameParaEditar.recorrencia;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder( // StatefulBuilder para gerenciar o estado do ChoiceChip
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
                      _showAlertDialog('Erro', 'O dia é inválido para ${mesAtual}. Por favor, insira um dia entre 1 e ${diasPorMes[mesAtual]}.');
                      return;
                    }

                    // Cria um novo objeto Exam com os dados atualizados
                    final updatedExam = Exam(
                      nome: novoNome,
                      observacao: observacaoController.text,
                      recorrencia: recorrenciaSelecionada,
                      concluido: exameParaEditar.concluido,
                    );

                    // Chama o provider para atualizar o exame
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

  // Exibe um AlertDialog genérico para mensagens de erro/informação
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