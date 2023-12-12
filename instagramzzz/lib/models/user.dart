import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  late final String email;
  late final String uid;
  late final String photoUrl;
  late final String username;
  late final String bio;
  late final followers;
  late final following;

  User({
    required this.email,
    required this.uid,
    required this.photoUrl,
    required this.username,
    required this.bio,
    required this.followers,
    required this.following,
  });

  Map<String, dynamic> toJson() => {
        'username': username,
        'uid': uid,
        'email': email,
        'photoUrl': photoUrl,
        'bio': bio,
        'followers': followers,
        'following': following,
      };

  
  static User fromSnap(DocumentSnapshot<Object?> snap) {
  var snapshot = snap.data() as Map<String, dynamic>?;

  if (snapshot != null) {
    return User(
      username: snapshot['username'],
      uid: snapshot['uid'],
      email: snapshot['email'],
      photoUrl: snapshot['photoUrl'],
      bio: snapshot['bio'],
      followers: snapshot['followers'],
      following: snapshot['following'],
    );
  } else {
    // Handle the case when data is null, for example, return a default User.
    return User(
      email: '',
      uid: '',
      photoUrl: '',
      username: '',
      bio: '',
      followers: 0,
      following: 0,
    );
  }
}

}
