import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:shimmer/shimmer.dart';

/// A custom cache manager for recipe images
/// This allows for more control over how images are cached
class RecipeImageCacheManager {
  static const key = 'recipeImageCache';
  static const int maxCacheSize = 200; // Maximum number of cached images
  static const Duration maxCacheAge = Duration(days: 7); // Cache duration

  static final RecipeImageCacheManager _instance = RecipeImageCacheManager._();
  factory RecipeImageCacheManager() => _instance;
  RecipeImageCacheManager._();

  final CacheManager cacheManager = CacheManager(
    Config(
      key,
      stalePeriod: maxCacheAge,
      maxNrOfCacheObjects: maxCacheSize,
      repo: JsonCacheInfoRepository(databaseName: key),
      fileService: HttpFileService(),
    ),
  );

  /// Clear the image cache
  Future<void> clearCache() async {
    await cacheManager.emptyCache();
  }
}

/// A utility class for optimized image loading
class OptimizedImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final bool useShimmerEffect;

  const OptimizedImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.useShimmerEffect = true,
  });

  @override
  Widget build(BuildContext context) {
    final imageWidget = CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      cacheManager: RecipeImageCacheManager().cacheManager,
      fadeInDuration: const Duration(milliseconds: 300),
      fadeOutDuration: const Duration(milliseconds: 300),
      memCacheWidth: _calculateMemCacheSize(width),
      memCacheHeight: _calculateMemCacheSize(height),
      placeholder: (context, url) => _buildPlaceholder(context),
      errorWidget: (context, url, error) => _buildErrorWidget(context),
    );

    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: borderRadius!,
        child: imageWidget,
      );
    }

    return imageWidget;
  }

  Widget _buildPlaceholder(BuildContext context) {
    if (useShimmerEffect) {
      return Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(
          width: width,
          height: height,
          color: Colors.white,
        ),
      );
    }

    return Container(
      width: width,
      height: height,
      color: Colors.grey[300],
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildErrorWidget(BuildContext context) {
    return Container(
      width: width,
      height: height,
      color: Colors.grey[200],
      child: const Center(
        child: Icon(
          Icons.broken_image,
          color: Colors.grey,
        ),
      ),
    );
  }

  /// Calculate the optimal memory cache size based on device pixel ratio
  int? _calculateMemCacheSize(double? dimension) {
    if (dimension == null) return null;
    
    // Get the device pixel ratio (defaults to 1.0 if not available)
    final pixelRatio = WidgetsBinding.instance.window.devicePixelRatio;
    
    // Calculate the cache size based on the dimension and pixel ratio
    // This helps optimize memory usage while maintaining image quality
    return (dimension * pixelRatio).round();
  }
}

/// Extension methods for image utilities
extension ImageUtilsExtension on String {
  /// Get a thumbnail version of the image URL if available
  /// This is useful for list views where smaller images are sufficient
  String get thumbnailVersion {
    // This is a placeholder implementation
    // In a real app, you might have a CDN that supports thumbnail generation
    // For example: https://yourcdn.com/image.jpg?width=200
    return this;
  }
}
