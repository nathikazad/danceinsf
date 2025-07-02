import 'package:flutter/material.dart';
import 'package:learning_app/controller.dart';
import '../models/video_links.dart';
import '../services/storage_service.dart';
import '../widgets/sidebar_section.dart';
import '../widgets/video_player_widget.dart';

class DesktopVideoApp extends StatefulWidget {
  const DesktopVideoApp({super.key});

  @override
  State<DesktopVideoApp> createState() => _DesktopVideoAppState();
}

class _DesktopVideoAppState extends State<DesktopVideoApp> {
  List<AccordionData>? accordionData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    VideoController.getVideosFromApi().then((value) {
      setState(() {
        accordionData = value;
        isLoading = false;
      });
    });
    // }).catchError((error) {
    //   setState(() {
    //     isLoading = false;
    //   });
    //   print('Error loading videos: $error');
    // });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return MaterialApp(
        title: 'Only Bachateros',
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    if (accordionData == null) {
      return MaterialApp(
        title: 'Only Bachateros',
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(
            child: Text('Error loading videos'),
          ),
        ),
      );
    }

    return MaterialApp(
      title: 'Only Bachateros',
      debugShowCheckedModeBanner: false,
      home: _DesktopScaffold(accordionData: accordionData!),
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
  void initState() {
    super.initState();
    _loadSelectedIndex();
  }

  Future<void> _loadSelectedIndex() async {
    final savedIndex = await StorageService.getExpandedAccordionIndex();
    // Ensure the saved index is within bounds
    final validIndex = savedIndex < widget.accordionData.length ? savedIndex : 0;
    
    setState(() {
      _selectedIndex = validIndex;
    });
  }

  Future<void> _selectSection(int index) async {
    setState(() {
      _selectedIndex = index;
    });
    await StorageService.saveExpandedAccordionIndex(index);
  }

  @override
  Widget build(BuildContext context) {
    final sections = widget.accordionData.map((data) => data.title).toList();
    final selectedData = widget.accordionData[_selectedIndex];

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SidebarSection(
            sections: sections,
            selectedIndex: _selectedIndex,
            onSectionSelected: _selectSection,
          ),
          Expanded(
            child: VideoPlayerWidget(
              key: ValueKey('desktop_video_$_selectedIndex'),
              videoUrls: selectedData.videoUrls,
              isExpanded: true,
              forDesktop: true,
              sectionTitle: selectedData.title,
            ),
          ),
        ],
      ),
    );
  }
} 