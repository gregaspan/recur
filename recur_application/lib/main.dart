import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/habits_screen.dart';
import 'screens/progress/progress_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Omogoči asinhrono inicializacijo
  await Firebase.initializeApp(); // Inicializacija Firebase
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Habit Tracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      // Določitev začetnega zaslona aplikacije
      initialRoute: '/',
      routes: {
        '/': (context) => HabitsScreen(), // Domača stran
        '/progress': (context) => ProgressScreenMain(), // Progress zaslon
        '/challenges': (context) => Placeholder(), // Challenges Screen Placeholder
        '/settings': (context) => Placeholder(),
      },
    );
  }
}