import 'package:http/http.dart' as http;
import 'dart:convert';

class AuthService {
  final String _baseUrl = 'https://seusite.com/api'; // Substitua pela sua URL base

  Future<http.Response> login(String email, String password) async {
    return await http.post(
      Uri.parse('$_baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email, 'password': password}),
    );
  }

  Future<http.Response> register(String email, String password, String recoveryPhrase) async {
    return await http.post(
      Uri.parse('$_baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'email': email,
        'password': password,
        'recoveryPhrase': recoveryPhrase,
      }),
    );
  }

  Future<http.Response> forgotPassword(String recoveryPhrase) async {
    return await http.post(
      Uri.parse('$_baseUrl/forgot-password'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'recoveryPhrase': recoveryPhrase}),
    );
  }

  Future<http.Response> resetPassword(String newPassword) async {
    // Nota: Em um cenário real, você provavelmente precisaria enviar também
    // o token de recuperação ou a frase de volta.
    return await http.post(
      Uri.parse('$_baseUrl/reset-password'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'newPassword': newPassword}),
    );
  }
}