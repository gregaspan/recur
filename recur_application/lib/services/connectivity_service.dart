import 'dart:async';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

class ConnectivityService with ChangeNotifier {
  bool _isConnected = true;

  bool get isConnected => _isConnected;

  late StreamSubscription _subscription;

  ConnectivityService() {
    _initialize();
  }

  void _initialize() {
    _subscription = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) async {
      bool previousStatus = _isConnected;
      _isConnected = await InternetConnectionChecker().hasConnection;

      if (previousStatus != _isConnected) {
        notifyListeners();
      }
    });

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