import 'package:flutter/material.dart';

class EventDetailRow extends StatelessWidget {
  final Widget icon;
  final String text;
  final String? linkText;
  final String? linkUrl;
  const EventDetailRow(
      {required this.icon,
      required this.text,
      this.linkText,
      this.linkUrl,
      super.key});

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
              child: Text(text, style: Theme.of(context).textTheme.titleSmall)),
          if (linkText != null && linkUrl != null)
            GestureDetector(
              onTap: () => _launchUrl(context, linkUrl!),
              child: Text(linkText!,
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 12)),
            ),
        ],
      ),
    );
  }

  void _launchUrl(BuildContext context, String url) {
    // TODO: Implement url_launcher logic
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Open link: $url')),
    );
  }
}
