import 'package:flutter/material.dart';

class EventDetailRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final String? linkText;
  final String? linkUrl;
  const EventDetailRow({required this.icon, required this.text, this.linkText, this.linkUrl, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: Colors.orange, size: 22),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 16))),
          if (linkText != null && linkUrl != null)
            GestureDetector(
              onTap: () => _launchUrl(context, linkUrl!),
              child: Text(linkText!, style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
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