import 'package:flutter/material.dart';
import '../../models/event_model.dart';

class DanceTypeSection extends StatelessWidget {
  final EventType type;
  final List<DanceStyle> styles;
  final Function(EventType) onTypeChanged;
  final Function(DanceStyle) onStyleChanged;

  const DanceTypeSection({
    required this.type,
    required this.styles,
    required this.onTypeChanged,
    required this.onStyleChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Type',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontSize: 14, color: Theme.of(context).colorScheme.secondary)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5)),
                    backgroundColor: type == EventType.social
                        ? Theme.of(context).colorScheme.secondaryContainer
                        : null,
                    side: BorderSide(
                      color: type == EventType.social
                          ? Colors.orange
                          : Colors.grey.shade300,
                    ),
                  ),
                  onPressed: () => onTypeChanged(EventType.social),
                  child: Text(
                    'Social',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontSize: 12,
                        color: type == EventType.social
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context)
                                .colorScheme
                                .onSecondaryContainer),
                  ),
                ),
              ),
            ),
            Expanded(
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5)),
                  backgroundColor: type == EventType.class_
                      ? Theme.of(context).colorScheme.secondaryContainer
                      : null,
                  side: BorderSide(
                    color: type == EventType.class_
                        ? Colors.orange
                        : Colors.grey.shade300,
                  ),
                ),
                onPressed: () => onTypeChanged(EventType.class_),
                child: Text(
                  'Class',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontSize: 12,
                      color: type == EventType.class_
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.onSecondaryContainer),
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
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5)),
                    backgroundColor: styles.contains(DanceStyle.bachata)
                        ? Theme.of(context).colorScheme.secondaryContainer
                        : null,
                    side: BorderSide(
                      color: styles.contains(DanceStyle.bachata)
                          ? Colors.orange
                          : Colors.grey.shade300,
                    ),
                  ),
                  onPressed: () => onStyleChanged(DanceStyle.bachata),
                  child: Text('Bachata',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontSize: 12,
                          color: styles.contains(DanceStyle.bachata)
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context)
                                  .colorScheme
                                  .onSecondaryContainer)),
                ),
              ),
            ),
            Expanded(
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5)),
                  backgroundColor: styles.contains(DanceStyle.salsa)
                      ? Theme.of(context).colorScheme.secondaryContainer
                      : null,
                  side: BorderSide(
                    color: styles.contains(DanceStyle.salsa)
                        ? Colors.orange
                        : Colors.grey.shade300,
                  ),
                ),
                onPressed: () => onStyleChanged(DanceStyle.salsa),
                child: Text('Salsa',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontSize: 12,
                        color: styles.contains(DanceStyle.salsa)
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context)
                                .colorScheme
                                .onSecondaryContainer)),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
