import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart'; 
import 'services/notification_service.dart'; 

import 'providers/auth_provider.dart';
import 'providers/user_exams_provider.dart';
import 'screens/home_screen.dart';
// 🟢 IMPORTANTE: Importar a tela principal para o redirecionamento
import 'screens/Saude_Homem_Screen.dart'; 
import 'models/exam.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(); 
  NotificationService().showLocalNotification(message);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
  await Hive.initFlutter();
  Hive.registerAdapter(ExamAdapter());
  Hive.registerAdapter(ExamDayAdapter());
  await Hive.openBox<Exam>('exams_box'); 

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProxyProvider<AuthProvider, UserExamsProvider>(
          create: (context) => UserExamsProvider(),
          update: (context, auth, userExams) {
            if (userExams == null) throw ArgumentError.notNull('userExams');
            userExams.initializeForUser(auth.userId);
            return userExams;
          },
        ),
      ],
      child: MaterialApp(
        title: 'CheckMen',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF007BFF),
            primary: const Color(0xFF007BFF),
            secondary: const Color(0xFF3B489A),
            surface: const Color(0xFFF8F9FA),
          ),
          
          // Estilo padrão dos Cards
          cardTheme: CardThemeData(
            elevation: 2,
            shadowColor: Colors.black.withOpacity(0.1),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            color: Colors.white,
          ),
          
          // Estilo padrão dos Botões
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              textStyle: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          
          // Estilo da AppBar
          appBarTheme: const AppBarTheme(
            centerTitle: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            scrolledUnderElevation: 0,
            iconTheme: IconThemeData(color: Colors.white),
          ),
        ),
        
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('pt', 'BR'),
        ],
        // 🟢 MUDANÇA AQUI: Usamos um Wrapper para decidir qual tela mostrar
        home: const AuthWrapper(),
      ),
    );
  }
}

// 🟢 NOVO WIDGET: Decide para onde o usuário vai
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, child) {
        // 1. Se ainda está carregando os dados do disco, mostra loading
        if (auth.isAuthLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // 2. Se já carregou e tem usuário logado (token existe), vai pro app
        if (auth.isAuthenticated) {
          return const SaudeHomemScreen();
        }

        // 3. Se não tem usuário, vai pro Login
        return const HomeScreen();
      },
    );
  }
}