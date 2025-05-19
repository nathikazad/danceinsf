import 'package:flutter/material.dart';

class CostSection extends StatelessWidget {
  final double initialCost;
  final Function(double) onCostChanged;
  final String? Function(String?)? validator;

  const CostSection({
    super.key,
    required this.initialCost,
    required this.onCostChanged,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController(text: initialCost.toString());
    controller.addListener(() {
      final value = double.tryParse(controller.text) ?? 0.0;
      onCostChanged(value);
    });

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
          validator: validator,
          keyboardType: TextInputType.number,
        ),
      ],
    );
  }
}
