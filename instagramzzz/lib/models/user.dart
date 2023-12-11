class User {
  late final String email;
  late final String uid;
  // late final String photoUrl;
  late final String username;
  late final String bio;
  late final followers;
  late final following;

  User({
    required this.email,
    required this.uid,
    // required this.photoUrl,
    required this.username,
    required this.bio,
    required this.followers,
    required this.following,
  });

  Map<String, dynamic> toJson() => {
        'username': username,
        'uid': uid,
        'email': email,
        // 'photoUrl': photoUrl,
        'bio': bio,
        'followers': followers,
        'following': following,
      };
}
