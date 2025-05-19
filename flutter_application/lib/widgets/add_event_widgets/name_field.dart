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
        Text('Name',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontSize: 14, color: Theme.of(context).colorScheme.secondary)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
              hintText: 'Name',
              hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontSize: 12, color: Theme.of(context).colorScheme.tertiary),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.onSecondaryContainer,
                  width: 0.5,
                ),
              )),
          validator: validator ??
              (v) => v == null || v.isEmpty ? 'Please enter a name' : null,
        ),
      ],
    );
  }
}
