import 'package:flutter/material.dart';
import 'package:recipe_book/utils/constants.dart';

/// A reusable pull-to-refresh widget that wraps a child widget
/// and provides a consistent refresh experience across the app
class PullToRefreshWrapper extends StatelessWidget {
  /// The child widget to display
  final Widget child;
  
  /// Callback function when the user pulls to refresh
  final Future<void> Function() onRefresh;
  
  /// Optional empty state widget to display when there's no content
  final Widget? emptyState;
  
  /// Whether the content is empty and should show the empty state
  final bool isEmpty;

  const PullToRefreshWrapper({
    super.key,
    required this.child,
    required this.onRefresh,
    this.emptyState,
    this.isEmpty = false,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      displacement: AppConstants.defaultPadding,
      color: Theme.of(context).colorScheme.primary,
      backgroundColor: Theme.of(context).colorScheme.surface,
      strokeWidth: 3,
      child: isEmpty && emptyState != null
          ? _wrapEmptyState(emptyState!)
          : child,
    );
  }

  /// Wraps the empty state widget in a scrollable container
  /// to ensure the refresh indicator can be triggered
  Widget _wrapEmptyState(Widget emptyState) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: SizedBox(
        height: 600, // Minimum height to allow pull-to-refresh
        child: emptyState,
      ),
    );
  }
}
