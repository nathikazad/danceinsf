import 'package:flutter/material.dart';
import '../../models/event_model.dart';
import 'package:flutter_svg_icons/flutter_svg_icons.dart';

class TopBox extends StatelessWidget {
  final Event event;
  final EventInstance eventInstance;
  const TopBox({required this.event, required this.eventInstance, super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          //mainAxisAlignment: MainAxisAlignment.start,

          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  event.styles.map((style) => style.name).join(' & '),
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: Theme.of(context).colorScheme.secondary,
                      fontSize: 16),
                ),

                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    eventInstance.cost.toStringAsFixed(0) == "0"
                        ? "Free"
                        : '\$${eventInstance.cost.toStringAsFixed(0)}',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 20),
                  ),
                ),
                // const SizedBox(height: 4),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  event.type == EventType.social
                      ? 'Social'
                      : 'Class and Social',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: Theme.of(context).colorScheme.secondary,
                      fontSize: 16),
                ),
                Row(
                  children: [
                    if (eventInstance.excitedUsers.isNotEmpty)
                      Row(
                        children: [
                          SvgIcon(
                            icon: SvgIconData('assets/icons/flame.svg'),
                            size: 16,
                            color: Colors.orange,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            eventInstance.excitedUsers.length.toString(),
                            style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontSize: 16),
                          ),
                        ],
                      ),
                    // if (eventInstance.excitedUsers.isNotEmpty && event.ratingCount != null && event.ratingCount! > 0)
                      const SizedBox(width: 16),
                    if (event.ratingCount != null && event.ratingCount! > 0)

                          Row(
                            children: [
                              const Icon(Icons.favorite,
                                  color: Colors.orange, size: 20),
                              const SizedBox(width: 4),
                              Text(
                                event.rating?.toStringAsFixed(1) ?? '-',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineLarge
                                    ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onTertiary,
                                        fontSize: 16),
                              ),
                              Text(
                                ' (${event.ratingCount ?? 0})',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineLarge
                                    ?.copyWith(
                                        fontWeight: FontWeight.w400,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onTertiary
                                            .withOpacity(0.5),
                                        fontSize: 14),
                              ),
                            ],
                          ),

                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
