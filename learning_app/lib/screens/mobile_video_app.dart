import 'package:flutter/material.dart';
import 'package:learning_app/controller.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import '../models/video_links.dart';
import '../services/storage_service.dart';
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
    VideoController.getVideosFromApi().then((value) {
      setState(() {
        accordionData = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pura Bachata',
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
  final ItemScrollController itemScrollController = ItemScrollController();
  final ScrollOffsetController scrollOffsetController = ScrollOffsetController();
  final ItemPositionsListener itemPositionsListener = ItemPositionsListener.create();
  final ScrollOffsetListener scrollOffsetListener = ScrollOffsetListener.create();
  bool _hasScrolledToInitialPosition = false;

  @override
  void initState() {
    super.initState();
    _loadExpandedAccordionIndex();
  }

  Future<void> _loadExpandedAccordionIndex() async {
    final savedIndex = await StorageService.getExpandedAccordionIndex();
    // Ensure the saved index is within bounds
    final validIndex = savedIndex < widget.accordionData.length ? savedIndex : 0;
    
    setState(() {
      _openAccordionIndex = validIndex;
    });

    // Scroll to the loaded accordion index only once
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (validIndex >= 0 && 
          validIndex < widget.accordionData.length && 
          !_hasScrolledToInitialPosition) {
        _scrollToAccordion(validIndex);
        _hasScrolledToInitialPosition = true;
      }
    });
  }

  void _scrollToAccordion(int index) {
    if (index >= 0 && index < widget.accordionData.length) {
      itemScrollController.scrollTo(
        index: index,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  Future<void> _toggleAccordion(int index) async {
    final newIndex = _openAccordionIndex == index ? -1 : index;
    setState(() {
      _openAccordionIndex = newIndex;
    });
    
    // Save the expanded accordion index (only if an accordion is open)
    if (newIndex >= 0) {
      await StorageService.saveExpandedAccordionIndex(newIndex);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pura Bachata'),
      ),
      body: ScrollablePositionedList.builder(
        itemCount: widget.accordionData.length,
        itemScrollController: itemScrollController,
        scrollOffsetController: scrollOffsetController,
        itemPositionsListener: itemPositionsListener,
        scrollOffsetListener: scrollOffsetListener,
        itemBuilder: (context, index) {
          final data = widget.accordionData[index];
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
        },
      ),
    );
  }
} 