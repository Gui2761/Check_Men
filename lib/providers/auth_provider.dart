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

  Future<void> saveAccessToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('accessToken', token);
    _accessToken = token;
  }
  
  Future<void> loadAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    _accessToken = prefs.getString('accessToken');
  }
  
  void logout() async {
    await saveLoginState(false);
    await _authService.clearAccessToken();
    _accessToken = null;
    _isLoginBoxVisible = false;
    _isRegistrationBoxVisible = false;
    _isForgotPasswordBoxVisible = false;
    _isNewPasswordBoxVisible = false;
    notifyListeners();
  }
  
  Future<http.Response> login(String identifier, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _authService.login(identifier, password);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = json.decode(response.body);
        if (data.containsKey('access_token')) {
          await saveAccessToken(data['access_token']);
        }
        await saveLoginState(true);
      }
      return response;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<http.Response> register(String username, String email, String password, String recoveryPhrase) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _authService.register(username, email, password, recoveryPhrase);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = json.decode(response.body);
        if (data.containsKey('access_token')) {
          await saveAccessToken(data['access_token']);
        }
      }
      return response;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<http.Response> forgotPassword(String email, String recoveryPhrase) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _authService.forgotPassword(email, recoveryPhrase);
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
      final response = await _authService.resetPassword(newPassword);
      return response;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}