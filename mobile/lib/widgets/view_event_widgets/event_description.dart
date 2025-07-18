import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class EventDescription extends StatefulWidget {
  final Map<String, String> description;

  const EventDescription({
    Key? key,
    required this.description,
  }) : super(key: key);

  @override
  State<EventDescription> createState() => _EventDescriptionState();
}

class _EventDescriptionState extends State<EventDescription> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currentLocale = Localizations.localeOf(context).languageCode;
    
    // Get description in current language, fallback to other language if not available
    String descriptionText = "";
    if (currentLocale == 'en') {
      descriptionText = widget.description["en"] ?? widget.description["es"] ?? "";
    } else {
      descriptionText = widget.description["es"] ?? widget.description["en"] ?? "";
    }
    
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ExpansionTile(
        initiallyExpanded: false,
        onExpansionChanged: (expanded) => setState(() => _expanded = expanded),
        title: Row(
          children: [
            Icon(
              Icons.description,
              color: Theme.of(context).colorScheme.primary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              l10n.eventDescriptionTitle,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        children: _expanded
            ? [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      descriptionText,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ),
              ]
            : [],
      ),
    );
  }
}