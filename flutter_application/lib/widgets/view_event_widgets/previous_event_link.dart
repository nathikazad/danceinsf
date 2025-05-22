import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../controllers/event_instance_controller.dart';

class PreviousEventLink extends StatefulWidget {
  final String eventId;
  final DateTime currentDate;

  const PreviousEventLink({
    super.key,
    required this.eventId,
    required this.currentDate,
  });

  @override
  State<PreviousEventLink> createState() => _PreviousEventLinkState();
}

class _PreviousEventLinkState extends State<PreviousEventLink> {
  Map<String, dynamic>? _previousEvent;

  @override
  void initState() {
    super.initState();
    _loadPreviousEvent();
  }

  Future<void> _loadPreviousEvent() async {
    final previousEvent = await EventInstanceController.getPreviousEvent(
      widget.eventId,
      widget.currentDate,
    );
    if (mounted) {
      setState(() {
        _previousEvent = previousEvent;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_previousEvent == null) return const SizedBox.shrink();

    final previousDate = _previousEvent!['instance_date'] as DateTime;
    final previousInstanceId = _previousEvent!['instance_id'] as String;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Previous instance of this event was on'),
          const SizedBox(width: 4),
          TextButton(
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            onPressed: () => GoRouter.of(context).push('/event/$previousInstanceId'),
            child: Text(
              '${previousDate.month}/${previousDate.day}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
          ),
        ],
      ),
    );
  }
} 