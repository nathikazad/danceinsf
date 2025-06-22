import 'package:flutter/foundation.dart';
import 'package:app_links/app_links.dart';
import 'dart:async';

class UniLinksHandler {
  static StreamSubscription? _linkSubscription;

  static Future<void> initialize({
    required Function(String link, bool initial) onLinkReceived,
  }) async {
    if (!kIsWeb) {
      // Handle links that opened the app from a terminated state
      try {
        final initialUri = await AppLinks().getInitialLink();
        if (initialUri != null) {
          onLinkReceived(initialUri.toString(), true);
        }
      } catch (e) {
        print('Failed to get initial link: $e');
      }

      // Handle links that opened the app from a background state
      _linkSubscription = AppLinks().uriLinkStream.listen((Uri? uri) {
        if (uri != null) {
          onLinkReceived(uri.toString(), false);
        }
      }, onError: (err) {
        print('Failed to receive link: $err');
      });
    } else {
      // For web platform, handle the initial URL
      final uri = Uri.base;
      print('Initial web URL: ${uri.toString()}');
      if (uri.path != '/') {
        onLinkReceived(uri.toString(), true);
      }
    }
  }

  static void dispose() {
    _linkSubscription?.cancel();
  }

  static String? parseLink(String link) {
    final uri = Uri.parse(link);
    if (uri.host == 'wheredothey.dance' || uri.host == 'localhost') {
      // Clean up the URL by removing the hash fragment
      return uri.path.split('#')[0];
    }
    return null;
  }
} 