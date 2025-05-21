import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Help & FAQ')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Frequently Asked Questions',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            _buildFAQItem(
              context,
              'Who maintains this list?',
              'It is maintained by the community.',
            ),
            _buildFAQItem(
              context,
              'Does it cost anything?',
              'No, it is a free tool to help people discover bachata events around them.',
            ),
            _buildFAQItem(
              context,
              'Does it work only in San Francisco?',
              'Yes, but if you want it in your city, send an email using the link below.',
            ),
            _buildFAQItem(
              context,
              'Is this available as apps?',
              'Yes, there is iOS and android app as well as a webpage.',
              link: InkWell(
                onTap: () => launchUrl(Uri.parse('https://wheredothey.dance')),
                child: const Text(
                  'Visit wheredothey.dance',
                  style: TextStyle(
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
            _buildFAQItem(
              context,
              'Who developed this?',
              'This app is developed by Nathik Azad',
              link: InkWell(
                onTap:
                    () => launchUrl(
                      Uri.parse('https://instagram.com/nathikazad'),
                    ),
                child: const Text(
                  '@nathikazad',
                  style: TextStyle(
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),
            const Text(
              'Need more help?',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: () {
                final email = 'nathikazad@gmail.com';
                final subject = 'Help Question';
                final body = 'Hello, I have a question about the app.';
                final url = 'mailto:$email?subject=$subject&body=$body';
                launchUrl(Uri.parse(url));
              },
              child: const Text(
                'Contact us via email',
                style: TextStyle(
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQItem(
    BuildContext context,
    String question,
    String answer, {
    Widget? link,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(answer, style: const TextStyle(fontSize: 16)),
              ),
            ],
          ),
          if (link != null) link,
        ],
      ),
    );
  }
}
