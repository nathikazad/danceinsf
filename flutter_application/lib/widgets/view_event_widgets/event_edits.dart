import 'package:flutter/material.dart';
import 'package:flutter_application/controllers/event_controller.dart';

class IsInformationCorrect extends StatefulWidget {
  final VoidCallback? onYes;
  final VoidCallback? onNo;
  final String eventId;
  final String eventInstanceId;
  const IsInformationCorrect({this.onYes, this.onNo, required this.eventId, required this.eventInstanceId, super.key});

  @override
  State<IsInformationCorrect> createState() => _IsInformationCorrectState();
}

class _IsInformationCorrectState extends State<IsInformationCorrect> {
  bool showTextBox = false;
  final TextEditingController _controller = TextEditingController();
  bool forAllEvents = false; // false = only for this event, true = for all events

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleSuggestEdit() {
    setState(() {
      showTextBox = true;
    });
    if (widget.onNo != null) widget.onNo!();
  }

  void _handleSubmit() {
    print('Creating proposal');
    print('eventId: ${widget.eventId}, eventInstanceId: ${widget.eventInstanceId}');
    EventController.createProposal(
      text: _controller.text.trim(),
      forAllEvents: forAllEvents,
      eventId: widget.eventId,
      eventInstanceId: widget.eventInstanceId,
    );
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Submitted: $text')),
      );
      setState(() {
        showTextBox = false;
        _controller.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 20),
        const Text(
          'This listing is maintained by the Community',
          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        if (!showTextBox)
          GestureDetector(
            onTap: _handleSuggestEdit,
            child: const Text(
              'Suggest an edit',
              style: TextStyle(
                color: Colors.orange,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          )
        else ...[
          TextField(
            controller: _controller,
            minLines: 2,
            maxLines: 4,
            decoration: const InputDecoration(
              hintText: 'Please enter which information is incorrect',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Checkbox(
                value: !forAllEvents,
                onChanged: (val) {
                  setState(() {
                    forAllEvents = false;
                  });
                },
              ),
              const Expanded(child: Text('Only this event', style: TextStyle(fontSize: 15))),
              Checkbox(
                value: forAllEvents,
                onChanged: (val) {
                  setState(() {
                    forAllEvents = true;
                  });
                },
              ),
              const Expanded(child: Text('All events', style: TextStyle(fontSize: 15))),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: _handleSubmit,
              child: const Text('Submit', style: TextStyle(fontSize: 16)),
            ),
          ),
        ],
      ],
    );
  }
} 