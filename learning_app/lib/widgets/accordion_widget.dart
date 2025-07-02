import 'package:flutter/material.dart';

class AccordionWidget extends StatefulWidget {
  final String title;
  final Widget child;
  final bool isExpanded;
  final VoidCallback onToggle;

  const AccordionWidget({
    super.key,
    required this.title,
    required this.child,
    required this.isExpanded,
    required this.onToggle,
  });

  @override
  State<AccordionWidget> createState() => _AccordionWidgetState();
}

class _AccordionWidgetState extends State<AccordionWidget> {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: widget.isExpanded ? Colors.white : Color(0xFF231404),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: ListTile(
              title: Text(
                widget.title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color(0xFF231404),
                ),
              ),
              trailing: Icon(
                widget.isExpanded ? Icons.expand_less : Icons.expand_more,
                color: Colors.white,
              ),
              onTap: widget.onToggle,
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
              ),
              padding: const EdgeInsets.all(16.0),
              child: widget.child,
            ),
            crossFadeState: widget.isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
          ),
        ],
      ),
    );
  }
} 