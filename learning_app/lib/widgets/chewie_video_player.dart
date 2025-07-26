import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

class ChewieVideoPlayer extends StatefulWidget {
  final String videoUrl;
  final double aspectRatio;
  final double maxHeight;

  const ChewieVideoPlayer({
    super.key,
    required this.videoUrl,
    this.aspectRatio = 16 / 9,
    this.maxHeight = 400,
  });

  @override
  State<ChewieVideoPlayer> createState() => _ChewieVideoPlayerState();
}

class _ChewieVideoPlayerState extends State<ChewieVideoPlayer> {
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  Future<void> _initializeVideo() async {
    _videoController = VideoPlayerController.networkUrl(
      Uri.parse(widget.videoUrl),
    );
    
    try {
      await _videoController!.initialize();
      
      _chewieController = ChewieController(
        videoPlayerController: _videoController!,
        autoPlay: true,
        looping: false,
        hideControlsTimer: const Duration(milliseconds: 1500),
        showControlsOnInitialize: true,
        showControls: true,
        pauseOnBackgroundTap: false,
        showSubtitles: false,
        allowFullScreen: true,
        cupertinoProgressColors: ChewieProgressColors(
          playedColor: Color(0xFF231404).withOpacity(0.5),
          handleColor: Color(0xFFFFA726),
          backgroundColor: Colors.white.withOpacity(0.2),
          bufferedColor: Colors.white.withOpacity(0.2),
        ),
        materialProgressColors: ChewieProgressColors(
          playedColor: Color(0xFF231404).withOpacity(0.5),
          handleColor: Color(0xFFFFA726),
          backgroundColor: Colors.white.withOpacity(0.2),
          bufferedColor: Colors.white.withOpacity(0.2),
        ),
      );

      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      print('Error initializing Chewie video: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: widget.maxHeight),
      child: AspectRatio(
        aspectRatio: widget.aspectRatio,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(16),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: _isInitialized && _chewieController != null
                ? Chewie(controller: _chewieController!)
                : Container(
                    color: Colors.black,
                    child: const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                  ),
          ),
        ),
      ),
    );
  }
} 