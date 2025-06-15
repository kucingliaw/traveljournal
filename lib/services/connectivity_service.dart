import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

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

  void dispose() {
    connectionStatusController.close();
  }
}
