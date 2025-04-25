import 'package:shared_preferences/shared_preferences.dart';

/// Service class for managing app preferences in local storage using SharedPreferences
class PreferencesStorage {
  // Keys for preferences
  static const String _hasSeenOnboardingKey = 'has_seen_onboarding';
  static const String _dismissedTipsKey = 'dismissed_tips';

  /// Checks if the user has seen the onboarding screens
  Future<bool> hasSeenOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_hasSeenOnboardingKey) ?? false;
  }

  /// Marks the onboarding as seen
  Future<void> setOnboardingSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hasSeenOnboardingKey, true);
  }

  /// Resets the onboarding status (for testing purposes)
  Future<void> resetOnboardingStatus() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hasSeenOnboardingKey, false);
  }

  /// Gets the list of dismissed tips
  Future<List<String>> getDismissedTips() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_dismissedTipsKey) ?? [];
  }

  /// Saves the list of dismissed tips
  Future<void> saveDismissedTips(List<String> dismissedTips) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_dismissedTipsKey, dismissedTips);
  }
}
