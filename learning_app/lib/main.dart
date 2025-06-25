import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

void main() => runApp(const VideoApp());

const String movieOne =
    "https://stream.mux.com/6xid2UmDgaZRybbQiOWTOeRF006lcls2QIjazfTaLPx00.m3u8";
const String movieTwo =
    "https://stream.mux.com/9yDN01VI8QmctgJEPF4i9evZIQFtR6CIwCnW1kt9uyyM.m3u8";
const String movieThree =
    "https://stream.mux.com/SW5iarXYcodHwfWkYlgzvUM5j9xqfxGfxYYYH02r4ZL00.m3u8";
const String movieFour =
    "https://stream.mux.com/1NeM2I7uIHVBRlqjzPijZu4Tzz01zcCvljDRFS005MNZ8.m3u8";
const String movieFive =
    "https://stream.mux.com/PXEyFShMfOW6PTarzJi4Hx8JZrI500Zd00HRuPao7hjyE.m3u8";

final List<String> videoUrls = [
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

class VideoPlayerWidget extends StatefulWidget {
  final List<String> videoUrls;
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

    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrls[index]));
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

  String _getThumbnailUrl(String videoUrl) {
    final playbackId = Uri.parse(videoUrl).pathSegments.first.split(".").first;
    return 'https://image.mux.com/$playbackId/thumbnail.jpg?width=400&height=200&fit_mode=smartcrop';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: widget.videoUrls.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  if (widget.isExpanded) {
                    _changeVideo(index);
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: _currentIndex == index
                              ? Colors.blue
                              : Colors.transparent,
                          width: 3.0,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(5),
                        child: Image.network(
                          _getThumbnailUrl(widget.videoUrls[index]),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.error),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
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

class VideoApp extends StatefulWidget {
  const VideoApp({super.key});

  @override
  _VideoAppState createState() => _VideoAppState();
}

class _VideoAppState extends State<VideoApp> {
  int _openAccordionIndex = 0; // Track which accordion is open

  void _toggleAccordion(int index) {
    setState(() {
      if (_openAccordionIndex == index) {
        // If clicking the same accordion, close it
        _openAccordionIndex = -1;
      } else {
        // Open the clicked accordion and close others
        _openAccordionIndex = index;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Video Player Demo',
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Video Player Demo'),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              AccordionWidget(
                title: 'Video Player 1',
                isExpanded: _openAccordionIndex == 0,
                onToggle: () => _toggleAccordion(0),
                child: SizedBox(
                  height: 400,
                  child: VideoPlayerWidget(
                    videoUrls: videoUrls,
                    isExpanded: _openAccordionIndex == 0, // Pass isExpanded
                  ),
                ),
              ),
              AccordionWidget(
                title: 'Video Player 2',
                isExpanded: _openAccordionIndex == 1,
                onToggle: () => _toggleAccordion(1),
                child: SizedBox(
                  height: 400,
                  child: VideoPlayerWidget(
                    videoUrls: videoUrls.reversed.toList(),
                    isExpanded: _openAccordionIndex == 1, // Pass isExpanded
                  ),
                ),
              ),
              AccordionWidget(
                title: 'Video Player 3',
                isExpanded: _openAccordionIndex == 2,
                onToggle: () => _toggleAccordion(2),
                child: SizedBox(
                  height: 400,
                  child: VideoPlayerWidget(
                    videoUrls: [movieOne, movieThree, movieFive],
                    isExpanded: _openAccordionIndex == 2, // Pass isExpanded
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}