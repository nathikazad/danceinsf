import 'package:flutter/material.dart';

class TicketsSection extends StatelessWidget {
  final String? initialTicketLink;
  final Function(String) onTicketLinkChanged;
  final String? Function(String?)? validator;

  const TicketsSection({
    super.key,
    required this.initialTicketLink,
    required this.onTicketLinkChanged,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController(text: initialTicketLink);
    controller.addListener(() {
      onTicketLinkChanged(controller.text);
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Tickets Link', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Row(
          children: [
            const Icon(Icons.info_outline, size: 18, color: Colors.orange),
            const SizedBox(width: 4),
            Text('Link for Customers to Buy Tickets', 
              style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Sample Link',
            border: OutlineInputBorder(),
          ),
          validator: validator,
          keyboardType: TextInputType.url,
        ),
      ],
    );
  }
} 