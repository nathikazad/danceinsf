import 'package:flutter/material.dart';

class SidebarToggleButton extends StatelessWidget {
  final bool isSidebarVisible;
  final VoidCallback onToggle;

  const SidebarToggleButton({
    super.key,
    required this.isSidebarVisible,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 20,
      height: 20,
      child: IconButton(
        icon: Icon(
          isSidebarVisible ? Icons.chevron_left : Icons.chevron_right,
          color: Colors.black87,
          size: 16,
        ),
        onPressed: onToggle,
        style: IconButton.styleFrom(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          padding: EdgeInsets.zero,
        ),
      ),
    );
  }
} 