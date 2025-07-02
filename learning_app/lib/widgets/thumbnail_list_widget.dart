import 'dart:math';

import 'package:flutter/material.dart';
import '../models/video_links.dart';

class ThumbnailListWidget extends StatelessWidget {
  final List<VideoLinks> videoUrls;
  final int currentIndex;
  final bool isExpanded;
  final Function(int) onVideoChange;
  final bool forDesktop;

  const ThumbnailListWidget({
    super.key,
    required this.videoUrls,
    required this.currentIndex,
    required this.isExpanded,
    required this.onVideoChange,
    this.forDesktop = false,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final maxWidth = 200.0;
    final containerWidth = (screenWidth * 0.25).clamp(80.0, maxWidth); // 25% of screen width, max 200
    final containerHeight = containerWidth * 0.8; // 80% of width for height
    final listHeight = forDesktop ? containerHeight + 20 : containerHeight; // Add some padding for text

    return SizedBox(
      height: listHeight,
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth * min(6, videoUrls.length)), // Allow up to 4 thumbnails
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: videoUrls.length,
            itemBuilder: (context, index) {
              final isSelected = currentIndex == index;
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
                        padding: const EdgeInsets.all(4.0),
                        child: AspectRatio(
                          aspectRatio: 16 / 9,
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: isSelected
                                    ? Color(0xFFFFA726)
                                    : Colors.transparent,
                                width: isSelected ? 4.0 : 3.0,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: Color(0x33FFA726),
                                        blurRadius: 8,
                                        spreadRadius: 1,
                                      ),
                                    ]
                                  : [],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(9),
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
                            fontSize: 15,
                            color: isSelected ? Color(0xFFFFA726) : Color(0xFF222222),
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
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