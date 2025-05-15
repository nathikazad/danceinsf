import 'package:flutter/material.dart';
import 'package:flutter_application/auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(24.0),
              child: Text('Menu', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            ),
            ListTile(
              leading: const Icon(Icons.help_outline),
              title: const Text('Contact'),
              onTap: () {
                // TODO: Implement Contact navigation
                Navigator.of(context).pop();
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.chat),
              title: const Text('Groupchat'),
              onTap: () {
                // TODO: Implement Groupchat navigation
                Navigator.of(context).pop();
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edits'),
              onTap: () {
                // TODO: Implement Edits navigation
                Navigator.of(context).pop();
              },
            ),
            const Divider(),
            if (ref.watch(authProvider).state.user != null)
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Revoke OTP'),
              onTap: () {
                ref.read(authProvider.notifier).signOut();
              },
            ),
          ],
        ),
      ),
    );
  }
} 