import 'package:auto_size_text/auto_size_text.dart';
import 'package:dance_shared/auth/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learning_app/l10n/app_localizations.dart';
import '../services/storage_service.dart';
import '../main.dart';
import 'sidebar_toggle_button.dart';

class SidebarSection extends ConsumerStatefulWidget {
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
  ConsumerState<SidebarSection> createState() => _SidebarSectionState();
}

class _SidebarSectionState extends ConsumerState<SidebarSection> {
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

  void _toggleLanguage() {
    final currentLocale = ref.read(localeProvider);
    final newLocale = currentLocale.languageCode == 'en' 
        ? const Locale('es') 
        : const Locale('en');
    ref.read(localeProvider.notifier).state = newLocale;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
                    padding: const EdgeInsets.only(top: 75, bottom: 75, left: 25, right: 25),
                    child: AutoSizeText(
                      'My Bachata Moves',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 22,
                        color: Colors.orange[700],
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
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
                  // Language toggle button
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12, left: 12, right: 12),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: _toggleLanguage,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                          child: Row(
                            children: [
                              const Icon(Icons.language, color: Colors.white),
                              const SizedBox(width: 12),
                              Text(
                                l10n.localeName == 'en' ? 'Español' : 'English',
                                style: const TextStyle(
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
                  // Logout button
                  Padding(
                    padding: const EdgeInsets.only(bottom: 24, left: 12, right: 12, top: 12),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: () {
                          ref.read(authProvider.notifier).signOut();
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                          child: Row(
                            children: [
                              const Icon(Icons.logout, color: Colors.white),
                              const SizedBox(width: 12),
                              Text(
                                l10n.logout,
                                style: const TextStyle(
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