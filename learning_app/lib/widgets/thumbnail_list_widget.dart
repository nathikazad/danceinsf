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

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final maxWidth = 200.0;
    final containerWidth = (screenWidth * 0.25).clamp(80.0, maxWidth); // 25% of screen width, max 200
    final containerHeight = containerWidth * 0.8; // 80% of width for height
    final listHeight = containerHeight + 20; // Add some padding for text

    return SizedBox(
      height: listHeight,
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth * 4), // Allow up to 4 thumbnails
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
                  width: containerWidth,
                  height: listHeight,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(4.0), // Reduced from 8.0 to save space
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
                                videoUrls[index].thumbnailUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(Icons.error),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          videoUrls[index].title,
                          style: TextStyle(
                            fontSize: 15, // Reduced from 10
                            color: Colors.black,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
} 