import 'package:flutter/material.dart';
import '../widgets/video_player_widget.dart';
import '../widgets/sidebar_navigation.dart';

class AccordionVideoListScreen extends StatefulWidget {
  const AccordionVideoListScreen({super.key});

  @override
  State<AccordionVideoListScreen> createState() => _AccordionVideoListScreenState();
}

class _AccordionVideoListScreenState extends State<AccordionVideoListScreen> with TickerProviderStateMixin {
  int? expandedIndex;
  bool isSidebarVisible = true;

  List<int> numUrlsToShow = [5, 4, 3, 4, 2, 2, 5, 1];

  final List<String> sections = [
    'Intro',
    'Paso 1',
    'Paso 2',
    'Paso 3',
    'Paso 4',
    'Paso 5',
    'Paso 6',
    'Outro',
  ];

  final List<String> videoUrls = [
    "https://stream.mux.com/6xid2UmDgaZRybbQiOWTOeRF006lcls2QIjazfTaLPx00.m3u8",
    "https://stream.mux.com/9yDN01VI8QmctgJEPF4i9evZIQFtR6CIwCnW1kt9uyyM.m3u8",
    "https://stream.mux.com/SW5iarXYcodHwfWkYlgzvUM5j9xqfxGfxYYYH02r4ZL00.m3u8",
    "https://stream.mux.com/1NeM2I7uIHVBRlqjzPijZu4Tzz01zcCvljDRFS005MNZ8.m3u8",
    "https://stream.mux.com/PXEyFShMfOW6PTarzJi4Hx8JZrI500Zd00HRuPao7hjyE.m3u8",
  ];


  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 600;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Bachata Gram'),
        backgroundColor: Colors.grey[300],
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: isDesktop
          ? Stack(
              children: [
                Row(
                  children: [
                    SidebarSection(
                      sections: sections,
                      selectedIndex: expandedIndex ?? 0,
                      onSectionSelected: (index) {
                        setState(() {
                          expandedIndex = index;
                        });
                      },
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: _buildExpandedSection(expandedIndex ?? 0),
                      ),
                    ),
                  ],
                ),
              ],
            )
          : SafeArea(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 8),
                itemCount: sections.length,
                itemBuilder: (context, index) {
                  final isExpanded = expandedIndex == index;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Card(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        color: isExpanded ? Colors.blue[100] : null,
                        child: ListTile(
                          title: Text(
                            sections[index],
                            style: TextStyle(
                              fontWeight: isExpanded ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                          trailing: Icon(isExpanded ? Icons.expand_less : Icons.expand_more),
                          onTap: () {
                            setState(() {
                              if (expandedIndex == index) {
                                expandedIndex = null;
                              } else {
                                expandedIndex = index;
                              }
                            });
                          },
                        ),
                      ),
                      AnimatedCrossFade(
                        firstChild: _buildExpandedSection(index),
                        secondChild: const SizedBox.shrink(),
                        crossFadeState: isExpanded ? CrossFadeState.showFirst : CrossFadeState.showSecond,
                        duration: const Duration(milliseconds: 300),
                        sizeCurve: Curves.easeInOut,
                      ),
                    ],
                  );
                },
              ),
            ),
    );
  }

  Widget _buildExpandedSection(int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: VideoPlayerWidget(
        key: ValueKey('video_player_$index'),
        videoUrls: videoUrls.sublist(0, numUrlsToShow[index]),
      ),
    );
  }
}