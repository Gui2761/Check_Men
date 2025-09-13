import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  
  bool _isLoginBoxVisible = false;
  bool _isRegistrationBoxVisible = false;
  bool _isForgotPasswordBoxVisible = false;
  bool _isNewPasswordBoxVisible = false;
  bool _isLoading = false;
  
  String? _accessToken;
  String? _refreshToken; 
  
  String? _emailForPasswordReset;
  String? _securityWordForPasswordReset;

  bool get isLoginBoxVisible => _isLoginBoxVisible;
  bool get isRegistrationBoxVisible => _isRegistrationBoxVisible;
  bool get isForgotPasswordBoxVisible => _isForgotPasswordBoxVisible;
  bool get isNewPasswordBoxVisible => _isNewPasswordBoxVisible;
  bool get isLoading => _isLoading;
  String? get accessToken => _accessToken;


  void animateLoginBox() {
    _isLoginBoxVisible = true;
    _isRegistrationBoxVisible = false;
    _isForgotPasswordBoxVisible = false;
    _isNewPasswordBoxVisible = false;
    notifyListeners();
  }

  void animateRegistrationBox() {
    _isRegistrationBoxVisible = true;
    _isLoginBoxVisible = false;
    _isForgotPasswordBoxVisible = false;
    _isNewPasswordBoxVisible = false;
    notifyListeners();
  }

  void animateForgotPasswordBox() {
    _isForgotPasswordBoxVisible = true;
    _isLoginBoxVisible = false;
    _isRegistrationBoxVisible = false;
    _isNewPasswordBoxVisible = false;
    notifyListeners();
  }

  void animateNewPasswordBox() {
    _isNewPasswordBoxVisible = true;
    _isForgotPasswordBoxVisible = false;
    _isLoginBoxVisible = false;
    _isRegistrationBoxVisible = false;
    notifyListeners();
  }
  
  void backToInitialScreen(BuildContext context) {
    FocusScope.of(context).unfocus();
    
    _isLoginBoxVisible = false;
    _isRegistrationBoxVisible = false;
    _isForgotPasswordBoxVisible = false;
    _isNewPasswordBoxVisible = false;
    notifyListeners();
  }
  
  Future<void> saveLoginState(bool isLoggedIn) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', isLoggedIn);
  }

  Future<bool> loadLoginState() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false;
  }

  Future<void> _saveTokens(String accessToken, String refreshToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('accessToken', accessToken);
    await prefs.setString('refreshToken', refreshToken);
    _accessToken = accessToken;
    _refreshToken = refreshToken;
  }

  Future<void> _loadTokens() async {
    final prefs = await SharedPreferences.getInstance();
    _accessToken = prefs.getString('accessToken');
    _refreshToken = prefs.getString('refreshToken');
  }
  
  void logout() async {
    await saveLoginState(false);
    await _authService.clearTokens();
    _accessToken = null;
    _refreshToken = null;
    _isLoginBoxVisible = false;
    _isRegistrationBoxVisible = false;
    _isForgotPasswordBoxVisible = false;
    _isNewPasswordBoxVisible = false;
    notifyListeners();
  }
  
  Future<http.Response> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _authService.login(email, password);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = json.decode(response.body);
        if (data.containsKey('access_token') && data.containsKey('refresh_token')) {
          await _saveTokens(data['access_token'], data['refresh_token']);
        }
        await saveLoginState(true);
      }
      return response;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<http.Response> register(String name, String email, String password, String securityWord) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _authService.register(name, email, password, securityWord);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = json.decode(response.body);
        if (data.containsKey('access_token') && data.containsKey('refresh_token')) {
          await _saveTokens(data['access_token'], data['refresh_token']);
        }
      }
      return response;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }


  Future<bool> attemptRefreshToken() async {
    await _loadTokens();
    if (_refreshToken == null) {
      return false;
    }

    try {
      final response = await _authService.refreshToken(_refreshToken!);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = json.decode(response.body);
        if (data.containsKey('access_token')) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('accessToken', data['access_token']);
          _accessToken = data['access_token'];
          notifyListeners();
          return true;
        }
      }
      return false;
    } catch (e) {
      return false;
    }
  }
  
 
  Future<http.Response> verifySecurityWord(String email, String securityWord) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _authService.verifySecurityWord(email, securityWord);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        _emailForPasswordReset = email;
        _securityWordForPasswordReset = securityWord;
      }
      return response;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<http.Response> resetPassword(String newPassword) async {
    _isLoading = true;
    notifyListeners();
    try {
      if (_emailForPasswordReset == null || _securityWordForPasswordReset == null) {
        throw Exception("Dados para redefinição de senha não encontrados.");
      }
      final response = await _authService.resetPassword(_emailForPasswordReset!, _securityWordForPasswordReset!, newPassword);
      return response;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}