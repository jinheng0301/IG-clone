import 'dart:typed_data';
import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:instagramzzz/models/post.dart';
import 'package:instagramzzz/resources/storage_methods.dart';

class FirestoreMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // upload post
  Future<String> uploadPost(
    String description,
    String username,
    String profImage,
    Uint8List file,
    String uid,
  ) async {
    String res = 'Some error occured';

    try {
      String photoUrl = await StorageMethods().uploadImageToStorage(
        'posts',
        file,
        true,
      );

      String postId = Uuid().v1(); // create a unique id based on time

      Post post = Post(
        description: description,
        uid: uid,
        username: username,
        postId: postId,
        datePublished: FieldValue.serverTimestamp(),
        // This ensures that the documents are retrieved in descending order based on the 'datePublished' field,
        // allowing the latest post to be displayed at the top.
        postUrl: photoUrl,
        profImage: profImage,
        likes: [],
      );

      _firestore.collection('posts').doc(postId).set(post.toJson());

      res = 'Success';
    } catch (err) {
      res = err.toString();
    }

    return res;
  }

  // updating likes
  Future<void> likePost(String postId, String uid, List likes) async {
    try {
      if (likes.contains(uid)) {
        // we already liked the post in the past
        await _firestore.collection('posts').doc(postId).update({
          'likes': FieldValue.arrayRemove([uid])
        });
      } else {
        await _firestore.collection('posts').doc(postId).update({
          'likes': FieldValue.arrayUnion([uid])
        });
      }
    } catch (e) {
      print(e.toString());
    }
  }

  // store comments in firebase
  Future<void> postComment(
    String postId,
    String text,
    String uid,
    String name,
    String profPic,
  ) async {
    try {
      if (text.isNotEmpty) {
        String commentId = Uuid().v1();
        await _firestore
            .collection('posts')
            .doc(postId)
            .collection('comments')
            .doc(commentId)
            .set({
          'profPic': profPic,
          'name': name,
          'uid': uid,
          'text': text,
          'commentId': commentId,
          'datePublished': DateTime.now(),
        });
      } else {
        print('Text is empty');
      }
    } catch (e) {
      e.toString();
    }
  }

  // deleting comment
  Future<void> deleteComment(String postId, String commentId) async {
    try {
      await _firestore
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .doc(commentId)
          .delete();
    } catch (e) {
      print('Error deleting comment: $e');
      // Optionally, you can handle the error or throw it again based on your requirements
      throw e;
    }
  }

  // deleting post
  Future<void> deletePost(String postId) async {
    try {
      await _firestore.collection('posts').doc(postId).delete();
    } catch (e) {
      print(e.toString());
    }
  }

  // follow the users
  Future<void> followUser(String uid, String followId) async {
    try {
      DocumentSnapshot snap =
          await _firestore.collection('users').doc(uid).get();
      List following = (snap.data()! as dynamic)['following'];

      if (following.contains(followId)) {
        // unfollow user when the userId is same
        await _firestore.collection('users').doc(followId).update({
          'followers': FieldValue.arrayRemove([uid]),
        });

        // remove the user from the 'following' subcollection
        await _firestore.collection('users').doc(uid).update({
          'following': FieldValue.arrayRemove([followId]),
        });
      } else {
        // follow user when the followId is not contained in 'following'
        await _firestore.collection('users').doc(followId).update({
          'followers': FieldValue.arrayUnion([uid]),
        });

        // add the user to the 'following' subcollection
        await _firestore.collection('users').doc(uid).update({
          'following': FieldValue.arrayUnion([followId]),
        });
      }
    } catch (e) {
      print(e.toString());
    }
  }
}
