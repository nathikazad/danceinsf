import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerWidget extends StatefulWidget {
  final List<String> videoUrls;

  const VideoPlayerWidget({
    super.key,
    required this.videoUrls,
  });

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  VideoPlayerController? _controller;
  ChewieController? _chewieController;
  bool _isLoading = true;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _initializeVideoPlayer();
  }

  Future<void> _initializeVideoPlayer() async {
    setState(() {
      _isLoading = true;
    });

    try {
      _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrls[_currentIndex]));
      await _controller!.initialize();

      _chewieController = ChewieController(
        videoPlayerController: _controller!,
        autoPlay: false,
        looping: false,
        showControls: true,
        pauseOnBackgroundTap: true
      );
    } catch (e) {
      print('Error initializing video: $e');
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _changeVideo(int index) async {
    if (_currentIndex == index && _chewieController != null) {
      return;
    }

    setState(() {
      _isLoading = true;
      _currentIndex = index;
    });

    _disposeControllers();

    try {
      _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrls[index]));
      await _controller!.initialize();

      _chewieController = ChewieController(
        videoPlayerController: _controller!,
        autoPlay: false,
        looping: false,
        showControls: true,
        pauseOnBackgroundTap: true
      );

    } catch (e) {
      print('Error changing video: $e');
    }

    setState(() {
      _isLoading = false;
    });
  }
  @override
  void dispose() {
    print('dispose');
    _disposeControllers();
    super.dispose();
  }

  void _disposeControllers() {
    _chewieController?.pause(); // Ensure video is paused before disposal
    _chewieController?.dispose();
    _controller?.dispose();
  }

  String _getThumbnailUrl(String videoUrl) {
    final playbackId = Uri.parse(videoUrl).pathSegments.first.split(".").first;
    return 'https://image.mux.com/$playbackId/thumbnail.jpg?width=400&height=200&fit_mode=smartcrop';
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: widget.videoUrls.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () => _changeVideo(index),
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
          const SizedBox(height: 16),
          AspectRatio(
            aspectRatio: 16 / 9,
            child: _isLoading || _chewieController == null
                ? const Center(child: CircularProgressIndicator())
                : Chewie(controller: _chewieController!),
          ),
        ],
      ),
    );
  }
}