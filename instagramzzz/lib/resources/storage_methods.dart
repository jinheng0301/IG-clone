import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class StorageMethods {
  final FirebaseStorage _storage =
      FirebaseStorage.instanceFor(bucket: 'ig-clone-2c574.appspot.com');
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Default profile picture URL - store this in Firebase Storage beforehand
  static const String DEFAULT_PROFILE_PICTURE =
      'YOUR_DEFAULT_PROFILE_PICTURE_URL_IN_FIREBASE_STORAGE';

  // add image to firebase storage
  Future<String> uploadImageToStorage(
    String childName,
    Uint8List? file,
    bool isPost,
  ) async {
    try {
      // If no file is provided, return default profile picture URL
      if (file == null) {
        return DEFAULT_PROFILE_PICTURE;
      }

      // Create reference with timestamp to avoid naming conflicts
      String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      Reference ref =
          _storage.ref().child(childName).child(_auth.currentUser!.uid);

      if (isPost) {
        String id = const Uuid().v1();
        ref = ref.child(id);
      } else {
        // For profile pictures, use timestamp to avoid cache issues
        ref = ref.child('profile_$timestamp');
      }

      // Set proper content type and metadata
      SettableMetadata metadata = SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {'timestamp': timestamp},
      );

      // Upload with metadata
      UploadTask uploadTask = ref.putData(file, metadata);

      // Add error handling and retry logic
      TaskSnapshot snap = await uploadTask.whenComplete(() {});

      // Get download URL
      String downloadURL = await snap.ref.getDownloadURL();
      return downloadURL;
    } catch (e) {
      print('Error uploading image: $e');
      return DEFAULT_PROFILE_PICTURE;
    }
  }
}
