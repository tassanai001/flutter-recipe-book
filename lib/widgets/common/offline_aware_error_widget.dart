import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recipe_book/providers/providers.dart';
import 'package:recipe_book/utils/constants.dart';

/// A widget that displays appropriate error messages based on connectivity status
class OfflineAwareErrorWidget extends ConsumerWidget {
  /// The error message to display when online
  final String onlineMessage;
  
  /// Optional callback function when retry button is pressed
  final VoidCallback? onRetry;
  
  /// Optional icon to display for online errors
  final IconData onlineIcon;
  
  /// Optional icon to display for offline errors
  final IconData offlineIcon;
  
  /// Whether to show cached data button when offline
  final bool showCachedDataButton;
  
  /// Callback when user wants to view cached data
  final VoidCallback? onViewCachedData;

  const OfflineAwareErrorWidget({
    super.key,
    this.onlineMessage = AppConstants.generalErrorMessage,
    this.onRetry,
    this.onlineIcon = Icons.error_outline,
    this.offlineIcon = Icons.wifi_off_rounded,
    this.showCachedDataButton = true,
    this.onViewCachedData,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectionStatus = ref.watch(connectionStatusProvider);
    
    return connectionStatus.when(
      data: (isConnected) {
        if (isConnected) {
          return _buildOnlineErrorWidget(context);
        } else {
          return _buildOfflineErrorWidget(context);
        }
      },
      loading: () => _buildOnlineErrorWidget(context),
      error: (_, __) => _buildOnlineErrorWidget(context),
    );
  }

  /// Build the error widget for online state
  Widget _buildOnlineErrorWidget(BuildContext context) {
    final theme = Theme.of(context);
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              onlineIcon,
              size: 64,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            Text(
              onlineMessage,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: AppConstants.defaultPadding),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Build the error widget for offline state
  Widget _buildOfflineErrorWidget(BuildContext context) {
    final theme = Theme.of(context);
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              offlineIcon,
              size: 64,
              color: theme.colorScheme.tertiary,
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            Text(
              'You are offline',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Please check your internet connection and try again.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            if (onRetry != null)
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                ),
              ),
            if (showCachedDataButton && onViewCachedData != null) ...[
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: onViewCachedData,
                icon: const Icon(Icons.offline_bolt_outlined),
                label: const Text('View Cached Data'),
                style: TextButton.styleFrom(
                  foregroundColor: theme.colorScheme.secondary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
