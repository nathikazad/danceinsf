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

class VideoApp extends StatefulWidget {
  const VideoApp({super.key});

  @override
  _VideoAppState createState() => _VideoAppState();
}

class _VideoAppState extends State<VideoApp> {
  VideoPlayerController? _controller;
  ChewieController? _chewieController;
  int _currentIndex = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _changeVideo(0);
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

    _controller = VideoPlayerController.networkUrl(Uri.parse(videoUrls[index]));
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
    });
  }

  String _getThumbnailUrl(String videoUrl) {
    final playbackId = Uri.parse(videoUrl).pathSegments.first.split(".").first;
    String str = 'https://image.mux.com/$playbackId/thumbnail.jpg?width=400&height=200&fit_mode=smartcrop';
    return str;
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
        body: Column(
          children: [
            SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: videoUrls.length,
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
                              _getThumbnailUrl(videoUrls[index]),
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
                child: _isLoading || _chewieController == null
                    ? const CircularProgressIndicator()
                    : Chewie(
                        controller: _chewieController!,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}