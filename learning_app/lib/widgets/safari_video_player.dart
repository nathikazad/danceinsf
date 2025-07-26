import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;
import 'dart:ui_web' as ui_web;

class SafariVideoPlayer extends StatefulWidget {
  final String videoUrl;
  final double aspectRatio;
  final double maxHeight;

  const SafariVideoPlayer({
    super.key,
    required this.videoUrl,
    this.aspectRatio = 16 / 9,
    this.maxHeight = 400,
  });

  @override
  State<SafariVideoPlayer> createState() => _SafariVideoPlayerState();
}

class _SafariVideoPlayerState extends State<SafariVideoPlayer> {
  static int _iframeCounter = 0;
  bool _isInitialized = false;
  late String _viewType;

  @override
  void initState() {
    super.initState();
    _viewType = 'safari-video-${_iframeCounter++}';
    _initializeIframe();
  }

  void _initializeIframe() {
    // Create iframe element using modern web package
    final iframeElement = web.document.createElement('iframe') as web.HTMLIFrameElement;
    iframeElement.src = widget.videoUrl;
    iframeElement.style.border = 'none';
    iframeElement.style.width = '100%';
    iframeElement.style.height = '100%';
    iframeElement.allowFullscreen = true;
    iframeElement.allow = 'autoplay; fullscreen';

    // Register the view factory
    ui_web.platformViewRegistry.registerViewFactory(
      _viewType,
      (int viewId) => iframeElement,
    );

    setState(() {
      _isInitialized = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: widget.maxHeight),
      child: Center(
        child: AspectRatio(
          aspectRatio: widget.aspectRatio,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(16),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: _isInitialized
                  ? HtmlElementView(
                      viewType: _viewType,
                      onPlatformViewCreated: (int id) {
                        // Platform view created
                      },
                    )
                  : Container(
                      color: Colors.black,
                      child: const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
} 