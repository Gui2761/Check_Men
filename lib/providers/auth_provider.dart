import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'user_exams_provider.dart'; // Importar o novo provedor

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  
  // Variáveis de estado para controle da UI de autenticação
  bool _isLoginBoxVisible = false;
  bool _isRegistrationBoxVisible = false;
  bool _isForgotPasswordBoxVisible = false;
  bool _isNewPasswordBoxVisible = false;
  bool _isLoading = false;
  
  // Variáveis de estado do usuário autenticado
  String? _accessToken;
  String? _refreshToken;
  String? _userName;
  String? _userId; // Adicionar o ID do usuário

  // Variáveis para o fluxo de redefinição de senha
  String? _emailForPasswordReset;
  String? _securityWordForPasswordReset;

  // Instância do provedor de exames, gerenciado por este AuthProvider
  final UserExamsProvider _userExamsProvider = UserExamsProvider(); 

  // Getters para as variáveis de estado
  bool get isLoginBoxVisible => _isLoginBoxVisible;
  bool get isRegistrationBoxVisible => _isRegistrationBoxVisible;
  bool get isForgotPasswordBoxVisible => _isForgotPasswordBoxVisible;
  bool get isNewPasswordBoxVisible => _isNewPasswordBoxVisible;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _accessToken != null; // Verifica se há um token de acesso
  String? get accessToken => _accessToken;
  String? get userName => _userName;
  String? get userId => _userId; // Getter para o ID do usuário
  UserExamsProvider get userExamsProvider => _userExamsProvider; // Getter para o provedor de exames

  AuthProvider() {
    _loadUserDataAndExams(); // Carrega dados do usuário e inicializa o provedor de exames
  }

  // --- Métodos para controle da visibilidade das caixas de autenticação ---
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
  // --- Fim dos métodos de controle da UI ---

  // --- Métodos para gerenciamento de dados do usuário e autenticação ---

  Future<void> _saveUserData(String accessToken, String refreshToken, String userName, String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('accessToken', accessToken);
    await prefs.setString('refreshToken', refreshToken);
    await prefs.setString('userName', userName);
    await prefs.setString('userId', userId); // Salvar o ID do usuário
    _accessToken = accessToken;
    _refreshToken = refreshToken;
    _userName = userName;
    _userId = userId;
  }

  Future<void> _loadUserDataAndExams() async {
    final prefs = await SharedPreferences.getInstance();
    _accessToken = prefs.getString('accessToken');
    _refreshToken = prefs.getString('refreshToken');
    _userName = prefs.getString('userName');
    _userId = prefs.getString('userId'); // Carregar o ID do usuário

    if (_userId != null && _userId!.isNotEmpty) {
      await _userExamsProvider.initializeForUser(_userId); // Inicializar provedor de exames para o usuário
    }
    notifyListeners();
  }
  
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Limpa todos os dados de SharedPreferences

    _accessToken = null;
    _refreshToken = null;
    _userName = null;
    _userId = null;
    
    // Resetar estado da UI de autenticação
    _isLoginBoxVisible = false;
    _isRegistrationBoxVisible = false;
    _isForgotPasswordBoxVisible = false;
    _isNewPasswordBoxVisible = false;

    await _userExamsProvider.closeUserBox(); // Fechar a box do Hive do usuário
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
        // Usar 'user_id' do objeto 'user'
        await _saveUserData(data['access_token'], data['refresh_token'], user['name'], user['user_id'].toString());
        await _userExamsProvider.initializeForUser(_userId); // Inicializar provedor de exames
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
        // Usar 'user_id' do objeto 'user'
        await _saveUserData(data['access_token'], data['refresh_token'], user['name'], user['user_id'].toString());
        await _userExamsProvider.initializeForUser(_userId); // Inicializar provedor de exames
      }
      return response;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Tenta renovar o token de acesso usando o refresh token.
  /// Retorna `true` se bem-sucedido, `false` caso contrário.
  Future<bool> attemptRefreshToken() async {
    if (_refreshToken == null) {
      return false; // Não há refresh token para usar
    }

    try {
      final response = await _authService.refreshToken(_refreshToken!);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = json.decode(response.body);
        if (data.containsKey('access_token')) {
          // Atualiza apenas o token de acesso (o refresh token geralmente não muda)
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('accessToken', data['access_token']);
          _accessToken = data['access_token'];
          // Após renovar, garante que o UserExamsProvider seja inicializado novamente
          // caso o accessToken estivesse nulo e o _userId ainda fosse válido.
          if (_userId != null && _userId!.isNotEmpty) {
             await _userExamsProvider.initializeForUser(_userId);
          }
          notifyListeners();
          return true; // Sucesso
        }
      }
      // Se a renovação falhou, limpa o token (o usuário terá que logar novamente)
      await logout(); 
      return false; 
    } catch (e) {
      // Se a renovação falhou por erro de rede ou outro problema, limpa o token
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