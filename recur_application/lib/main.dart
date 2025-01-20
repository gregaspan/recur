// lib/main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'screens/habit_detail_screen.dart';
import 'screens/habits_screen.dart';
import 'screens/progress/progress_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/hello_world_screen.dart';
import 'screens/challanges_screen.dart';
import 'services/connectivity_service.dart';
import 'services/theme_provider.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Enables asynchronous initialization

  // Firebase initialization with error handling
  try {
    await Firebase.initializeApp(
      // options: DefaultFirebaseOptions.currentPlatform, // Use if you have firebase_options.dart
    );
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
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeProvider>(
          create: (_) => ThemeProvider(),
        ),
        ChangeNotifierProvider<ConnectivityService>(
          create: (_) => ConnectivityService(),
        ),
      ],
      child: Consumer2<ThemeProvider, ConnectivityService>(
        builder: (context, themeProvider, connectivityService, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Habit Tracker',
            theme: ThemeData(
              brightness: themeProvider.isDarkMode
                  ? Brightness.dark
                  : Brightness.light,
              primarySwatch: Colors.blue,
            ),
            // Define the initial screen of the app
            initialRoute: '/',
            routes: {
              '/': (context) =>  HabitsScreen(), // Home screen
              '/progress': (context) =>  ProgressScreenMain(), // Progress screen
              '/challenges': (context) =>
                 ChallengesScreen(), // Challenges Screen Placeholder
              '/settings': (context) => const SettingsPage(),
            },
            builder: (context, child) {
              return Stack(
                children: [
                  child!, // The main Navigator
                  if (!connectivityService.isConnected)
                    const OfflineOverlay(),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class OfflineOverlay extends StatelessWidget {
  const OfflineOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        color: Colors.black54,
        child: Center(
          child: AlertDialog(
            title: const Text('No Internet Connection'),
            content: const Text(
                'Please connect to the internet (Wi-Fi or Mobile Data) to use the app.'),
            actions: [
              TextButton(
                child: const Text('Retry'),
                onPressed: () async {
                  final connectivityService =
                      Provider.of<ConnectivityService>(context, listen: false);
                  bool connected =
                      await InternetConnectionChecker().hasConnection;
                  if (connected) {
                    }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}