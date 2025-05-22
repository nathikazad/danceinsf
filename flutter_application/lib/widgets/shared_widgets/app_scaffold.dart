import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

class AppScaffold extends StatelessWidget {
  final Widget child;

  const AppScaffold({
    required this.child,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const DownloadBanner(),
          Expanded(child: child),
        ],
      ),
    );
  }
} 

class DownloadBanner extends StatelessWidget {
  const DownloadBanner({super.key});

  @override
  Widget build(BuildContext context) {
    // Only show on web platform
    if (!kIsWeb) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      color: Theme.of(context).colorScheme.primary,
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'For faster experience',
            style: TextStyle(color: Colors.white, fontSize: 13),
          ),
          const SizedBox(width: 8),
          _buildDownloadButton(context),
        ],
      ),
    );
  }

  Widget _buildDownloadButton(BuildContext context) {
    return TextButton(
      onPressed: () {

        launchUrl(Uri.parse('https://play.google.com/store/apps/details?id=com.dancesf.app'));
      },
      style: TextButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Theme.of(context).colorScheme.primary,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(2),
        ),
      ),
      child: const Text(
        'Download App',
        style: TextStyle(fontSize: 13),
      ),
    );
  }
} 