import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'user_exams_provider.dart'; 
import 'package:firebase_messaging/firebase_messaging.dart'; 
import '../services/notification_service.dart'; 

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  
  // Variáveis de UI
  bool _isLoginBoxVisible = false;
  bool _isRegistrationBoxVisible = false;
  bool _isForgotPasswordBoxVisible = false;
  bool _isNewPasswordBoxVisible = false;
  bool _isLoading = false;
  
  // 🟢 NOVA VARIÁVEL: Indica se estamos verificando o auto-login
  bool _isAuthLoading = true; 
  
  // Variáveis de Usuário
  String? _accessToken;
  String? _refreshToken;
  String? _userName;
  String? _userId; 

  String? _emailForPasswordReset;
  String? _securityWordForPasswordReset;

  final UserExamsProvider _userExamsProvider = UserExamsProvider(); 

  // Getters
  bool get isLoginBoxVisible => _isLoginBoxVisible;
  bool get isRegistrationBoxVisible => _isRegistrationBoxVisible;
  bool get isForgotPasswordBoxVisible => _isForgotPasswordBoxVisible;
  bool get isNewPasswordBoxVisible => _isNewPasswordBoxVisible;
  bool get isLoading => _isLoading;
  
  // 🟢 Getter para saber se está carregando o auto-login
  bool get isAuthLoading => _isAuthLoading; 
  
  bool get isAuthenticated => _accessToken != null; 
  String? get accessToken => _accessToken;
  String? get userName => _userName;
  String? get userId => _userId; 
  UserExamsProvider get userExamsProvider => _userExamsProvider; 

  AuthProvider() {
    _loadUserDataAndExams(); 
  }

  // --- Controle de UI ---
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

  Future<void> _initializeAndSendToken({required String accessToken}) async {
    await NotificationService().initializeAndGetToken(accessToken);
  }

  Future<void> _saveUserData(String accessToken, String refreshToken, String userName, String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('accessToken', accessToken);
    await prefs.setString('refreshToken', refreshToken);
    await prefs.setString('userName', userName);
    await prefs.setString('userId', userId); 
    _accessToken = accessToken;
    _refreshToken = refreshToken;
    _userName = userName;
    _userId = userId;
  }

  // 🟢 ATUALIZADO: Carrega dados e define isAuthLoading como false quando termina
  Future<void> _loadUserDataAndExams() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _accessToken = prefs.getString('accessToken');
      _refreshToken = prefs.getString('refreshToken');
      _userName = prefs.getString('userName');
      _userId = prefs.getString('userId'); 

      if (_userId != null && _userId!.isNotEmpty) {
        await _userExamsProvider.initializeForUser(_userId); 
        // Se tiver token, tenta inicializar notificações também
        if (_accessToken != null) {
           _initializeAndSendToken(accessToken: _accessToken!);
        }
      }
    } catch (e) {
      print("Erro ao carregar dados do usuário: $e");
    } finally {
      // 🟢 Avisa que terminou de carregar
      _isAuthLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); 

    _accessToken = null;
    _refreshToken = null;
    _userName = null;
    _userId = null;
    
    _isLoginBoxVisible = false;
    _isRegistrationBoxVisible = false;
    _isForgotPasswordBoxVisible = false;
    _isNewPasswordBoxVisible = false;

    await _userExamsProvider.closeUserBox(); 
    notifyListeners();
  }
  
  Future<http.Response> login(String identifier, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _authService.login(identifier, password);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = json.decode(response.body);
        final user = data['user'];
        final newAccessToken = data['access_token']; 
        
        await _saveUserData(newAccessToken, data['refresh_token'], user['name'], user['user_id'].toString());
        await _userExamsProvider.initializeForUser(_userId); 
        await _initializeAndSendToken(accessToken: newAccessToken); 
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
        final user = data['user'];
        final newAccessToken = data['access_token']; 
        
        await _saveUserData(newAccessToken, data['refresh_token'], user['name'], user['user_id'].toString());
        await _userExamsProvider.initializeForUser(_userId); 
        await _initializeAndSendToken(accessToken: newAccessToken); 
      }
      return response;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> attemptRefreshToken() async {
    if (_refreshToken == null) {
      return false; 
    }

    try {
      final response = await _authService.refreshToken(_refreshToken!);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = json.decode(response.body);
        if (data.containsKey('access_token')) {
          final newAccessToken = data['access_token'];

          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('accessToken', newAccessToken);
          _accessToken = newAccessToken;
          
          if (_userId != null && _userId!.isNotEmpty) {
             await _userExamsProvider.initializeForUser(_userId);
             await _initializeAndSendToken(accessToken: newAccessToken);
          }
          notifyListeners();
          return true; 
        }
      }
      await logout(); 
      return false; 
    } catch (e) {
      await logout();
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