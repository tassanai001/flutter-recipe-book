import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/providers.dart';
import '../../providers/theme_provider.dart';
import '../../utils/constants.dart';
import '../../utils/image_utils.dart';

/// Settings screen that allows users to change app preferences
/// such as theme and clear favorites
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.watch(themeProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.settingsScreenTitle),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        children: [
          // Theme section
          _buildSectionHeader(context, 'Appearance'),
          const SizedBox(height: AppConstants.smallPadding),
          _buildThemeSelector(context, ref, currentTheme),
          
          const SizedBox(height: AppConstants.largePadding),
          
          // Data management section
          _buildSectionHeader(context, 'Data Management'),
          const SizedBox(height: AppConstants.smallPadding),
          _buildClearFavoritesButton(context, ref),
          const SizedBox(height: AppConstants.smallPadding),
          _buildClearImageCacheButton(context, ref),
          
          const SizedBox(height: AppConstants.largePadding),
          
          // App info section
          _buildSectionHeader(context, 'About'),
          const SizedBox(height: AppConstants.smallPadding),
          _buildAboutInfo(context),
        ],
      ),
    );
  }
  
  /// Builds a section header with the given title
  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }
  
  /// Builds the theme selector with system, light, and dark options
  Widget _buildThemeSelector(BuildContext context, WidgetRef ref, ThemeMode currentTheme) {
    return Card(
      elevation: AppConstants.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.smallPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              title: const Text('System Theme'),
              subtitle: const Text('Follow system settings'),
              leading: const Icon(Icons.brightness_auto),
              selected: currentTheme == ThemeMode.system,
              onTap: () => ref.read(themeProvider.notifier).setThemeMode(ThemeMode.system),
              trailing: currentTheme == ThemeMode.system 
                ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary) 
                : null,
            ),
            const Divider(),
            ListTile(
              title: const Text('Light Theme'),
              subtitle: const Text('Always use light theme'),
              leading: const Icon(Icons.brightness_5),
              selected: currentTheme == ThemeMode.light,
              onTap: () => ref.read(themeProvider.notifier).setThemeMode(ThemeMode.light),
              trailing: currentTheme == ThemeMode.light 
                ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary) 
                : null,
            ),
            const Divider(),
            ListTile(
              title: const Text('Dark Theme'),
              subtitle: const Text('Always use dark theme'),
              leading: const Icon(Icons.brightness_4),
              selected: currentTheme == ThemeMode.dark,
              onTap: () => ref.read(themeProvider.notifier).setThemeMode(ThemeMode.dark),
              trailing: currentTheme == ThemeMode.dark 
                ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary) 
                : null,
            ),
          ],
        ),
      ),
    );
  }
  
  /// Builds the clear favorites button with confirmation dialog
  Widget _buildClearFavoritesButton(BuildContext context, WidgetRef ref) {
    return Card(
      elevation: AppConstants.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.smallPadding),
        child: ListTile(
          title: const Text('Clear Favorites'),
          subtitle: const Text('Remove all saved favorite recipes'),
          leading: const Icon(Icons.delete_outline, color: AppConstants.errorColor),
          onTap: () => _showClearFavoritesDialog(context, ref),
        ),
      ),
    );
  }
  
  /// Shows a confirmation dialog before clearing favorites
  void _showClearFavoritesDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Favorites?'),
        content: const Text(
          'This will remove all your favorite recipes. This action cannot be undone.'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              
              try {
                // Show loading indicator
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Clearing favorites...'))
                );
                
                // Clear favorites
                await ref.read(clearFavoritesProvider)();
                
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('All favorites cleared'))
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: ${e.toString()}'))
                  );
                }
              }
            },
            child: const Text('CLEAR', style: TextStyle(color: AppConstants.errorColor)),
          ),
        ],
      ),
    );
  }
  
  /// Builds the clear image cache button with confirmation dialog
  Widget _buildClearImageCacheButton(BuildContext context, WidgetRef ref) {
    return Card(
      elevation: AppConstants.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.smallPadding),
        child: ListTile(
          title: const Text('Clear Image Cache'),
          subtitle: const Text('Free up storage space by clearing cached images'),
          leading: const Icon(Icons.image_not_supported_outlined, color: Colors.orange),
          onTap: () => _showClearImageCacheDialog(context, ref),
        ),
      ),
    );
  }
  
  /// Shows a confirmation dialog before clearing image cache
  void _showClearImageCacheDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Image Cache?'),
        content: const Text(
          'This will clear all cached images. Images will be re-downloaded when needed.'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              
              try {
                // Show loading indicator
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Clearing image cache...'))
                );
                
                // Clear image cache
                await ref.read(imageCacheProvider).clearCache();
                
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Image cache cleared'))
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: ${e.toString()}'))
                  );
                }
              }
            },
            child: const Text('CLEAR', style: TextStyle(color: Colors.orange)),
          ),
        ],
      ),
    );
  }
  
  /// Builds the about app information section
  Widget _buildAboutInfo(BuildContext context) {
    return Card(
      elevation: AppConstants.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppConstants.appName,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppConstants.smallPadding),
            const Text(
              'A recipe browsing app built with Flutter and TheMealDB API. '
              'Browse, search, and save your favorite recipes.',
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            const Text('Data provided by TheMealDB'),
            const SizedBox(height: AppConstants.smallPadding),
            OutlinedButton(
              onPressed: () {
                // Open TheMealDB website or show more info
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('TheMealDB API - www.themealdb.com'))
                );
              },
              child: const Text('Visit TheMealDB'),
            ),
          ],
        ),
      ),
    );
  }
}
