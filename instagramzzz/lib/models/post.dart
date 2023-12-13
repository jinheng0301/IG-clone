import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  late final String description;
  late final String uid;
  late final String username;
  late final String postId;
  late final datePublished;
  late final postUrl;
  late final profImage;
  late final likes;

  Post({
    required this.description,
    required this.uid,
    required this.username,
    required this.postId,
    required this.datePublished,
    required this.postUrl,
    required this.profImage,
    required this.likes,
  });

  Map<String, dynamic> toJson() => {
        'username': username,
        'uid': uid,
        'description': description,
        'postId': postId,
        'datePublished': datePublished,
        'profImage': profImage,
        'postUrl': postUrl,
        'likes': likes,
      };

  static Post fromSnap(DocumentSnapshot<Object?> snap) {
    var snapshot = snap.data() as Map<String, dynamic>?;

    if (snapshot != null) {
      return Post(
        username: snapshot['username'],
        uid: snapshot['uid'],
        description: snapshot['description'],
        postId: snapshot['postId'],
        datePublished: snapshot['datePublished'],
        profImage: snapshot['profImage'],
        postUrl: snapshot['postUrl'],
        likes: snapshot['likes'],
      );
    } else {
      // Handle the case when data is null, for example, return a default User.
      return Post(
        description: '',
        uid: '',
        postId: '',
        username: '',
        datePublished: '',
        profImage: 0,
        postUrl: 0,
        likes: 0,
      );
    }
  }
}
