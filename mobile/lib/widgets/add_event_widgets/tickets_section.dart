import 'package:flutter/material.dart';

class TicketsSection extends StatefulWidget {
  final List<String> initialTicketLinks;
  final Function(List<String>) onTicketLinksChanged;
  final String? Function(String?)? validator;

  const TicketsSection({
    super.key,
    required this.initialTicketLinks,
    required this.onTicketLinksChanged,
    this.validator,
  });

  @override
  State<TicketsSection> createState() => _TicketsSectionState();
}

class _TicketsSectionState extends State<TicketsSection> {
  late List<TextEditingController> controllers;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with existing links, or one empty controller if no links
    controllers = widget.initialTicketLinks.isEmpty 
        ? [TextEditingController()]
        : widget.initialTicketLinks.map((link) => TextEditingController(text: link)).toList();
    
    // Add listeners to all controllers
    for (final controller in controllers) {
      controller.addListener(_onLinksChanged);
    }
  }

  @override
  void dispose() {
    for (final controller in controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _onLinksChanged() {
    final links = controllers
        .map((controller) => controller.text.trim())
        .where((text) => text.isNotEmpty)
        .toList();
    widget.onTicketLinksChanged(links);
  }

  void _addNewLink() {
    setState(() {
      final newController = TextEditingController();
      newController.addListener(_onLinksChanged);
      controllers.add(newController);
    });
  }

  void _removeLink(int index) {
    if (controllers.length > 1) {
      setState(() {
        controllers[index].dispose();
        controllers.removeAt(index);
        _onLinksChanged();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Links to Event',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontSize: 14, color: Theme.of(context).colorScheme.secondary)),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(Icons.info,
                size: 16, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 4),
            Expanded(
              child: Text('Links for customers to see more info and buy tickets',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontSize: 10,
                      color: Theme.of(context).colorScheme.tertiary)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...controllers.asMap().entries.map((entry) {
          final index = entry.key;
          final controller = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: controller,
                    decoration: InputDecoration(
                        hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontSize: 12, color: Theme.of(context).colorScheme.tertiary),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        hintText: 'Link ${index + 1}',
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.onSecondaryContainer,
                              width: 1,
                            ))),
                    validator: widget.validator,
                    keyboardType: TextInputType.url,
                  ),
                ),
                if (controllers.length > 1) ...[
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () => _removeLink(index),
                    icon: Icon(
                      Icons.remove_circle_outline,
                      color: Theme.of(context).colorScheme.error,
                      size: 24,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ],
            ),
          );
        }).toList(),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _addNewLink,
            icon: const Icon(Icons.add),
            label: const Text('Add Another Link'),
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
