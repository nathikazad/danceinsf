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
  bool _isSidebarVisible = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _isSidebarVisible ? 200 : 30,
      child: Stack(
        children: [
          // Sidebar content
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 200,
            child: Transform.translate(
              offset: Offset(_isSidebarVisible ? 0 : -170, 0),
              child: Container(
                width: 200,
                color: Colors.grey[300],
                child: ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: widget.sections.length,
                  itemBuilder: (context, index) {
                    final bool isSelected = widget.selectedIndex == index;
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
              ),
            ),
          ),
          // Toggle button
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            right: _isSidebarVisible ? 0 : null,
            left: _isSidebarVisible ? null : 0,
            top: 0,
            child: SidebarToggleButton(
              isSidebarVisible: _isSidebarVisible,
              onToggle: () {
                setState(() {
                  _isSidebarVisible = !_isSidebarVisible;
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}