import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'providers/auth_provider.dart';
import 'providers/user_exams_provider.dart';
import 'screens/home_screen.dart';
import 'models/exam.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Hive.initFlutter();
  Hive.registerAdapter(ExamAdapter());
  Hive.registerAdapter(ExamDayAdapter());

  // Abra a Box para ExamDays (existente)
  // Box<ExamDay> userExamsBox = await Hive.openBox<ExamDay>('user_exams'); // Esta será aberta no provider agora
  
  // ABRA UMA NOVA BOX PARA OS EXAMES INDIVIDUAIS
  await Hive.openBox<Exam>('exams_box'); // <--- NOVA LINHA

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