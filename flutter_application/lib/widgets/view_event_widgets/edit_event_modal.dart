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
      // dismiss the modal
      if (context.mounted) {
        Navigator.pop(context);
      }
    } else {
      await GoRouter.of(context).push(
        '/verify',
        extra: {
          'nextRoute': route,
          'verifyScreenType': VerifyScreenType.editEvent,
        },
      );
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
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(100),
              ),
              child: Icon(
                Icons.edit,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
            ),
            title: Text(
              'Only this event on ${formatDate(eventInstance.date)}',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontSize: 14),
            ),
            onTap:
                () => _handleEditNavigation(
                  context,
                  '/edit-event-instance/${eventInstance.eventInstanceId}',
                ),
          ),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(100),
              ),
              child: Icon(
                Icons.edit_calendar,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
            ),
            title: Text(
              'All future versions of this event',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontSize: 14),
            ),
            onTap:
                () => _handleEditNavigation(
                  context,
                  '/edit-event/${eventInstance.event.eventId}',
                ),
          ),
        ],
      ),
    );
  }
}
