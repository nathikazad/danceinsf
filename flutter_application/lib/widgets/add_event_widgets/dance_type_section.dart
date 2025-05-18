import 'package:flutter/material.dart';
import '../../models/event_model.dart';

class DanceTypeSection extends StatelessWidget {
  final EventType type;
  final DanceStyle style;
  final Function(EventType) onTypeChanged;
  final Function(DanceStyle) onStyleChanged;

  const DanceTypeSection({
    required this.type,
    required this.style,
    required this.onTypeChanged,
    required this.onStyleChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Type', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    backgroundColor: type == EventType.social ? Colors.orange.shade50 : null,
                    side: BorderSide(
                      color: type == EventType.social ? Colors.orange : Colors.grey.shade300,
                    ),
                  ),
                  onPressed: () => onTypeChanged(EventType.social),
                  child: Text(
                    'Social',
                    style: TextStyle(
                      color: type == EventType.social ? Colors.orange : Colors.black,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  backgroundColor: type == EventType.class_ ? Colors.orange.shade50 : null,
                  side: BorderSide(
                    color: type == EventType.class_ ? Colors.orange : Colors.grey.shade300,
                  ),
                ),
                onPressed: () => onTypeChanged(EventType.class_),
                child: Text(
                  'Class',
                  style: TextStyle(
                    color: type == EventType.class_ ? Colors.orange : Colors.black,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    backgroundColor: style == DanceStyle.bachata ? Colors.orange.shade50 : null,
                    side: BorderSide(
                      color: style == DanceStyle.bachata ? Colors.orange : Colors.grey.shade300,
                    ),
                  ),
                  onPressed: () => onStyleChanged(DanceStyle.bachata),
                  child: Text(
                    'Bachata',
                    style: TextStyle(
                      color: style == DanceStyle.bachata ? Colors.orange : Colors.black,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  backgroundColor: style == DanceStyle.salsa ? Colors.orange.shade50 : null,
                  side: BorderSide(
                    color: style == DanceStyle.salsa ? Colors.orange : Colors.grey.shade300,
                  ),
                ),
                onPressed: () => onStyleChanged(DanceStyle.salsa),
                child: Text(
                  'Salsa',
                  style: TextStyle(
                    color: style == DanceStyle.salsa ? Colors.orange : Colors.black,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
} 