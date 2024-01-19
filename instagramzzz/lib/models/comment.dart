import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  late final String description;
  late final String uid;
  late final String username;
  late final datePublished;
  late final commentLikes;

  Comment({
    required this.description,
    required this.uid,
    required this.username,
    required this.datePublished,
    required this.commentLikes,
  });

  Map<String, dynamic> toJson() => {
        'username': username,
        'uid': uid,
        'description': description,
        'datePublished': datePublished,
        'commentLikes': commentLikes,
      };

  static Comment fromSnap(DocumentSnapshot<Object?> snap) {
    var snapshot = snap.data() as Map<String, dynamic>?;

    if (snapshot != null) {
      return Comment(
        username: snapshot['username'],
        uid: snapshot['uid'],
        description: snapshot['description'],
        commentLikes: snapshot['commentLikes'],
        datePublished: snapshot['datePublished'],
      );
    } else {
      // Handle the case when data is null, for example, return a default User.
      return Comment(
        description: '',
        uid: '',
        commentLikes: '',
        username: '',
        datePublished: '',
      );
    }
  }
}
