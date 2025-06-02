import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class EventDetailRow extends StatelessWidget {
  final Widget icon;
  final String text;
  final String? linkUrl;
  const EventDetailRow({
    required this.icon,
    required this.text,
    this.linkUrl,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                color: Theme.of(context).colorScheme.secondaryContainer),
            child: icon,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: linkUrl != null ? () => _launchUrl(context, linkUrl!) : null,
              child: Text(
                text,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: linkUrl != null 
                    ? Theme.of(context).colorScheme.primary 
                    : null,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launchUrl(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open link')),
        );
      }
    }
  }
}
