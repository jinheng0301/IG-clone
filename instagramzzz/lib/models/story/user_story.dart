class UserStory {
  static final UserStory user = UserStory(
    name: 'John Doe',
    profileImageUrl: 'https://wallpapercave.com/wp/AYWg3iu.jpg',
  );

  final String name;
  final String profileImageUrl;

  // Constructor
  UserStory({
    required this.name,
    required this.profileImageUrl,
  });
}
