import 'package:learning_app/models/video_links.dart';

class VideoController {
  static List<AccordionData> getVideos() {
    return [
      AccordionData(
        title: 'Intro',
        videoUrls: videoUrls,
      ),
      AccordionData(
        title: 'Paso 1',
        videoUrls: videoUrls.reversed.toList(),
      ),
      AccordionData(
        title: 'Paso 2',
        videoUrls: [movieOne, movieThree, movieFive],
      ),
    ];
  }
}