import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../models/video_links.dart';
import 'thumbnail_list_widget.dart';

// Custom fullscreen widget that preserves video state
class CustomFullscreenWidget extends StatefulWidget {
  final String videoUrl;
  final Duration initialPosition;
  final bool isFlipped;
  final Function(bool) onFlipStateChanged;

  const CustomFullscreenWidget({
    super.key,
    required this.videoUrl,
    required this.initialPosition,
    required this.isFlipped,
    required this.onFlipStateChanged,
  });

  @override
  State<CustomFullscreenWidget> createState() => _CustomFullscreenWidgetState();
}

class _CustomFullscreenWidgetState extends State<CustomFullscreenWidget> {
  late ChewieController _chewieController;
  late VideoPlayerController _videoController;
  late bool _isFlipped;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _isFlipped = widget.isFlipped;
    _initializeController();
  }

  Future<void> _initializeController() async {
    _videoController = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));
    
    try {
      await _videoController.initialize();
      
      _chewieController = ChewieController(
        videoPlayerController: _videoController,
        autoPlay: true,
        looping: false,
        hideControlsTimer: const Duration(milliseconds: 1500),
        showControlsOnInitialize: true,
        showControls: true,
        pauseOnBackgroundTap: false,
        showSubtitles: false,
        allowFullScreen: false,
        startAt: widget.initialPosition,
      );

      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      print('Error initializing fullscreen video: $e');
    }
  }

  @override
  void dispose() {
    _videoController.dispose();
    _chewieController.dispose();
    super.dispose();
  }

  void _toggleFlip() {
    setState(() {
      _isFlipped = !_isFlipped;
    });
    // Notify parent of flip state change
    widget.onFlipStateChanged(_isFlipped);
  }

  void _closeFullscreen() {
    _chewieController.pause();
    Navigator.of(context).pop(_videoController.value.position);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Video player with flip transform
            Center(
              child: _isInitialized
                  ? Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.rotationY(_isFlipped ? 3.14159 : 0),
                      child: Chewie(controller: _chewieController),
                    )
                  : const CircularProgressIndicator(color: Colors.white),
            ),
            // Flip button
            if (_isInitialized)
              Positioned(
                top: 16,
                right: 80, // Position it to the left of the fullscreen button
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.flip,
                      color: Colors.white,
                      size: 24,
                    ),
                    onPressed: _toggleFlip,
                    tooltip: 'Flip Video',
                  ),
                ),
              ),
            // Close button
            Positioned(
              top: 16,
              right: 28,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 24,
                  ),
                  onPressed: _closeFullscreen,
                  tooltip: 'Close',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class VideoPlayerWidget extends StatefulWidget {
  final List<VideoLinks> videoUrls;
  final bool isExpanded;
  final bool forDesktop;
  final String? sectionTitle;

  const VideoPlayerWidget({
    super.key,
    required this.videoUrls,
    required this.isExpanded,
    this.forDesktop = false,
    this.sectionTitle,
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
  bool _isFlipped = false;

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

  void _toggleFlip() {
    setState(() {
      _isFlipped = !_isFlipped;
    });
  }

  void _onFullscreenFlipStateChanged(bool isFlipped) {
    setState(() {
      _isFlipped = isFlipped;
    });
  }

  Future<void> _openFullscreen() async {
    if (_controller != null) {
      // Create a new controller with the same video source
      final currentPosition = _controller!.value.position;
      final videoUrl = widget.videoUrls[_currentVideoIndex].streamUrl;
      _chewieController?.pause();
      final position = await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => CustomFullscreenWidget(
            videoUrl: videoUrl,
            initialPosition: currentPosition,
            isFlipped: _isFlipped,
            onFlipStateChanged: _onFullscreenFlipStateChanged,
          ),
        ),
      );
      await _controller?.seekTo(position);
      _chewieController?.play();
    }
  }

  Future<void> _changeVideo(int index) async {
    if (_currentVideoIndex == index && _chewieController != null) {
      return;
    }

    setState(() {
      _isLoading = true;
      _currentVideoIndex = index;
      _isFlipped = false;
    });

    _chewieController?.dispose();
    _controller?.dispose();

    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrls[index].streamUrl));
    print('Initializing video ${widget.videoUrls[index]}');
    await _controller!.initialize();

    _chewieController = ChewieController(
      videoPlayerController: _controller!,
      autoPlay: false,
      looping: false,
      hideControlsTimer: const Duration(milliseconds: 1500),
      showControlsOnInitialize: true,
      showControls: true,
      pauseOnBackgroundTap: false,
      showSubtitles: false,
      allowFullScreen: false,
      
    );

    setState(() {
      _isLoading = false;
      _isInitialized = true; // Mark as initialized
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.forDesktop && widget.sectionTitle != null)
        Padding(
          padding: const EdgeInsets.only(left: 24, bottom: 8, top: 16),
          child: Text(
            widget.sectionTitle!,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ),
        // Thumbnails
        ThumbnailListWidget(
          videoUrls: widget.videoUrls,
          currentIndex: _currentVideoIndex,
          isExpanded: widget.isExpanded,
          onVideoChange: _changeVideo,
        ),
        // Video Player
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black,
              // borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.all(8),
            child: Stack(
              children: [
                Center(
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : (_chewieController == null || !widget.isExpanded)
                          ? const Text('Video not loaded')
                          : Transform(
                              alignment: Alignment.center,
                              transform: Matrix4.rotationY(_isFlipped ? 3.14159 : 0),
                              child: Chewie(controller: _chewieController!),
                            ),
                ),
                if (_chewieController != null && widget.isExpanded && !_isLoading)
                  Positioned(
                    top: 16,
                    right: 16,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Flip button
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: IconButton(
                            icon: Icon(
                              Icons.flip,
                              color: Colors.white,
                              size: 24,
                            ),
                            onPressed: _toggleFlip,
                            tooltip: 'Flip Video',
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Fullscreen button
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.fullscreen,
                              color: Colors.white,
                              size: 24,
                            ),
                            onPressed: _openFullscreen,
                            tooltip: 'Fullscreen',
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
} 
