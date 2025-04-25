import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recipe_book/utils/connectivity_service.dart';

/// Provider for the connectivity service
final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  final service = ConnectivityService();
  
  // Dispose the service when the provider is disposed
  ref.onDispose(() {
    service.dispose();
  });
  
  return service;
});

/// Provider that exposes the current connection status
final connectionStatusProvider = StreamProvider<bool>((ref) {
  final connectivityService = ref.watch(connectivityServiceProvider);
  return connectivityService.connectionStatus;
});

/// Provider to check if the device is currently connected
final isConnectedProvider = FutureProvider<bool>((ref) async {
  final connectivityService = ref.watch(connectivityServiceProvider);
  return connectivityService.isConnected();
});
