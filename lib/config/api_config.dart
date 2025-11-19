class ApiConfig {
  static const String baseUrl = 'http://192.168.1.100:8000'; // Seu IP configurado

  // Auth Endpoints
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String resetPassword = '/auth/reset-password';
  static const String verifySecurityWord = '/auth/verify-security-word';
  static const String refreshToken = '/auth/refresh-token';
  static const String registerDeviceToken = '/auth/device-token';

  // 🟢 Endpoint de agendamento de notificações
  static const String scheduleExam = '/auth/schedule-exam-test';

  // News Endpoint
  static const String rssNews = '/rss/';
}