import 'package:flutter/material.dart';
import 'screens/habits_screen.dart';
import 'screens/progress/progress_screen.dart';

void main() {
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