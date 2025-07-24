import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';

class EventDescription extends StatefulWidget {
  final Map<String, String> description;
  final Map<DateTime, double>? ticketPrices;

  const EventDescription({
    Key? key,
    required this.description,
    this.ticketPrices,
  }) : super(key: key);

  @override
  State<EventDescription> createState() => _EventDescriptionState();
}

class _EventDescriptionState extends State<EventDescription> {
  bool _expanded = true;

  String _formatTicketPriceDate(DateTime date) {
    // Example: Till 11pm Friday Aug 2nd
    final hour = date.hour == 0 || date.hour == 12
        ? 12
        : date.hour % 12;
    final ampm = date.hour < 12 ? 'am' : 'pm';
    final weekday = DateFormat('EEEE').format(date); // Friday
    final month = DateFormat('MMM').format(date); // Aug
    final day = date.day;
    // Suffix for day
    String suffix;
    if (day >= 11 && day <= 13) {
      suffix = 'th';
    } else {
      switch (day % 10) {
        case 1:
          suffix = 'st';
          break;
        case 2:
          suffix = 'nd';
          break;
        case 3:
          suffix = 'rd';
          break;
        default:
          suffix = 'th';
      }
    }
    // Show hour with am/pm (e.g., 11pm, 12pm, 1am)
    return 'Till $hour$ampm $weekday $month $day$suffix';
  }

  String getTicketPrices() {
    if (widget.ticketPrices == null) {
      return "";
    }
    String ticketPrices = widget.ticketPrices!.entries
        .map((entry) => "${_formatTicketPriceDate(entry.key.toLocal())}: \$${entry.value.toStringAsFixed(2)}")
        .join("\n");
    return "Ticket Prices:\n$ticketPrices";
  }

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
        initiallyExpanded: true,
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
                      "$descriptionText\n\n${getTicketPrices()}",
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