import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final String _baseUrl = 'http://localhost:8000/auth'; 
  String? _accessToken;

  Future<void> _loadAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    _accessToken = prefs.getString('accessToken');
  }

  Future<void> clearAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('accessToken');
    _accessToken = null;
  }

  Future<http.Response> login(String identifier, String password) async {
    final bool isEmail = identifier.contains('@');

    final response = await http.post(
      Uri.parse('$_baseUrl/login'),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, String>{
        isEmail ? 'email' : 'username': identifier,
        'password': password,
      }),
    );
    return response;
  }

  Future<http.Response> register(String username, String email, String password, String recoveryPhrase) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/register'),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, String>{
        'username': username,
        'email': email,
        'password': password,
        'recoveryPhrase': recoveryPhrase,
      }),
    );
    return response;
  }

  Future<http.Response> forgotPassword(String email, String recoveryPhrase) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/forgot-password'),
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
      Uri.parse('$_baseUrl/reset-password'),
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