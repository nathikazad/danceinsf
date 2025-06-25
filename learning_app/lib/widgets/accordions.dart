import 'package:flutter/material.dart';
import '../models/video_links.dart';
import 'accordion_widget.dart';
import 'sidebar_section.dart';
import 'video_player_widget.dart';

class Accordions extends StatefulWidget {
  final List<AccordionData> accordionData;

  const Accordions({
    super.key,
    required this.accordionData,
  });

  @override
  State<Accordions> createState() => _AccordionsState();
}

class _AccordionsState extends State<Accordions> {
  int _openAccordionIndex = 0; // Track selected section

  void _toggleAccordion(int index) {
    setState(() {
      if (_openAccordionIndex == index) {
        _openAccordionIndex = -1; // Close if same accordion is tapped
      } else {
        _openAccordionIndex = index; // Open new accordion
      }
    });
  }

  void _selectSection(int index) {
    setState(() {
      _openAccordionIndex = index; // Update selected section
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 600) {
          // Sidebar layout for widths > 600
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SidebarSection(
                sections: widget.accordionData.map((data) => data.title).toList(),
                selectedIndex: _openAccordionIndex,
                onSectionSelected: _selectSection,
              ),
              Expanded(
                child: VideoPlayerWidget(
                  key: ValueKey(_openAccordionIndex), // Unique key to manage instance
                  videoUrls: _openAccordionIndex >= 0 &&
                          _openAccordionIndex < widget.accordionData.length
                      ? widget.accordionData[_openAccordionIndex].videoUrls
                      : [], // Empty list if invalid index
                  isExpanded: true, // Always expanded in sidebar layout
                ),
              ),
            ],
          );
        } else {
          // Accordion layout for widths <= 600
          return SingleChildScrollView(
            child: Column(
              children: widget.accordionData.asMap().entries.map((entry) {
                final index = entry.key;
                final data = entry.value;
                return AccordionWidget(
                  key: ValueKey('accordion_$index'), // Unique key for each accordion
                  title: data.title,
                  isExpanded: _openAccordionIndex == index,
                  onToggle: () => _toggleAccordion(index),
                  child: SizedBox(
                    height: 400,
                    child: VideoPlayerWidget(
                      key: ValueKey('video_$index'), // Unique key for each video player
                      videoUrls: data.videoUrls,
                      isExpanded: _openAccordionIndex == index,
                    ),
                  ),
                );
              }).toList(),
            ),
          );
        }
      },
    );
  }
} 