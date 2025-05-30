import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';

/// A utility class for caching API responses to improve performance
/// and reduce network requests
class ApiCacheManager {
  static const String _cachePrefix = 'api_cache_';
  static const Duration _defaultCacheDuration = Duration(hours: 1);
  
  final Logger _logger = Logger();
  
  /// Singleton instance
  static final ApiCacheManager _instance = ApiCacheManager._internal();
  factory ApiCacheManager() => _instance;
  
  /// Whether we're running in test mode (no actual SharedPreferences access)
  bool _testMode = false;
  
  /// In-memory cache for test mode
  final Map<String, String> _memoryCache = {};
  
  ApiCacheManager._internal();
  
  /// Enable test mode to avoid SharedPreferences access in tests
  void enableTestMode() {
    _testMode = true;
  }
  
  /// Cache an API response
  /// [key] - Unique key for the cached data
  /// [data] - Data to cache
  /// [duration] - How long to keep the cache valid
  Future<bool> cacheData(
    String key, 
    dynamic data, {
    Duration duration = _defaultCacheDuration,
  }) async {
    try {
      final cacheEntry = CacheEntry(
        data: data,
        timestamp: DateTime.now(),
        expiryDuration: duration,
      );
      
      final cacheString = jsonEncode(cacheEntry.toJson());
      
      if (_testMode) {
        // In test mode, store in memory
        _memoryCache[_getCacheKey(key)] = cacheString;
        return true;
      }
      
      // In normal mode, use SharedPreferences
      try {
        final prefs = await SharedPreferences.getInstance();
        final success = await prefs.setString(
          _getCacheKey(key),
          cacheString,
        );
        
        _logger.d('Cached data for key: $key, success: $success');
        return success;
      } catch (e) {
        // If SharedPreferences fails, log and continue without caching
        _logger.e('Error caching data: $e');
        return false;
      }
    } catch (e) {
      _logger.e('Error caching data: $e');
      return false;
    }
  }
  
  /// Get cached data if it exists and is still valid
  /// [key] - Unique key for the cached data
  /// Returns null if cache doesn't exist or is expired
  Future<dynamic> getCachedData(String key) async {
    try {
      String? cachedString;
      
      if (_testMode) {
        // In test mode, get from memory
        cachedString = _memoryCache[_getCacheKey(key)];
      } else {
        // In normal mode, use SharedPreferences
        try {
          final prefs = await SharedPreferences.getInstance();
          cachedString = prefs.getString(_getCacheKey(key));
        } catch (e) {
          // If SharedPreferences fails, log and continue as if no cache exists
          _logger.e('Error retrieving cached data: $e');
          return null;
        }
      }
      
      if (cachedString == null) {
        _logger.d('No cache found for key: $key');
        return null;
      }
      
      final cacheEntry = CacheEntry.fromJson(jsonDecode(cachedString));
      
      // Check if cache is expired
      if (cacheEntry.isExpired()) {
        _logger.d('Cache expired for key: $key');
        await invalidateCache(key);
        return null;
      }
      
      _logger.d('Retrieved valid cache for key: $key');
      return cacheEntry.data;
    } catch (e) {
      _logger.e('Error retrieving cached data: $e');
      return null;
    }
  }
  
  /// Invalidate a specific cache entry
  Future<bool> invalidateCache(String key) async {
    try {
      if (_testMode) {
        // In test mode, remove from memory
        _memoryCache.remove(_getCacheKey(key));
        return true;
      }
      
      // In normal mode, use SharedPreferences
      try {
        final prefs = await SharedPreferences.getInstance();
        final success = await prefs.remove(_getCacheKey(key));
        _logger.d('Invalidated cache for key: $key, success: $success');
        return success;
      } catch (e) {
        // If SharedPreferences fails, log and continue
        _logger.e('Error invalidating cache: $e');
        return false;
      }
    } catch (e) {
      _logger.e('Error invalidating cache: $e');
      return false;
    }
  }
  
  /// Clear all cached API responses
  Future<bool> clearAllCache() async {
    try {
      if (_testMode) {
        // In test mode, clear memory cache
        _memoryCache.clear();
        return true;
      }
      
      // In normal mode, use SharedPreferences
      try {
        final prefs = await SharedPreferences.getInstance();
        final allKeys = prefs.getKeys();
        final cacheKeys = allKeys.where((key) => key.startsWith(_cachePrefix));
        
        for (final key in cacheKeys) {
          await prefs.remove(key);
        }
        
        _logger.d('Cleared all API cache entries: ${cacheKeys.length}');
        return true;
      } catch (e) {
        // If SharedPreferences fails, log and continue
        _logger.e('Error clearing all cache: $e');
        return false;
      }
    } catch (e) {
      _logger.e('Error clearing all cache: $e');
      return false;
    }
  }
  
  /// Generate a cache key with prefix
  String _getCacheKey(String key) => '$_cachePrefix$key';
}

/// Model class for a cache entry
class CacheEntry {
  final dynamic data;
  final DateTime timestamp;
  final Duration expiryDuration;
  
  CacheEntry({
    required this.data,
    required this.timestamp,
    required this.expiryDuration,
  });
  
  /// Check if the cache entry is expired
  bool isExpired() {
    final now = DateTime.now();
    return now.difference(timestamp) > expiryDuration;
  }
  
  /// Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'data': data,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'expiryDuration': expiryDuration.inMilliseconds,
    };
  }
  
  /// Create from JSON storage
  factory CacheEntry.fromJson(Map<String, dynamic> json) {
    return CacheEntry(
      data: json['data'],
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp']),
      expiryDuration: Duration(milliseconds: json['expiryDuration']),
    );
  }
}
