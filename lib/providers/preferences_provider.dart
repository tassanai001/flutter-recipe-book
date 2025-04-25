import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recipe_book/data/local/preferences_storage.dart';

/// Provider for the preferences storage service
final preferencesStorageProvider = Provider<PreferencesStorage>((ref) {
  return PreferencesStorage();
});

/// Provider to check if the user has seen the onboarding
final hasSeenOnboardingProvider = FutureProvider<bool>((ref) async {
  final preferencesStorage = ref.watch(preferencesStorageProvider);
  return preferencesStorage.hasSeenOnboarding();
});
