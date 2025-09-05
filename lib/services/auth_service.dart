import 'package:http/http.dart' as http;
import 'dart:convert';

class AuthService {
  final String _baseUrl = 'SEU_URL_DA_API'; // Substitua pelo seu URL

  Future<http.Response> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/login'),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, String>{
        'email': email,
        'password': password,
      }),
    );
    return response;
  }

  Future<http.Response> register(String email, String password, String recoveryPhrase) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/register'),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, String>{
        'email': email,
        'password': password,
        'recoveryPhrase': recoveryPhrase,
      }),
    );
    return response;
  }

  Future<http.Response> forgotPassword(String email, String recoveryPhrase) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/forgot-password'), // Substitua pelo endpoint correto
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, String>{
        'email': email,
        'recoveryPhrase': recoveryPhrase,
      }),
    );
    return response;
  }

  Future<http.Response> resetPassword(String newPassword) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/reset-password'), // Substitua pelo endpoint correto
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, String>{
        'newPassword': newPassword,
      }),
    );
    return response;
  }
}