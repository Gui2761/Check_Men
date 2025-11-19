class ApiConfig {
  static const String baseUrl = 'http://192.168.1.100:8000'; // Lembre-se de usar seu IP

  // Auth Endpoints
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String resetPassword = '/auth/reset-password';
  static const String verifySecurityWord = '/auth/verify-security-word';
  static const String refreshToken = '/auth/refresh-token';
  static const String registerDeviceToken = '/auth/device-token'; // 🟢 NOVO

  // News Endpoint
  static const String rssNews = '/rss/'; // <-- ADICIONE ESTA LINHA
}

// para fucionar no celular
// uvicorn app.main:app --reload --host 0.0.0.0
// 'http://SEU_IP_AQUI:8000';
// ipconfig
// venv\Scripts\activate http://localhost:8000