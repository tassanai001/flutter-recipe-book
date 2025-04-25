import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recipe_book/providers/tips_provider.dart';
import 'package:recipe_book/utils/constants.dart';

/// A widget that displays a tip card with a title, description, and dismiss button
class TipCard extends ConsumerWidget {
  final AppTip tip;
  final VoidCallback? onDismiss;

  const TipCard({
    super.key,
    required this.tip,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    
    return Card(
      margin: const EdgeInsets.all(AppConstants.defaultPadding),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
          border: Border.all(
            color: theme.colorScheme.primary.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with icon and dismiss button
              Row(
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Tip',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  if (tip.isDismissible)
                    IconButton(
                      icon: const Icon(Icons.close, size: 18),
                      onPressed: () {
                        ref.read(tipsProvider.notifier).dismissTip(tip.id);
                        if (onDismiss != null) {
                          onDismiss!();
                        }
                      },
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Tip title
              Text(
                tip.title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              
              // Tip description
              Text(
                tip.description,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A widget that displays all tips for a specific screen
class ScreenTips extends ConsumerWidget {
  final String screen;
  
  const ScreenTips({
    super.key,
    required this.screen,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tips = ref.watch(screenTipsProvider(screen));
    
    if (tips.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Column(
      children: tips.map((tip) => TipCard(tip: tip)).toList(),
    );
  }
}
