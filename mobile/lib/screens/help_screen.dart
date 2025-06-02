import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  bool _isLoading = false;

  Future<void> _handleDeleteAccount() async {
    setState(() {
      _isLoading = true;
    });

    // Wait for 2 seconds
    await Future.delayed(const Duration(seconds: 2));
    
    // Sign out the user
    await Supabase.instance.client.auth.signOut();
    
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

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
              'No, it is a free tool to help people discover bachata events in San Francisco.',
            ),
            _buildFAQItem(
              context,
              'Does it work only in San Francisco?',
              'Yes only in San Francisco, but if you want it in your city, send an email using the link below.',
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

            if (Supabase.instance.client.auth.currentUser != null)
            _buildFAQItem(
              context,
              'How to delete my account?',
              'Click the link below to delete your account.',
              link: InkWell(
                onTap: _isLoading ? null : _handleDeleteAccount,
                child: _isLoading 
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'Delete Account',
                      style: TextStyle(
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                    ),
              ),
            ),

            const SizedBox(height: 24),
            const Text(
              'Have any questions?',
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
