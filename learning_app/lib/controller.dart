import 'package:learning_app/models/video_links.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class VideoController {
  static Future<List<AccordionData>> getVideosFromApi() async {
    // try {
      final response = await http.get(Uri.parse('https://sfdn.cc/video-links'));
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);  
        final List<AccordionData> accordionDataList = [];
        
        jsonData.forEach((key, value) {
          final Map<String, dynamic> sectionData = value as Map<String, dynamic>;
          final List<dynamic> videosData = sectionData['videos'] as List<dynamic>;
          
          final List<VideoLinks> videoLinks = videosData.map((videoData) {
            final Map<String, dynamic> video = videoData as Map<String, dynamic>;
            return VideoLinks(
              playbackId: video['playbackId'] as String,
              title: video['title'] as String,
              signed: video['signed'] as bool,
              streamUrl: video['streamUrl'] as String,
              thumbnailUrl: video['thumbnailUrl'] as String,
            );
          }).toList();
          
          accordionDataList.add(AccordionData(
            title: sectionData['title'] as String,
            videoUrls: videoLinks,
          ));
        });
        
        return accordionDataList;
      } else {
        throw Exception('Failed to load videos: ${response.statusCode}');
      }
    // } catch (e) {
    //   throw Exception('Error fetching videos: $e');
    // }
  }
}