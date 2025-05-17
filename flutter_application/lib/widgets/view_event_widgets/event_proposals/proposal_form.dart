import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_application/controllers/proposal_controller.dart';
import 'package:flutter_application/models/event_model.dart';

class ProposalForm extends StatefulWidget {
  final EventInstance eventInstance;
  final VoidCallback onSubmitted;

  const ProposalForm({
    required this.eventInstance,
    required this.onSubmitted,
    super.key,
  });

  @override
  State<ProposalForm> createState() => _ProposalFormState();
}

class _ProposalFormState extends State<ProposalForm> {
  final TextEditingController _controller = TextEditingController();
  bool forAllEvents = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    print('Creating proposal');
    ProposalController.createProposal(
      text: _controller.text.trim(),
      forAllEvents: forAllEvents,
      eventId: widget.eventInstance.event.eventId,
      eventInstanceId: widget.eventInstance.eventInstanceId,
    );
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Submitted: $text')),
      );
      _controller.clear();
      widget.onSubmitted();
      Navigator.of(context).pop(); // Close the dialog
    }
  }

  @override
  Widget build(BuildContext context) {
    // Note: showDialog's barrierDismissible should be true for outside tap to close
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Center(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            constraints: const BoxConstraints(maxWidth: 400),
            padding: const EdgeInsets.all(24),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox(width: 40), // for alignment
                      const Expanded(
                        child: Text(
                          'Suggest an Edit',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(context).pop(),
                        tooltip: 'Close',
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _controller,
                    minLines: 4,
                    maxLines: 6,
                    maxLength: 150,
                    decoration: const InputDecoration(
                      hintText: 'Please enter the edits you would like to make',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if(widget.eventInstance.event.frequency != Frequency.once)
                  Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Checkbox(
                              value: !forAllEvents,
                              onChanged: (val) {
                                setState(() {
                                  forAllEvents = false;
                                });
                              },
                            ),
                            const Expanded(
                              child: Text(
                                'Only this event',
                                style: TextStyle(fontSize: 15),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Row(
                          children: [
                            Checkbox(
                              value: forAllEvents,
                              onChanged: (val) {
                                setState(() {
                                  forAllEvents = true;
                                });
                              },
                            ),
                            const Expanded(
                              child: Text(
                                'All events',
                                style: TextStyle(fontSize: 15),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                        onPressed: _handleSubmit,
                        child: const Text('Submit', style: TextStyle(fontSize: 16)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}