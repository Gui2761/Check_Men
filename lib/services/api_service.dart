import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class ApiService {
  // 🟢 ATUALIZADO: Removemos o parâmetro 'recurrence'
  Future<void> scheduleExam(String token, String examName, DateTime examDate) async {
    final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.scheduleExam}');
    
    final String dateStr = "${examDate.year}-${examDate.month.toString().padLeft(2, '0')}-${examDate.day.toString().padLeft(2, '0')}";

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'exam_name': examName,
          'exam_date': dateStr,
          // 'recurrence' removido
        }),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        print("Agendamento realizado com sucesso.");
      } else {
        print("Erro no backend: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      print('Erro de conexão ao agendar: $e');
    }
  }
}