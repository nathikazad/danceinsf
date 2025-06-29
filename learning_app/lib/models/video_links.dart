import 'package:learning_app/services/jwt_service.dart';

class VideoLinks {
  String playbackId;
  String title;
  bool signed = false;
  String streamUrl;
  String thumbnailUrl;
  VideoLinks({required this.playbackId, required this.title, this.signed = false, required this.streamUrl, required this.thumbnailUrl});
}



class AccordionData {
  final String title;
  final List<VideoLinks> videoUrls;

  AccordionData({
    required this.title,
    required this.videoUrls,
  });
} 