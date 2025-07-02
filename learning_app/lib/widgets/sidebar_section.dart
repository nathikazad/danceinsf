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
      width: _isSidebarVisible ? 220 : 30,
      color: const Color(0xFF231404),
      child: Stack(
        children: [
          // Sidebar content
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 220,
            child: Transform.translate(
              offset: Offset(_isSidebarVisible ? 0 : -170, 0),
              child: Column(
                children: [
                  // Logo
                  Padding(
                    padding: const EdgeInsets.only(top: 16, bottom: 32),
                    child: Image.asset(
                      'assets/logo.png',
                      // height: 68,
                      width: 136,
                    ),
                  ),
                  // Section buttons
                  Expanded(
                    child: ListView.builder(
                      itemCount: widget.sections.length,
                      itemBuilder: (context, index) {
                        final isSelected = widget.selectedIndex == index;
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          child: Material(
                            color: isSelected ? const Color(0xFFFFA726) : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(8),
                              onTap: () => widget.onSectionSelected(index),
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.ondemand_video,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        widget.sections[index],
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                          fontSize: 16,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  // Logout button
                  Padding(
                    padding: const EdgeInsets.only(bottom: 24, left: 12, right: 12, top: 12),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: () {/* TODO: Implement logout */},
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                          child: Row(
                            children: [
                              const Icon(Icons.logout, color: Colors.white),
                              const SizedBox(width: 12),
                              const Text(
                                'Logout',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
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