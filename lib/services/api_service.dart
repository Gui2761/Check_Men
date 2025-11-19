import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class ApiService {
  // Função para agendar o exame no backend (para notificação push)
  Future<void> scheduleExam(String token, String examName, DateTime examDate) async {
    final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.scheduleExam}');
    
    // Formata a data para o padrão que o Python espera: YYYY-MM-DD
    final String dateStr = "${examDate.year}-${examDate.month.toString().padLeft(2, '0')}-${examDate.day.toString().padLeft(2, '0')}";

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // Envia o token para autenticar
        },
        body: jsonEncode({
          'exam_name': examName,
          'exam_date': dateStr,
        }),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        print("Agendamento no backend realizado com sucesso: ${response.body}");
      } else {
        print("Erro no backend: ${response.statusCode} - ${response.body}");
        // Não lançamos exceção para não travar o fluxo visual do usuário, 
        // mas você poderia tratar isso se quisesse alertar o usuário.
      }
    } catch (e) {
      print('Erro de conexão ao agendar: $e');
    }
  }
}