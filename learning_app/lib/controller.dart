import 'package:learning_app/models/video_links.dart';

class VideoController {
  static List<AccordionData> getVideos() {
    return [
      AccordionData(
        title: 'Intro',
        videoUrls: introUrls,
      ),
      AccordionData(
        title: 'Paso 1',
        videoUrls: pasoUnoUrls,
      ),
      AccordionData(
        title: 'Paso 2',
        videoUrls: pasoDosUrls,
      ),
    ];
  }
}