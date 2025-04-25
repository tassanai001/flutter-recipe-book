import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Service to monitor and manage network connectivity status
class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  final StreamController<bool> _connectionStatusController = StreamController<bool>.broadcast();

  /// Stream of connectivity status (true = connected, false = disconnected)
  Stream<bool> get connectionStatus => _connectionStatusController.stream;

  ConnectivityService() {
    // Initialize with the current connection status
    _checkConnectionStatus();
    
    // Listen for connectivity changes
    _connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      _handleConnectivityChange(result);
    });
  }

  /// Check the current connection status
  Future<void> _checkConnectionStatus() async {
    final ConnectivityResult result = await _connectivity.checkConnectivity();
    _handleConnectivityChange(result);
  }

  /// Handle connectivity change events
  void _handleConnectivityChange(ConnectivityResult result) {
    final bool isConnected = result != ConnectivityResult.none;
    _connectionStatusController.add(isConnected);
  }

  /// Check if the device is currently connected to the internet
  Future<bool> isConnected() async {
    final ConnectivityResult result = await _connectivity.checkConnectivity();
    return result != ConnectivityResult.none;
  }

  /// Dispose resources
  void dispose() {
    _connectionStatusController.close();
  }
}
