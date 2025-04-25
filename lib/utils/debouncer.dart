import 'dart:async';

import 'package:flutter/foundation.dart';

/// A utility class that helps to debounce user input
/// Useful for search functionality to avoid making API calls on every keystroke
class Debouncer {
  final Duration delay;
  Timer? _timer;

  Debouncer({this.delay = const Duration(milliseconds: 500)});

  /// Run the provided callback after the specified delay
  /// If run is called again before the delay has passed, the timer is reset
  void run(VoidCallback callback) {
    _timer?.cancel();
    _timer = Timer(delay, callback);
  }

  /// Cancel the timer if it's active
  void cancel() {
    _timer?.cancel();
  }
}
