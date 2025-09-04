import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  
  bool _isLoginBoxVisible = false;
  bool _isRegistrationBoxVisible = false;
  bool _isForgotPasswordBoxVisible = false;
  bool _isNewPasswordBoxVisible = false;
  bool _isLoading = false;
  
  bool get isLoginBoxVisible => _isLoginBoxVisible;
  bool get isRegistrationBoxVisible => _isRegistrationBoxVisible;
  bool get isForgotPasswordBoxVisible => _isForgotPasswordBoxVisible;
  bool get isNewPasswordBoxVisible => _isNewPasswordBoxVisible;
  bool get isLoading => _isLoading;

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
  
  Future<http.Response> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _authService.login(email, password);
      return response;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<http.Response> register(String email, String password, String recoveryPhrase) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _authService.register(email, password, recoveryPhrase);
      return response;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<http.Response> forgotPassword(String recoveryPhrase) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _authService.forgotPassword(recoveryPhrase);
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