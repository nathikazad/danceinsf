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
        const Text('Cost', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Cost',
            border: OutlineInputBorder(),
          ),
          validator: validator,
          keyboardType: TextInputType.number,
        ),
      ],
    );
  }
} 