import 'package:flutter/material.dart';
import 'package:learning_app/controller.dart';
import '../models/video_links.dart';
import '../widgets/sidebar_section.dart';
import '../widgets/video_player_widget.dart';

class DesktopVideoApp extends StatefulWidget {
  const DesktopVideoApp({super.key});

  @override
  State<DesktopVideoApp> createState() => _DesktopVideoAppState();
}

class _DesktopVideoAppState extends State<DesktopVideoApp> {
  late final List<AccordionData> accordionData;

  @override
  void initState() {
    super.initState();
    accordionData = VideoController.getVideos();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Video Player Demo - Desktop',
      debugShowCheckedModeBanner: false,
      home: _DesktopScaffold(accordionData: accordionData),
    );
  }
}

class _DesktopScaffold extends StatefulWidget {
  final List<AccordionData> accordionData;

  const _DesktopScaffold({required this.accordionData});

  @override
  State<_DesktopScaffold> createState() => _DesktopScaffoldState();
}

class _DesktopScaffoldState extends State<_DesktopScaffold> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final sections = widget.accordionData.map((data) => data.title).toList();
    final selectedData = widget.accordionData[_selectedIndex];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Player Demo - Desktop'),
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SidebarSection(
            sections: sections,
            selectedIndex: _selectedIndex,
            onSectionSelected: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
          ),
          Expanded(
            child: VideoPlayerWidget(
              key: ValueKey('desktop_video_$_selectedIndex'),
              videoUrls: selectedData.videoUrls,
              isExpanded: true,
            ),
          ),
        ],
      ),
    );
  }
} 