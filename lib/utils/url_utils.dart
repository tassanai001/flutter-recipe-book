import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Utility class for handling URL operations
class UrlUtils {
  /// Launches a URL with error handling
  /// Returns true if the URL was launched successfully, false otherwise
  static Future<bool> launchUrlWithErrorHandling(
    String urlString, {
    required BuildContext context,
    LaunchMode mode = LaunchMode.externalApplication,
  }) async {
    try {
      final Uri url = Uri.parse(urlString);
      
      // Check if the URL can be launched
      if (await canLaunchUrl(url)) {
        return await launchUrl(url, mode: mode);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Could not open: $urlString'),
            ),
          );
        }
        return false;
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening URL: ${e.toString()}'),
          ),
        );
      }
      return false;
    }
  }
  
  /// Launches a YouTube video URL
  /// Automatically handles YouTube URLs in various formats
  static Future<bool> launchYouTubeVideo(
    String? youtubeUrl, {
    required BuildContext context,
  }) async {
    if (youtubeUrl == null || youtubeUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No video URL available for this recipe'),
        ),
      );
      return false;
    }
    
    return launchUrlWithErrorHandling(
      youtubeUrl,
      context: context,
      mode: LaunchMode.externalApplication,
    );
  }
}
