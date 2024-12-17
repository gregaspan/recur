import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/habit_detail_screen.dart';
import 'screens/habits_screen.dart';
import 'screens/progress/progress_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Omogoči asinhrono inicializacijo

  // Firebase inicializacija z obravnavo morebitnih napak
  try {
    await Firebase.initializeApp();
    print("Firebase successfully initialized!");
  } catch (e, stacktrace) {
    print("Error initializing Firebase: $e");
    print("Stacktrace: $stacktrace");
  }

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