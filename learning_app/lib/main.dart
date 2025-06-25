import 'package:chewie/chewie.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Get the screen width
  final mediaQueryData = MediaQueryData.fromView(WidgetsBinding.instance.window);
  final screenWidth = mediaQueryData.size.width;
  print(screenWidth);
  // Decide based on width threshold (600px)
  if (screenWidth > 600) {
    // Desktop version
    runApp(const DesktopVideoApp());
  } else {
    // Mobile version
    runApp(const MobileVideoApp());
  }
}

class VideoLinks {
  String url;
  String title;

  VideoLinks({required this.url, required this.title});
}

VideoLinks movieOne =
    VideoLinks(url: "https://stream.mux.com/6xid2UmDgaZRybbQiOWTOeRF006lcls2QIjazfTaLPx00.m3u8", title: "Musica");
VideoLinks movieTwo =
    VideoLinks(url: "https://stream.mux.com/9yDN01VI8QmctgJEPF4i9evZIQFtR6CIwCnW1kt9uyyM.m3u8", title: "Cuentas");
VideoLinks movieThree =
    VideoLinks(url: "https://stream.mux.com/SW5iarXYcodHwfWkYlgzvUM5j9xqfxGfxYYYH02r4ZL00.m3u8", title: "Chicos");
VideoLinks movieFour =
    VideoLinks(url: "https://stream.mux.com/1NeM2I7uIHVBRlqjzPijZu4Tzz01zcCvljDRFS005MNZ8.m3u8", title: "Chicas");
VideoLinks movieFive =
    VideoLinks(url: "https://stream.mux.com/PXEyFShMfOW6PTarzJi4Hx8JZrI500Zd00HRuPao7hjyE.m3u8", title: "Extra");

final List<VideoLinks> videoUrls = [
  movieOne,
  movieTwo,
  movieThree,
  movieFour,
  movieFive,
];

class AccordionWidget extends StatefulWidget {
  final String title;
  final Widget child;
  final bool isExpanded;
  final VoidCallback onToggle;

  const AccordionWidget({
    super.key,
    required this.title,
    required this.child,
    required this.isExpanded,
    required this.onToggle,
  });

  @override
  State<AccordionWidget> createState() => _AccordionWidgetState();
}

class _AccordionWidgetState extends State<AccordionWidget> {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          ListTile(
            title: Text(
              widget.title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            trailing: Icon(
              widget.isExpanded ? Icons.expand_less : Icons.expand_more,
            ),
            onTap: widget.onToggle,
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.all(16.0),
              child: widget.child,
            ),
            crossFadeState: widget.isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
          ),
        ],
      ),
    );
  }
}

class ThumbnailListWidget extends StatelessWidget {
  final List<VideoLinks> videoUrls;
  final int currentIndex;
  final bool isExpanded;
  final Function(int) onVideoChange;

  const ThumbnailListWidget({
    super.key,
    required this.videoUrls,
    required this.currentIndex,
    required this.isExpanded,
    required this.onVideoChange,
  });

  String _getThumbnailUrl(String videoUrl) {
    final playbackId = Uri.parse(videoUrl).pathSegments.first.split(".").first;
    return 'https://image.mux.com/$playbackId/thumbnail.jpg?width=400&height=200&fit_mode=smartcrop';
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 140, // Increased to match Container height
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: videoUrls.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              if (isExpanded) {
                onVideoChange(index);
              }
            },
            child: Container(
              width: 200, // Define a fixed width
              height: 140, // Increased height to accommodate thumbnail + text
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: currentIndex == index
                                ? Colors.blue
                                : Colors.transparent,
                            width: 3.0,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(5),
                          child: Image.network(
                            _getThumbnailUrl(videoUrls[index].url),
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.error),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Text(
                    videoUrls[index].title,
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class VideoPlayerWidget extends StatefulWidget {
  final List<VideoLinks> videoUrls;
  final bool isExpanded;

  const VideoPlayerWidget({
    super.key,
    required this.videoUrls,
    required this.isExpanded,
  });

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  VideoPlayerController? _controller;
  ChewieController? _chewieController;
  int _currentIndex = 0;
  bool _isLoading = true;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    // Only initialize if the accordion is expanded
    if (widget.isExpanded) {
      _changeVideo(0);
    } else {
      setState(() {
        _isLoading = false; // Avoid showing loading indicator when not initialized
      });
    }
  }

  @override
  void didUpdateWidget(VideoPlayerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Initialize when accordion is expanded
    if (!oldWidget.isExpanded && widget.isExpanded && !_isInitialized) {
      _changeVideo(0);
    }
    // Pause when accordion is collapsed
    if (oldWidget.isExpanded && !widget.isExpanded && _chewieController != null) {
      _chewieController!.pause();
      _controller?.pause();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!widget.isExpanded && mounted) {
          _chewieController?.dispose();
          _controller?.dispose();
          setState(() {
            _chewieController = null;
            _controller = null;
            _isInitialized = false;
            _isLoading = false;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  Future<void> _changeVideo(int index) async {
    if (_currentIndex == index && _chewieController != null) {
      return;
    }

    setState(() {
      _isLoading = true;
      _currentIndex = index;
    });

    _chewieController?.dispose();
    _controller?.dispose();

    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrls[index].url));
    print('Initializing video ${widget.videoUrls[index]}');
    await _controller!.initialize();

    _chewieController = ChewieController(
      videoPlayerController: _controller!,
      autoPlay: false,
      looping: true,
      hideControlsTimer: const Duration(milliseconds: 500),
      showControlsOnInitialize: true,
      showControls: true,
    );

    setState(() {
      _isLoading = false;
      _isInitialized = true; // Mark as initialized
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ThumbnailListWidget(
          videoUrls: widget.videoUrls,
          currentIndex: _currentIndex,
          isExpanded: widget.isExpanded,
          onVideoChange: _changeVideo,
        ),
        Expanded(
          child: Center(
            child: _isLoading
                ? const CircularProgressIndicator()
                : (_chewieController == null || !widget.isExpanded)
                    ? const Text('Video not loaded') // Placeholder when not expanded
                    : Chewie(controller: _chewieController!),
          ),
        ),
      ],
    );
  }
}

class SidebarToggleButton extends StatelessWidget {
  final bool isSidebarVisible;
  final VoidCallback onToggle;

  const SidebarToggleButton({
    super.key,
    required this.isSidebarVisible,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 20,
      height: 20,
      child: IconButton(
        icon: Icon(
          isSidebarVisible ? Icons.chevron_left : Icons.chevron_right,
          color: Colors.black87,
          size: 16,
        ),
        onPressed: onToggle,
        style: IconButton.styleFrom(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          padding: EdgeInsets.zero,
        ),
      ),
    );
  }
}

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
              onToggle: () {
                setState(() {
                  _isSidebarVisible = !_isSidebarVisible;
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}

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

class AccordionData {
  final String title;
  final List<VideoLinks> videoUrls;

  AccordionData({
    required this.title,
    required this.videoUrls,
  });
}

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
    accordionData = [
      AccordionData(
        title: 'Intro',
        videoUrls: videoUrls,
      ),
      AccordionData(
        title: 'Paso 1',
        videoUrls: videoUrls.reversed.toList(),
      ),
      AccordionData(
        title: 'Paso 2',
        videoUrls: [movieOne, movieThree, movieFive],
      ),
    ];
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
    accordionData = [
      AccordionData(
        title: 'Intro',
        videoUrls: videoUrls,
      ),
      AccordionData(
        title: 'Paso 1',
        videoUrls: videoUrls.reversed.toList(),
      ),
      AccordionData(
        title: 'Paso 2',
        videoUrls: [movieOne, movieThree, movieFive],
      ),
    ];
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
