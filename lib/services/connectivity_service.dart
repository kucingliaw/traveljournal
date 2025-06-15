import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._internal();
  final Connectivity _connectivity = Connectivity();
  StreamController<bool> connectionStatusController =
      StreamController<bool>.broadcast();
  ScaffoldFeatureController<SnackBar, SnackBarClosedReason>? _snackBarController;
  bool _lastStatus = true; // Assume online at start

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

    // Only react if status changed
    if (_lastStatus == isConnected) return;
    _lastStatus = isConnected;

    // Remove previous snackbar if any
    _snackBarController?.close();

    if (!isConnected) {
      // Show persistent red snackbar
      _snackBarController = ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.wifi_off, color: Colors.white),
              SizedBox(width: 8),
              Text('No internet connection'),
            ],
          ),
          backgroundColor: Colors.red,
          duration: Duration(days: 1), // Effectively persistent
        ),
      );
    } else {
      // Show green snackbar for 2 seconds
      _snackBarController = ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.wifi, color: Colors.white),
              SizedBox(width: 8),
              Text('Back online'),
            ],
          ),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void dispose() {
    connectionStatusController.close();
  }
}
