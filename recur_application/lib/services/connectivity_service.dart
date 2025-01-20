// connectivity_service.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

class ConnectivityService with ChangeNotifier {
  // Current connectivity status
  bool _isConnected = true;

  bool get isConnected => _isConnected;

  // Stream subscription
  late StreamSubscription _subscription;

  ConnectivityService() {
    _initialize();
  }

  void _initialize() {
    // Listen to connectivity changes
    _subscription = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) async {
      // Check for actual internet access
      bool previousStatus = _isConnected;
      _isConnected = await InternetConnectionChecker().hasConnection;

      // Notify listeners only if status changed
      if (previousStatus != _isConnected) {
        notifyListeners();
      }
    });

    // Initial check
    _checkInitialConnection();
  }

  Future<void> _checkInitialConnection() async {
    _isConnected = await InternetConnectionChecker().hasConnection;
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}