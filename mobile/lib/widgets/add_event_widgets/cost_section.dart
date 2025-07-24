import 'package:flutter/material.dart';

class CostSection extends StatefulWidget {
  final double? initialCost;
  final Function(double) onCostChanged;
  final String? Function(String?)? validator;

  const CostSection({
    super.key,
    required this.initialCost,
    required this.onCostChanged,
    this.validator,
  });

  @override
  State<CostSection> createState() => _CostSectionState();
}

class _CostSectionState extends State<CostSection> {
  late final TextEditingController controller;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController(text: widget.initialCost?.toString() ?? "");
    controller.addListener(() {
      final value = double.tryParse(controller.text) ?? 0.0;
      widget.onCostChanged(value);
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Cost',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontSize: 14, color: Theme.of(context).colorScheme.secondary)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
              hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontSize: 12, color: Theme.of(context).colorScheme.tertiary),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              hintText: 'Cost',
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.onSecondaryContainer,
                    width: 1,
                  ))),
          validator: widget.validator,
          keyboardType: TextInputType.number,
        ),
      ],
    );
  }
}
