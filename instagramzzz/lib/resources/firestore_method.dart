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

      await _firestore.collection('posts').doc(postId).set({
        ...post.toJson(),
        'commentCount': 0, // Add this field
      });

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

        // Use batch write for atomic operations
        WriteBatch batch = _firestore.batch();

        // Add comment
        DocumentReference commentRef = _firestore
            .collection('posts')
            .doc(postId)
            .collection('comments')
            .doc(commentId);

        batch.set(commentRef, {
          'profPic': profPic,
          'name': name,
          'uid': uid,
          'text': text,
          'commentId': commentId,
          'datePublished': DateTime.now(),
          'likes': [],
          // initialize likes as an empty list first then we can store like count in firebase
          // just like the likePost function.
        });

        // Increment comment count
        DocumentReference postRef = _firestore.collection('posts').doc(postId);
        batch.update(postRef, {
          'commentCount': FieldValue.increment(1),
        });

        await batch.commit();
      } else {
        print('Text is empty');
      }
    } catch (e) {
      e.toString();
    }
  }

  // Like a comment
  Future<void> likeComment(
    String postId,
    String commentId,
    String uid,
    List likes,
  ) async {
    try {
      final commentRef = _firestore
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .doc(commentId);

      if (likes.contains(uid)) {
        // If the user already liked the comment in the past, remove the like
        await commentRef.update({
          'likes': FieldValue.arrayRemove([uid])
        });
      } else {
        // If the user hasn't liked the comment yet, add the like
        await commentRef.update({
          'likes': FieldValue.arrayUnion([uid])
        });
      }
    } catch (e) {
      print('Error liking comment: ${e.toString()}');
    }
  }

  // deleting comment
  Future<void> deleteComment(String postId, String commentId) async {
    try {
      WriteBatch batch = _firestore.batch();

      // Delete comment
      DocumentReference commentRef = _firestore
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .doc(commentId);
      batch.delete(commentRef);

      // Decrement count
      DocumentReference postRef = _firestore.collection('posts').doc(postId);
      batch.update(postRef, {
        'commentCount': FieldValue.increment(-1),
      });

      await batch.commit();
    } catch (e) {
      print('Error deleting comment: $e');
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

  // remove user from follow screen
  Future<void> removeUser(String uid, String followId) async {
    try {
      DocumentSnapshot snap =
          await _firestore.collection('users').doc(uid).get();
      List followers = (snap.data()! as dynamic)['followers'];

      if (followers.contains(followId)) {
        await _firestore.collection('users').doc(followId).update({
          'following': FieldValue.arrayRemove([uid]),
        });

        await _firestore.collection('users').doc(uid).update({
          'followers': FieldValue.arrayRemove([followId]),
        });
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> deleteAccount(String uid) async {
    try {
      // Start a batch for atomic operations
      WriteBatch batch = _firestore.batch();

      // Get user's document reference
      DocumentReference userRef = _firestore.collection('users').doc(uid);

      // Get all posts by the user
      QuerySnapshot postSnapshot = await _firestore
          .collection('posts')
          .where('uid', isEqualTo: uid)
          .get();

      // Delete all posts by the user
      for (var doc in postSnapshot.docs) {
        batch.delete(doc.reference);
      }

      // Get all comments made by the user
      QuerySnapshot commentSnapshot = await _firestore
          .collectionGroup('comments')
          .where('uid', isEqualTo: uid)
          .get();

      // Delete all comments made by the user
      for (var doc in commentSnapshot.docs) {
        batch.delete(doc.reference);
      }

      // Get all users for updating followers/following lists
      QuerySnapshot userSnapshot = await _firestore.collection('users').get();
      for (var doc in userSnapshot.docs) {
        if (doc.id != uid) {
          batch.update(doc.reference, {
            'followers': FieldValue.arrayRemove([uid]),
            'following': FieldValue.arrayRemove([uid]),
          });
        }
      }

      // Finally, delete the user's document
      batch.delete(userRef);

      // Commit the batch
      await batch.commit();

      print("User and related data removed successfully.");
    } catch (e) {
      print('Unable to remove user: ${e.toString()}');
    }
  }
}
