import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/usuario_model.dart';

class ApiService {
  final String _baseUrl = 'https://jsonplaceholder.typicode.com';

  Future<List<Usuario>> getUsuarios() async {
    final uri = Uri.parse('$_baseUrl/users');
    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList.map((json) => Usuario.fromJson(json)).toList();
      } else {
        throw Exception('Falha ao carregar os usuários: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Ocorreu um erro na requisição: $e');
    }
  }

  Future<http.Response> criarUsuario(Map<String, dynamic> dadosUsuario) async {
    final uri = Uri.parse('$_baseUrl/users');
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode(dadosUsuario);
    try {
      final response = await http.post(uri, headers: headers, body: body);
      if (response.statusCode == 201) {
        return response;
      } else {
        throw Exception('Falha ao criar o usuário: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Ocorreu um erro na requisição: $e');
    }
  }
}