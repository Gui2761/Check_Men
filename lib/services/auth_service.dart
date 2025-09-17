import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart'; // Certifique-se de que este import está correto

class AuthService {
  Future<void> clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('accessToken');
    await prefs.remove('refreshToken');
  }

  Future<http.Response> login(String identifier, String password) async {
    final response = await http.post(
      Uri.parse(ApiConfig.baseUrl + ApiConfig.login),
      headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode(<String, String>{'identifier': identifier, 'password': password}),
    );
    return response;
  }

  Future<http.Response> register(String name, String email, String password, String securityWord) async {
    final response = await http.post(
      Uri.parse(ApiConfig.baseUrl + ApiConfig.register),
      headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode(<String, String>{
        'name': name,
        'email': email,
        'password': password,
        'security_word': securityWord,
      }),
    );
    return response;
  }

  // Novo método para renovar o token
  Future<http.Response> refreshToken(String refreshToken) async {
    final response = await http.post(
      Uri.parse(ApiConfig.baseUrl + ApiConfig.refreshToken),
      headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode(<String, String>{'refresh_token': refreshToken}),
    );
    return response;
  }

  Future<http.Response> verifySecurityWord(String email, String securityWord) async {
    final response = await http.post(
      Uri.parse(ApiConfig.baseUrl + ApiConfig.verifySecurityWord),
      headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode(<String, String>{'email': email, 'security_word': securityWord}),
    );
    return response;
  }

  Future<http.Response> resetPassword(String email, String securityWord, String newPassword) async {
    final response = await http.post(
      Uri.parse(ApiConfig.baseUrl + ApiConfig.resetPassword),
      headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode(<String, String>{
        'email': email,
        'security_word': securityWord,
        'new_password': newPassword,
      }),
    );
    return response;
  }
}