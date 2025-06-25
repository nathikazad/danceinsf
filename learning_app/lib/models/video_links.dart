import 'package:learning_app/services/jwt_service.dart';

class VideoLinks {
  String playbackId;
  String title;
  bool signed = false;

  VideoLinks({required this.playbackId, required this.title, this.signed = false});

  String get url {
    return JwtTokenService.generateStreamUrl(playbackId: playbackId, signed: signed);
  }

  String get thumbnailUrl {
    return JwtTokenService.generateThumbnailUrl(playbackId: playbackId, signed: signed);
  }
}

VideoLinks movieOne =
    VideoLinks(playbackId: "6xid2UmDgaZRybbQiOWTOeRF006lcls2QIjazfTaLPx00", title: "Musica");
VideoLinks movieTwo =
    VideoLinks(playbackId: "9yDN01VI8QmctgJEPF4i9evZIQFtR6CIwCnW1kt9uyyM", title: "Cuentas");
VideoLinks movieThree =
    VideoLinks(playbackId: "SW5iarXYcodHwfWkYlgzvUM5j9xqfxGfxYYYH02r4ZL00", title: "Chicos");
VideoLinks movieFour =
    VideoLinks(playbackId: "1NeM2I7uIHVBRlqjzPijZu4Tzz01zcCvljDRFS005MNZ8", title: "Chicas");
VideoLinks movieFive =
    VideoLinks(playbackId: "PXEyFShMfOW6PTarzJi4Hx8JZrI500Zd00HRuPao7hjyE", title: "Extra");

final List<VideoLinks> introUrls = [
  movieOne,
  movieTwo,
  movieThree,
  movieFour,
  movieFive,
];

VideoLinks pasoUnoMusica =
      VideoLinks(playbackId: "AQ55vZPsJJnzWziqMmrufpoGyRr5WOL8RGI1PgAGphY", title: "Musica", signed: false);
VideoLinks pasoUnoCuentas =
      VideoLinks(playbackId: "ZPnuFoZGQ01EFRuJwhq6qjWUdIcXxi00015i101aXWQluW8", title: "Cuentas", signed: false);
VideoLinks pasoUnoChicos =
      VideoLinks(playbackId: "74y1BX00aRR0201dLx0039m2Qm0253zQDjm3x9bc4RTv02kIM", title: "Chicos", signed: false);
VideoLinks pasoUnoChicas =
      VideoLinks(playbackId: "qq02MXs3kWmcyPS9P7DMgxZa4O6sP01h00le3z5oi5hz00g", title: "Chicas", signed: false);

final List<VideoLinks> pasoUnoUrls = [
  pasoUnoMusica,
  pasoUnoCuentas,
  pasoUnoChicos,
  pasoUnoChicas,
];

VideoLinks pasoDosMusica =
      VideoLinks(playbackId: "Qu86eMOGBCXYaPlmGLFoM6AEbmJ3Ia27BNjV99rtzmQ", title: "Musica", signed: true);
VideoLinks pasoDosCuentas =
      VideoLinks(playbackId: "35Lw4d3vY01bBPY9ZAu8uhLxs3kDLvAI6RlqzjPbMWps", title: "Cuentas", signed: true);

final List<VideoLinks> pasoDosUrls = [
  pasoDosMusica,
  pasoDosCuentas,
];


class AccordionData {
  final String title;
  final List<VideoLinks> videoUrls;

  AccordionData({
    required this.title,
    required this.videoUrls,
  });
} 