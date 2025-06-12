import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._internal();
  final Connectivity _connectivity = Connectivity();
  StreamController<bool> connectionStatusController =
      StreamController<bool>.broadcast();

  factory ConnectivityService() {
    return _instance;
  }

  ConnectivityService._internal() {
    // Initialize the connection status
    _checkConnectionStatus();

    // Listen for connectivity changes
    _connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      _checkConnectionStatus();
    });
  }

  Future<void> _checkConnectionStatus() async {
    final ConnectivityResult result = await _connectivity.checkConnectivity();
    bool isConnected = result != ConnectivityResult.none;
    connectionStatusController.add(isConnected);
  }

  void showConnectivitySnackBar(BuildContext context, bool isConnected) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isConnected ? Icons.wifi : Icons.wifi_off,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            Text(isConnected ? 'Back online' : 'No internet connection'),
          ],
        ),
        backgroundColor: isConnected ? Colors.green : Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void dispose() {
    connectionStatusController.close();
  }
}
