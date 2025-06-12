import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dance_sf/widgets/list_event_widgets/event_filters/event_filters_widget.dart';

class TopBar extends StatelessWidget {
  final VoidCallback onFilterPressed;
  final VoidCallback onAddPressed;
  final FilterController filterController;

  const TopBar({
    super.key,
    required this.onFilterPressed,
    required this.onAddPressed,
    required this.filterController,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(100)),
                child: IconButton(
                  icon: const Icon(Icons.tune),
                  onPressed: onFilterPressed,
                ),
              ),
              Consumer(
                builder: (context, ref, child) {
                  final filterCount =
                      ref.watch(filterControllerProvider).countActiveFilters();
                  if (filterCount == 0) return const SizedBox.shrink();
                  return Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        filterCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          Expanded(
            child: EventSearchBar(
              initialValue: filterController.searchText,
              onChanged: filterController.updateSearchText,
            ),
          ),
          Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                color: Theme.of(context).colorScheme.secondaryContainer),
            child: IconButton(
              icon: const Icon(Icons.add),
              onPressed: onAddPressed,
            ),
          ),
        ],
      ),
    );
  }
}
