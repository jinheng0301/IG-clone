import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:instagramzzz/resources/storage_methods.dart';

class AuthMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // sign up user
  // Future: all the calls that we make to the firebase is asynchronous
  // so the functions return type changes to the Future
  // the data type is Stirng
  Future<String> signUpUser({
    required String email,
    required String password,
    required String username,
    required String bio,
    // required Uint8List file,
  }) async {
    String res = "Some error occurred";

    try {
      if (email.isNotEmpty ||
          password.isNotEmpty ||
          username.isNotEmpty ||
          bio.isNotEmpty) {
        // register user
        UserCredential cred = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        print(cred.user!.uid);

        // String photoURL = await StorageMethods()
        //     .uploadImageToStorage('profilePics', file, false);

        // add user to database
        // we need to create a collection users if it doen't exist, then we need to make this document if it's not there
        // and set this data
        // ! means user can returned as null
        await _firestore.collection('users').doc(cred.user!.uid).set({
          'username': username,
          'uid': cred.user!.uid,
          'email': email,
          'bio': bio,
          'followers': [],
          'following': [],
          // 'pthotoURL': photoURL,
        });

        res = 'Success';
      }
    } on FirebaseAuthException catch (err) {
      if (err.code == 'invalid email') {
        res = 'The email is badly formatted.';
      } else if (err.code == 'weak password') {
        res = 'Password should be at least 6 characters';
      }
    } catch (err) {
      res = err.toString();
    }
    return res;
  }
}
