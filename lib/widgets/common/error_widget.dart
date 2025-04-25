import 'package:flutter/material.dart';
import '../../utils/constants.dart';

/// A reusable widget to display error states with an optional retry action
class AppErrorWidget extends StatelessWidget {
  /// The error message to display
  final String message;
  
  /// Optional callback function when retry button is pressed
  final VoidCallback? onRetry;
  
  /// Optional icon to display
  final IconData icon;

  const AppErrorWidget({
    super.key,
    this.message = AppConstants.generalErrorMessage,
    this.onRetry,
    this.icon = Icons.error_outline,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: AppConstants.defaultPadding),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
