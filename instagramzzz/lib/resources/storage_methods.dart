import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class StorageMethods {
  final FirebaseStorage _storage = FirebaseStorage.instanceFor(bucket: 'ig-clone-2c574.appspot.com');

  final FirebaseAuth _auth = FirebaseAuth.instance;

  // add image to firebase storage
  Future<String> uploadImageToStorage(
    String childName,
    Uint8List file,
    bool isPost,
  ) async {
    Reference ref =
        _storage.ref().child(childName).child(_auth.currentUser!.uid);
    // create the folder of path way for the storage folder

    if (isPost) {
      // if it is a post we can generate a unique id,
      String id = Uuid().v1();
      // the name of the post is gonna be that unique id
      ref = ref.child(id);
    }

    UploadTask uploadTask = ref.putData(file);

    TaskSnapshot snap = await uploadTask;

    String downloadURL = await snap.ref.getDownloadURL();

    return downloadURL;
  }
}
