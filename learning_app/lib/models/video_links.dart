class VideoLinks {
  String url;
  String title;

  VideoLinks({required this.url, required this.title});
}

VideoLinks movieOne =
    VideoLinks(url: "https://stream.mux.com/6xid2UmDgaZRybbQiOWTOeRF006lcls2QIjazfTaLPx00.m3u8", title: "Musica");
VideoLinks movieTwo =
    VideoLinks(url: "https://stream.mux.com/9yDN01VI8QmctgJEPF4i9evZIQFtR6CIwCnW1kt9uyyM.m3u8", title: "Cuentas");
VideoLinks movieThree =
    VideoLinks(url: "https://stream.mux.com/SW5iarXYcodHwfWkYlgzvUM5j9xqfxGfxYYYH02r4ZL00.m3u8", title: "Chicos");
VideoLinks movieFour =
    VideoLinks(url: "https://stream.mux.com/1NeM2I7uIHVBRlqjzPijZu4Tzz01zcCvljDRFS005MNZ8.m3u8", title: "Chicas");
VideoLinks movieFive =
    VideoLinks(url: "https://stream.mux.com/PXEyFShMfOW6PTarzJi4Hx8JZrI500Zd00HRuPao7hjyE.m3u8", title: "Extra");

final List<VideoLinks> videoUrls = [
  movieOne,
  movieTwo,
  movieThree,
  movieFour,
  movieFive,
];

class AccordionData {
  final String title;
  final List<VideoLinks> videoUrls;

  AccordionData({
    required this.title,
    required this.videoUrls,
  });
} 