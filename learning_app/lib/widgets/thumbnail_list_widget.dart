import 'package:flutter/material.dart';
import '../models/video_links.dart';

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