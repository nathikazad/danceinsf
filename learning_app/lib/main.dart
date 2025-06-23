import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';

void main() => runApp(VideoApp());

String movieOne = "https://stream.mux.com/6xid2UmDgaZRybbQiOWTOeRF006lcls2QIjazfTaLPx00.m3u8";
String movieTwo = "https://stream.mux.com/9yDN01VI8QmctgJEPF4i9evZIQFtR6CIwCnW1kt9uyyM.m3u8";
String movieThree = "https://stream.mux.com/SW5iarXYcodHwfWkYlgzvUM5j9xqfxGfxYYYH02r4ZL00.m3u8";
String movieFour = "https://stream.mux.com/1NeM2I7uIHVBRlqjzPijZu4Tzz01zcCvljDRFS005MNZ8.m3u8";
String movieFive = "https://stream.mux.com/PXEyFShMfOW6PTarzJi4Hx8JZrI500Zd00HRuPao7hjyE.m3u8";

class VideoApp extends StatefulWidget {
  @override
  _VideoAppState createState() => _VideoAppState();
}

class _VideoAppState extends State<VideoApp> {
  late VideoPlayerController _controller;
  ChewieController? _chewieController;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(
        Uri.parse('https://stream.mux.com/49VWJ8VuPEekO74MFQkJnUaeRMxiOXsSsfhhdQZSpAc.m3u8'));
      _controller.initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        setState(() {});
        // Initialize Chewie controller after video is initialized
        _chewieController = ChewieController(
          videoPlayerController: _controller,
          autoPlay: false,
          looping: false,
          aspectRatio: _controller.value.aspectRatio,
          allowFullScreen: true,
          allowMuting: true,
          showControls: true,
          placeholder: Container(
            color: Colors.black,
            child: const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
          ),
          materialProgressColors: ChewieProgressColors(
            playedColor: Colors.blue,
            handleColor: Colors.blue,
            backgroundColor: Colors.grey,
            bufferedColor: Colors.grey.shade300,
          ),
        );
        setState(() {});
      });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Video Demo',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Video Player Demo'),
        ),
        body: Center(
          child: _chewieController != null &&
                  _chewieController!.videoPlayerController.value.isInitialized
              ? Chewie(
                  controller: _chewieController!,
                )
              : const CircularProgressIndicator(),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _chewieController?.dispose();
    super.dispose();
  }
}