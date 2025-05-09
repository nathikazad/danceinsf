import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../auth.dart';

class EventsScreen extends ConsumerWidget {
  const EventsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dance Events'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authProvider).signOut(),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 10, // Placeholder count
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: ListTile(
              title: Text('Dance Event ${index + 1}'),
              subtitle: Text('Date: ${DateTime.now().add(Duration(days: index)).toString().split(' ')[0]}'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                // TODO: Navigate to event details
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/add-event'),
        child: const Icon(Icons.add),
      ),
    );
  }
} 