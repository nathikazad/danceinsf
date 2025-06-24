import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:web/web.dart' as web;
import 'package:dance_sf/utils/app_storage.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
    final l10n = AppLocalizations.of(context)!;
    final String userAgent = web.window.navigator.userAgent.toLowerCase();
    print(userAgent);
    final bool isMobile = userAgent.contains('android') || 
                         userAgent.contains('iphone') || 
                         userAgent.contains('ipad');
    if (!isMobile) return const SizedBox.shrink();
    if (AppStorage.zone != 'San Francisco') return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      color: Theme.of(context).colorScheme.primary,
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            l10n.downloadBanner,
            style: TextStyle(color: Colors.white, fontSize: 13),
          ),
          const SizedBox(width: 8),
          _buildDownloadButton(context),
        ],
      ),
    );
  }

  Widget _buildDownloadButton(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return TextButton(
      onPressed: () {
        final String userAgent = web.window.navigator.userAgent.toLowerCase();
        final String url = userAgent.contains('iphone') || userAgent.contains('ipad')
            ? 'https://apps.apple.com/us/app/dance-sf/id6746145378'
            : 'https://play.google.com/store/apps/details?id=com.dancesf.app';
        // show snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${l10n.downloadingSnackbar} $url')),
        );
        launchUrl(Uri.parse(url));
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
      child: Text(
        l10n.downloadButton,
        style: TextStyle(fontSize: 13),
      ),
    );
  }
} 