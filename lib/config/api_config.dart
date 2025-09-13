class ApiConfig {
  static const String baseUrl = 'http://localhost:8000';

  // Auth Endpoints
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String resetPassword = '/auth/reset-password';
  static const String verifySecurityWord = '/auth/verify-security-word';
  static const String refreshToken = '/auth/refresh-token';
}

// para fucionar no celular
// uvicorn app.main:app --reload --host 0.0.0.0
// 'http://SEU_IP_AQUI:8000';
// ipconfig