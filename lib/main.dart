// gui2761/check_men/Check_Men-e15d1b7f40dd23def6eca51b303d67d10e1cbdd7/lib/main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

// 🟢 NOVAS IMPORTAÇÕES DO FIREBASE E SERVIÇO
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart'; 
import 'services/notification_service.dart'; 

import 'providers/auth_provider.dart';
import 'providers/user_exams_provider.dart';
import 'screens/home_screen.dart';
import 'models/exam.dart';

// Handler de background de nível superior (usado no NotificationService)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(); 
  NotificationService().showLocalNotification(message);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 🟢 INICIALIZAÇÃO DO FIREBASE (CRÍTICO)
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
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('pt', 'BR'),
        ],
        home: const HomeScreen(),
      ),
    );
  }
}