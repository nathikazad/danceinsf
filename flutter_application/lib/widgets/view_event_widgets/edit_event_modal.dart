import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/event_model.dart';
import '../../screens/verify_screen.dart';

class EditEventModal extends StatelessWidget {
  final EventInstance eventInstance;
  final Function() onEditComplete;
  final String Function(DateTime) formatDate;

  const EditEventModal({
    super.key,
    required this.eventInstance,
    required this.onEditComplete,
    required this.formatDate,
  });

  Future<void> _handleEditNavigation(BuildContext context, String route) async {
    if (Supabase.instance.client.auth.currentUser != null) {
      await GoRouter.of(context).push(route);
    } else {
      await GoRouter.of(context).push('/verify', extra: {
        'nextRoute': route,
        'verifyScreenType': VerifyScreenType.editEvent
      });
    }
    onEditComplete();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.edit),
            title: Text('Only this event on ${formatDate(eventInstance.date)}'),
            onTap: () => _handleEditNavigation(
              context,
              '/edit-event-instance/${eventInstance.eventInstanceId}'
            ),
          ),
          ListTile(
            leading: const Icon(Icons.edit_calendar),
            title: const Text('All future versions of this event'),
            onTap: () => _handleEditNavigation(
              context,
              '/edit-event/${eventInstance.event.eventId}'
            ),
          ),
        ],
      ),
    );
  }
} 