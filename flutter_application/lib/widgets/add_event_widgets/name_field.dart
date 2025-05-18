import 'package:flutter/material.dart';

class NameField extends StatelessWidget {
  final TextEditingController controller;
  final String? Function(String?)? validator;

  const NameField({
    required this.controller,
    this.validator,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Name', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Name',
            border: OutlineInputBorder(),
          ),
          validator: validator ?? (v) => v == null || v.isEmpty ? 'Please enter a name' : null,
        ),
      ],
    );
  }
} 