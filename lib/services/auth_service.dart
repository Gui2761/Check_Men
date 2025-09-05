import 'package:http/http.dart' as http;
import 'dart:convert';

class AuthService {
  final String _baseUrl = 'https://sua-api.com';

  Future<http.Response> login(String email, String password) async {
    final uri = Uri.parse('$_baseUrl/auth/login');
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({'email': email, 'password': password});
    return await http.post(uri, headers: headers, body: body);
  }

  Future<http.Response> register(String email, String password, String recoveryPhrase) async {
    final uri = Uri.parse('$_baseUrl/auth/register');
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({
      'email': email,
      'password': password,
      'recoveryPhrase': recoveryPhrase
    });
    return await http.post(uri, headers: headers, body: body);
  }

  Future<http.Response> forgotPassword(String recoveryPhrase) async {
    final uri = Uri.parse('$_baseUrl/auth/forgot-password');
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({'recoveryPhrase': recoveryPhrase});
    return await http.post(uri, headers: headers, body: body);
  }

  Future<http.Response> resetPassword(String newPassword) async {
    final uri = Uri.parse('$_baseUrl/auth/reset-password');
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({'newPassword': newPassword});
    return await http.post(uri, headers: headers, body: body);
  }
}