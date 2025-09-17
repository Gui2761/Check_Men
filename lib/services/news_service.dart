import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/noticia_model.dart'; // Importar o novo modelo NoticiaResponse

class NewsService {
  Future<NoticiaResponse> fetchNoticias({int page = 1, int limit = 3}) async { // Adicionado page e limit
    final uri = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.rssNews}?page=$page&limit=$limit');
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = json.decode(response.body);
      // Verificar se a resposta é um erro do backend
      if (jsonData.containsKey('error')) {
        throw Exception(jsonData['error']); // Lança a mensagem de erro do backend
      }
      return NoticiaResponse.fromJson(jsonData); // Usar o novo modelo
    } else {
      throw Exception('Erro ao carregar notícias: ${response.statusCode}');
    }
  }
}