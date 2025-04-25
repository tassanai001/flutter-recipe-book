import 'package:flutter/material.dart';
import 'package:recipe_book/utils/constants.dart';

/// A reusable empty state widget that provides a consistent UI for empty states
class EmptyState extends StatelessWidget {
  /// The icon to display
  final IconData icon;
  
  /// The title text to display
  final String title;
  
  /// The message text to display
  final String message;
  
  /// Optional action button
  final Widget? actionButton;
  
  /// Optional color for the icon
  final Color? iconColor;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionButton,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.largePadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 80,
              color: iconColor ?? theme.colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            Text(
              title,
              style: theme.textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.smallPadding),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            if (actionButton != null) ...[
              const SizedBox(height: AppConstants.largePadding),
              actionButton!,
            ],
          ],
        ),
      ),
    );
  }
}

/// A reusable error state widget that provides a consistent UI for error states
class ErrorState extends StatelessWidget {
  /// The error message to display
  final String message;
  
  /// Callback function when the retry button is pressed
  final VoidCallback? onRetry;

  const ErrorState({
    super.key,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.largePadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: theme.colorScheme.error.withOpacity(0.7),
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            Text(
              'Something Went Wrong',
              style: theme.textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.smallPadding),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: AppConstants.largePadding),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
