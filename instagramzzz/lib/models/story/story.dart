enum MediaType {
  image,
  video,
}

class Story {
  late final String url;
  late MediaType media;
  late final Duration duration;
  late final user;

  Story({
    required this.url,
    required this.media,
    required this.duration,
    required this.user,
  });
}
