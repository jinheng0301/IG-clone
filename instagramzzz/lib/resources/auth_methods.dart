import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:instagramzzz/models/user.dart' as model;
import 'package:instagramzzz/resources/storage_methods.dart';

class AuthMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<model.User> getUserDetails() async {
    User? currentUser = _auth.currentUser;

    if (currentUser == null) {
      throw Exception('No current user found. Please log in again.');
    }

    try {
      DocumentSnapshot snap =
          await _firestore.collection('users').doc(currentUser.uid).get();

      if (!snap.exists) {
        await logOut(); // Log out if user is not found in the database
        throw Exception('User not found in the database. Logged out.');
      }

      return model.User.fromSnap(snap);
    } catch (e) {
      await logOut(); // Ensure user is logged out if any error occurs
      throw Exception('Error fetching user details: $e');
    }
  }

  // sign up user
  // Future: all the calls that we make to the firebase is asynchronous
  // so the functions return type changes to the Future
  // the data type is Stirng
  Future<String> signUpUser({
    required String email,
    required String password,
    required String username,
    required String bio,
    required Uint8List file,
  }) async {
    try {
      // Validate input fields
      if (email.isEmpty ||
          password.isEmpty ||
          username.isEmpty ||
          bio.isEmpty) {
        return "Please fill in all fields.";
      }

      // Validate email format
      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
        return 'Invalid email format.';
      }

      // Validate password strength
      if (password.length < 6) {
        return 'Password should be at least 6 characters.';
      }

      // Attempt user creation with retries
      UserCredential? cred;
      for (int attempt = 0; attempt < 3; attempt++) {
        try {
          cred = await _auth.createUserWithEmailAndPassword(
            email: email,
            password: password,
          );
          break;
        } on FirebaseAuthException catch (err) {
          if (err.code == 'too-many-requests') {
            await Future.delayed(Duration(seconds: 5 * (attempt + 1)));
            continue;
          }
          return _mapAuthError(err);
        }
      }

      if (cred == null) {
        return "Unable to create user account. Please try again later.";
      }

      // Upload profile picture with error handling
      String photoUrl;
      try {
        photoUrl = await StorageMethods().uploadImageToStorage(
          'profilePics',
          file,
          false,
        );
      } catch (storageError) {
        // If image upload fails, use a default image
        photoUrl = 'assets/images/Default_pfp.svg.png';
        print('Profile image upload failed: $storageError');
      }

      // Create user model
      model.User user = model.User(
        username: username,
        uid: cred.user!.uid,
        email: email,
        bio: bio,
        photoUrl: photoUrl,
        followers: [],
        following: [],
      );

      // Add user to Firestore with retry
      for (int attempt = 0; attempt < 3; attempt++) {
        try {
          await _firestore
              .collection('users')
              .doc(cred.user!.uid)
              .set(user.toJson());
          break;
        } catch (firestoreError) {
          if (attempt == 2) {
            // If all attempts fail, delete the created user
            await cred.user?.delete();
            return "Failed to create user profile. Please try again.";
          }
          await Future.delayed(Duration(seconds: 2));
        }
      }

      return 'Success';
    } catch (err) {
      print("Unexpected error during signup: $err");
      return "An unexpected error occurred. Please try again.";
    }
  }

// Helper method to map Firebase Auth errors
  String _mapAuthError(FirebaseAuthException err) {
    switch (err.code) {
      case 'email-already-in-use':
        return 'Email is already registered.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'weak-password':
        return 'Password is too weak.';
      case 'operation-not-allowed':
        return 'Email/password accounts are not enabled.';
      default:
        return 'Authentication failed: ${err.message}';
    }
  }

  // logging in user
  Future<String> loginUser({
    required String email,
    required String password,
  }) async {
    String res = 'Some error occurred.';
    try {
      if (email.isNotEmpty && password.isNotEmpty) {
        UserCredential cred = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        print("User signed in: ${cred.user?.uid}");
        res = 'Success';
      } else {
        res = "Please enter all the fields";
      }
    } on FirebaseAuthException catch (err) {
      res = "Firebase Auth Error: ${err.message}";
    } catch (err) {
      res = "General Error: $err";
    }

    return res;
  }

  // logging out user
  Future<void> logOut() async {
    await _auth.signOut();
  }
}
