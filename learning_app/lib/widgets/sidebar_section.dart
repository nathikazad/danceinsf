import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import 'sidebar_toggle_button.dart';

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
  void initState() {
    super.initState();
    _loadSidebarVisibility();
  }

  Future<void> _loadSidebarVisibility() async {
    final isVisible = await StorageService.getSidebarVisible();
    setState(() {
      _isSidebarVisible = isVisible;
    });
  }

  Future<void> _toggleSidebar() async {
    final newVisibility = !_isSidebarVisible;
    setState(() {
      _isSidebarVisible = newVisibility;
    });
    await StorageService.saveSidebarVisible(newVisibility);
  }

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
              onToggle: _toggleSidebar,
            ),
          ),
        ],
      ),
    );
  }
} 