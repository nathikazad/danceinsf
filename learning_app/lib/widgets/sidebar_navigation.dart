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
      width: 40,
      height: 40,
      child: IconButton(
        icon: Icon(
          isSidebarVisible ? Icons.chevron_left : Icons.chevron_right,
          color: Colors.black87,
        ),
        onPressed: onToggle,
        style: IconButton.styleFrom(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}

class SidebarSection extends StatefulWidget {
  final List<String> sections;
  final int selectedIndex;
  final ValueChanged<int> onSectionSelected;

  const SidebarSection({
    super.key,
    required this.sections,
    required this.selectedIndex,
    required this.onSectionSelected,
  });

  @override
  State<SidebarSection> createState() => _SidebarSectionState();
}

class _SidebarSectionState extends State<SidebarSection> {
  bool isSidebarVisible = true;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: isSidebarVisible ? 200 : 0,
          child: isSidebarVisible
              ? Container(
                  width: 200,
                  color: Colors.grey[300],
                  child: ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: widget.sections.length,
                    itemBuilder: (context, index) {
                      final isSelected = widget.selectedIndex == index;
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: ListTile(
                          title: Text(
                            widget.sections[index],
                            style: TextStyle(
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                          onTap: () {
                            widget.onSectionSelected(index);
                          },
                        ),
                      );
                    },
                  ),
                )
              : null,
        ),
      ],
    );
  }
} 