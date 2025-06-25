import 'package:flutter/material.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';
import '../widgets/video_player_widget.dart';

class AccordionVideoListScreen extends StatefulWidget {
  const AccordionVideoListScreen({super.key});

  @override
  State<AccordionVideoListScreen> createState() => _AccordionVideoListScreenState();
}

class _AccordionVideoListScreenState extends State<AccordionVideoListScreen> with TickerProviderStateMixin {
  int? expandedIndex;
  ChewieController? _activeChewieController; // Track the currently active controller

  final List<String> sections = [
    'Intro',
    'Paso 1',
    'Paso 2',
    'Paso 3',
    'Paso 4',
    'Paso 5',
    'Paso 6',
    'Paso 7',
    'Paso 8',
    'Paso 9',
    'Paso 10',
    'Paso 11',
    'Paso 12',
    'Outro',
  ];

  final List<String> videoUrls = [
    "https://stream.mux.com/6xid2UmDgaZRybbQiOWTOeRF006lcls2QIjazfTaLPx00.m3u8",
    "https://stream.mux.com/9yDN01VI8QmctgJEPF4i9evZIQFtR6CIwCnW1kt9uyyM.m3u8",
    "https://stream.mux.com/SW5iarXYcodHwfWkYlgzvUM5j9xqfxGfxYYYH02r4ZL00.m3u8",
    "https://stream.mux.com/1NeM2I7uIHVBRlqjzPijZu4Tzz01zcCvljDRFS005MNZ8.m3u8",
    "https://stream.mux.com/PXEyFShMfOW6PTarzJi4Hx8JZrI500Zd00HRuPao7hjyE.m3u8",
  ];

  // Method to update the active controller
  void _setActiveController(ChewieController? controller) {
    // Pause the previously active controller
    _activeChewieController?.pause();
    _activeChewieController = controller; // Set new active controller
  }

  @override
  void dispose() {
    _activeChewieController?.dispose();
    super.dispose();
  }

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
          ? Row(
              children: [
                Container(
                  width: 200,
                  color: Colors.grey[300],
                  child: ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: sections.length,
                    itemBuilder: (context, index) {
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: ListTile(
                          title: Text(sections[index]),
                          onTap: () {
                            setState(() {
                              expandedIndex = expandedIndex == index ? null : index;
                            });
                          },
                        ),
                      );
                    },
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: _buildExpandedSection(expandedIndex ?? 0),
                  ),
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
                        child: ListTile(
                          title: Text(sections[index]),
                          trailing: Icon(isExpanded ? Icons.expand_less : Icons.expand_more),
                          onTap: () {
                            setState(() {
                              expandedIndex = isExpanded ? null : index;
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
      child: 
        VideoPlayerWidget(
            videoUrls: videoUrls,
            isPlaying: expandedIndex == index,
            onControllerReady: _setActiveController, // Pass callback to update active controller
          ),
        
    );
  }
}