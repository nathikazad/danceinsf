import 'package:flutter/material.dart';
import 'package:learning_app/controller.dart';
  import '../models/video_links.dart';
import '../widgets/accordion_widget.dart';
import '../widgets/video_player_widget.dart';

class MobileVideoApp extends StatefulWidget {
  const MobileVideoApp({super.key});

  @override
  State<MobileVideoApp> createState() => _MobileVideoAppState();
}

class _MobileVideoAppState extends State<MobileVideoApp> {
  late final List<AccordionData> accordionData;

  @override
  void initState() {
    super.initState();
    accordionData = VideoController.getVideos();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Video Player Demo - Mobile',
      debugShowCheckedModeBanner: false,
      home: _MobileScaffold(accordionData: accordionData),
    );
  }
}

class _MobileScaffold extends StatefulWidget {
  final List<AccordionData> accordionData;

  const _MobileScaffold({required this.accordionData});

  @override
  State<_MobileScaffold> createState() => _MobileScaffoldState();
}

class _MobileScaffoldState extends State<_MobileScaffold> {
  int _openAccordionIndex = 0;

  void _toggleAccordion(int index) {
    setState(() {
      if (_openAccordionIndex == index) {
        _openAccordionIndex = -1;
      } else {
        _openAccordionIndex = index;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Player Demo - Mobile'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: widget.accordionData.asMap().entries.map((entry) {
            final index = entry.key;
            final data = entry.value;
            return AccordionWidget(
              key: ValueKey('mobile_accordion_$index'),
              title: data.title,
              isExpanded: _openAccordionIndex == index,
              onToggle: () => _toggleAccordion(index),
              child: SizedBox(
                height: 400,
                child: VideoPlayerWidget(
                  key: ValueKey('mobile_video_$index'),
                  videoUrls: data.videoUrls,
                  isExpanded: _openAccordionIndex == index,
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
} 