import 'package:dance_sf/utils/app_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg_icons/flutter_svg_icons.dart';

class TicketLinkController extends ChangeNotifier {
  final TextEditingController textController;
  IconOption icon;

  TicketLinkController({String? initialText, IconOption? initialIcon})
      : textController = TextEditingController(),
        icon = initialIcon ?? _iconOptions.last {
    if (initialText != null && initialText.isNotEmpty) {
      final deconstructed = deconstructLink(initialText);
      icon = deconstructed.key;
      textController.text = deconstructed.value;
    }
    textController.addListener(notifyListeners);
  }

  setIcon(IconOption newIcon) {
    icon = newIcon;
    notifyListeners();
  }

  String get text => textController.text;

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }
}

class TicketsSection extends StatefulWidget {
  final List<String> initialTicketLinks;
  final void Function(List<String>) onTicketLinksChanged;
  final String? Function(String?)? validator;

  const TicketsSection({
    Key? key,
    required this.initialTicketLinks,
    required this.onTicketLinksChanged,
    this.validator,
  }) : super(key: key);

  @override
  State<TicketsSection> createState() => _TicketsSectionState();
}

class _TicketsSectionState extends State<TicketsSection> {
  late List<TicketLinkController> _controllers;

  @override
  void initState() {
    super.initState();
    _controllers = widget.initialTicketLinks.isNotEmpty
        ? widget.initialTicketLinks
            .map((link) => TicketLinkController(
                  initialText: link,
                  initialIcon: getIconOption(link),
                ))
            .toList()
        : [TicketLinkController()];
    for (final c in _controllers) {
      c.addListener(_onLinksChanged);
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _onLinksChanged() {
    final links = _controllers
        .map((c) => buildFullLink(c.icon, c.text))
        .where((text) => text.isNotEmpty)
        .toList();
    widget.onTicketLinksChanged(links);
  }

  void _addField() {
    setState(() {
      final c = TicketLinkController();
      c.addListener(_onLinksChanged);
      _controllers.add(c);
    });
  }

  void _removeField(int index) {
    setState(() {
      _controllers[index].dispose();
      _controllers.removeAt(index);
    });
    _onLinksChanged();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ...List.generate(_controllers.length, (index) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Row(
              children: [
                Expanded(
                  child: TicketLinkTextField(
                    controller: _controllers[index],
                    index: index,
                    // validator: widget.validator,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline),
                  onPressed: _controllers.length > 1
                      ? () => _removeField(index)
                      : null,
                ),
              ],
            ),
          );
        }),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: _addField,
            icon: const Icon(Icons.add),
            label: const Text('Add Link'),
          ),
        ),
      ],
    );
  }
}

class TicketLinkTextField extends StatefulWidget {
  final TicketLinkController controller;
  final int index;
  // final String? Function(String?)? validator;

  const TicketLinkTextField({
    Key? key,
    required this.controller,
    required this.index,
    // this.validator,
  }) : super(key: key);

  @override
  State<TicketLinkTextField> createState() => _TicketLinkTextFieldState();
}

class IconOption {
  final String iconPath;
  final String label;
  final String urlIdentifier;
  SvgIcon get icon => SvgIcon(
        icon: SvgIconData(iconPath),
        size: 18,
      );
  IconOption(this.iconPath, this.label, this.urlIdentifier);
}

List<IconOption> _iconOptions = [
  IconOption("assets/icons/fb.svg", "Facebook", "facebook"),
  IconOption("assets/icons/ig.svg", "Instagram", "instagram"),
  IconOption("assets/icons/wa.svg", "WhatsApp", "wa.me"),
  IconOption("assets/icons/eb.svg", "EventBrite", "eventbrite"),
  IconOption("assets/icons/line-md_link.svg", "Website", ""),
];

String buildFullLink(IconOption option, String input) {
  final trimmed = input.trim();
  switch (option.label) {
    case 'Instagram':
      if (trimmed.startsWith('http')) return trimmed;
      return 'https://instagram.com/$trimmed';
    case 'WhatsApp':
      final phone = trimmed.replaceAll(RegExp(r'\D'), '');
      final countryCode = AppStorage.countryCode;
      final withCountry = phone.startsWith(countryCode) ? phone : '$countryCode$phone';
      return 'https://wa.me/$withCountry';
    default:
      return trimmed;
  }
}

MapEntry<IconOption, String> deconstructLink(String link) {
  for (final option in _iconOptions) {
    if (option.label == 'Instagram' && link.startsWith('https://instagram.com/')) {
      return MapEntry(option, link.replaceFirst('https://instagram.com/', ''));
    }
    if (option.label == 'WhatsApp' && link.startsWith('https://wa.me/')) {
      var phone = link.replaceFirst('https://wa.me/', '');
      if (phone.startsWith(AppStorage.countryCode)) phone = phone.substring(AppStorage.countryCode.length); // Remove default country code
      return MapEntry(option, phone);
    }
  }
  return MapEntry(_iconOptions.last, link);
}

class _TicketLinkTextFieldState extends State<TicketLinkTextField> {
  late TicketLinkController _controller;
  String _previewUrl = '';

  @override
  void initState() {
    super.initState();
    _controller = widget.controller;
    _previewUrl = buildFullLink(_controller.icon, _controller.text);
    _controller.addListener(_updatePreview);
  }

  void _updatePreview() {
    setState(() {
      _previewUrl = buildFullLink(_controller.icon, _controller.text);
    });
  }

  @override
  void dispose() {
    _controller.removeListener(_updatePreview);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            DropdownButton<IconOption>(
              value: _controller.icon,
              icon: const Icon(Icons.arrow_drop_down),
              underline: Container(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _controller.setIcon(value);
                    _previewUrl = buildFullLink(_controller.icon, _controller.text);
                  });
                }
              },
              items: _iconOptions.map((option) {
                return DropdownMenuItem<IconOption>(
                  value: option,
                  child: Row(
                    children: [
                      option.icon,
                      const SizedBox(width: 6),
                      Text(option.label),
                    ],
                  ),
                );
              }).toList(),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextFormField(
                controller: _controller.textController,
                decoration: InputDecoration(
                  hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontSize: 12, color: Theme.of(context).colorScheme.tertiary),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  hintText: 'Link ${widget.index + 1}',
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.onSecondaryContainer,
                        width: 1,
                      )),
                ),
                // validator: widget.validator,
                keyboardType: TextInputType.url,
              ),
            ),
          ],
        ),
        if (_previewUrl.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 8.0, top: 4.0),
            child: Text(
              _previewUrl,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.tertiary,
                  ),
            ),
          ),
      ],
    );
  }
}

SvgIcon getIcon(String iconPath) {
  return SvgIcon(
    icon: SvgIconData(iconPath),
    size: 18,
  );
}

IconOption getIconOption(String link) {
  for (final option in _iconOptions) {
    if (option.urlIdentifier.isNotEmpty && link.contains(option.urlIdentifier)) {
      return option;
    }
  }
  // Default to Website
  return _iconOptions.last;
}
