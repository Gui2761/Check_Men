// gui2761/check_men/Check_Men-e15d1b7f40dd23def6eca51b303d67d10e1cbdd7/lib/services/notification_service.dart

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// ✅ CORREÇÃO FINAL: Importação relativa. O arquivo auth_service.dart está na mesma pasta.
import 'auth_service.dart'; 

// ----------------------------------------------------------------------
// 1. Handler para mensagens com o APP FECHADO (Terminated/Background)
// ----------------------------------------------------------------------
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Nota: Inicialização do Firebase aqui para handlers de background
  print("Handling a background message: ${message.messageId}");

  if (message.notification != null) {
    NotificationService().showLocalNotification(message);
  }
}

class NotificationService {
  // Singleton Pattern
  NotificationService._internal();
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;

  final _firebaseMessaging = FirebaseMessaging.instance;
  final _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  
  // Instância do AuthService para comunicação com o backend
  final _authService = AuthService(); // Agora importado corretamente


  // 🟢 MODIFICADO: Retorna o Token FCM para ser enviado ao backend
  Future<String?> initializeAndGetToken(String? accessToken) async {
    // 1. Configurar o handler de background
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // 2. Solicitar permissões
    await _requestPermission();

    // 3. Configurar Local Notifications (para Foreground)
    await _setupLocalNotifications();

    // 4. Configurar os Listeners
    _setupMessageHandlers();
    
    // 5. Obter o Token FCM
    final token = await _firebaseMessaging.getToken();
    print('FCM Token: $token');
    
    // 6. Enviar o token para o backend Imediatamente
    if (token != null && accessToken != null) {
        try {
            // Usa o novo token de acesso obtido no login
            await _authService.registerDeviceToken(token, accessToken); 
            print('Token FCM enviado com sucesso ao backend.');
        } catch(e) {
            print('Erro ao registrar token FCM no backend durante a inicialização: $e');
        }
    }
    
    return token;
  }

  Future<void> _requestPermission() async {
    await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  Future<void> _setupLocalNotifications() async {
    const androidInitializationSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher', // Use o ícone do seu app
    );
    const iosInitializationSettings = DarwinInitializationSettings();
    const initializationSettings = InitializationSettings(
      android: androidInitializationSettings,
      iOS: iosInitializationSettings,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        print('Notification tapped with payload: ${response.payload}');
      },
    );
  }

  void _setupMessageHandlers() {
    // Handler para mensagens com o APP ABERTO (Foreground)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');

      if (message.notification != null) {
        showLocalNotification(message);
      }
    });

    // Handler para mensagens com o APP EM SEGUNDO PLANO/TERMINADO (quando o usuário clica)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('A new onMessageOpenedApp event was published! Navigating...');
    });

    _firebaseMessaging.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        print('App launched from terminated state via notification! Navigating...');
      }
    });
  }

  // Função auxiliar para exibir a notificação no Foreground/Background (com Data Messages)
  void showLocalNotification(RemoteMessage message) {
    if (message.notification == null) return;

    const androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'high_importance_channel',
      'Notificações de Exames',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );
    const iosPlatformChannelSpecifics = DarwinNotificationDetails();
    const platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iosPlatformChannelSpecifics,
    );

    // Exibe a notificação local
    _flutterLocalNotificationsPlugin.show(
      message.hashCode, // ID único
      message.notification!.title,
      message.notification!.body,
      platformChannelSpecifics,
      payload: message.data.toString(), 
    );
  }
}