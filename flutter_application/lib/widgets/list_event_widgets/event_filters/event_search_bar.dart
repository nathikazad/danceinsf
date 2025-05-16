import 'package:flutter/material.dart';
import 'package:flutter_application/utils/theme/app_color.dart';

class EventSearchBar extends StatefulWidget {
  final String initialValue;
  final ValueChanged<String> onChanged;

  const EventSearchBar({
    super.key,
    required this.onChanged,
    this.initialValue = '',
  });

  @override
  State<EventSearchBar> createState() => _EventSearchBarState();
}

class _EventSearchBarState extends State<EventSearchBar> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void didUpdateWidget(EventSearchBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only update the text if it's different and we're not the source of the change
    if (widget.initialValue != oldWidget.initialValue &&
        widget.initialValue != _controller.text) {
      _controller.text = widget.initialValue;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: TextField(
        controller: _controller,
        decoration: InputDecoration(
          hintText: 'Search',
          prefixIcon: const Icon(
            Icons.search,
            size: 20,
            color: AppColors.darkPrimary,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          isDense: true,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        ),
        onChanged: (value) {
          final String valueCopy = String.fromCharCodes(value.runes);
          widget.onChanged(valueCopy);
        },
      ),
    );
  }
}
