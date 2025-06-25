import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../models/video_links.dart';
import 'thumbnail_list_widget.dart';

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
  int _currentVideoIndex = 0;
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
    if (_currentVideoIndex == index && _chewieController != null) {
      return;
    }

    setState(() {
      _isLoading = true;
      _currentVideoIndex = index;
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
          currentIndex: _currentVideoIndex,
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