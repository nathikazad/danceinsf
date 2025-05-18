import 'package:flutter/material.dart';

class CostSection extends StatefulWidget {
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
  State<CostSection> createState() => _CostSectionState();
}

class _CostSectionState extends State<CostSection> {
  late final TextEditingController controller;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController(text: widget.initialCost.toString());
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
        const Text('Cost', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Cost',
            border: OutlineInputBorder(),
          ),
          validator: widget.validator,
          keyboardType: TextInputType.number,
        ),
      ],
    );
  }
} 