import 'package:flutter/material.dart';

class TicketsSection extends StatefulWidget {
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
  State<TicketsSection> createState() => _TicketsSectionState();
}

class _TicketsSectionState extends State<TicketsSection> {
  late final TextEditingController controller;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController(text: widget.initialTicketLink);
    controller.addListener(() {
      widget.onTicketLinkChanged(controller.text);
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Tickets Link',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontSize: 14, color: Theme.of(context).colorScheme.secondary)),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(Icons.info,
                size: 16, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 4),
            Text('Link for Customers to Buy Tickets',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontSize: 10,
                    color: Theme.of(context).colorScheme.tertiary)),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
              hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontSize: 12, color: Theme.of(context).colorScheme.tertiary),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              hintText: 'Sample Link',
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.onSecondaryContainer,
                    width: 1,
                  ))),
          validator: widget.validator,
          keyboardType: TextInputType.url,
        ),
      ],
    );
  }
}
