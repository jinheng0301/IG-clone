import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

// pickImage(ImageSource source) async {
//   final ImagePicker _imagePicker = ImagePicker();

//   XFile? _file = await _imagePicker.pickImage(source: source);

//   if (_file != null) {
//     return await _file.readAsBytes();
//   }

//   print('no image selected');
// }

Future<Uint8List?> pickImage(ImageSource source) async {
  XFile? pickedFile = await ImagePicker().pickImage(source: source);

  if (pickedFile != null) {
    File file = File(pickedFile.path);
    List<int> bytes = await file.readAsBytes();
    return Uint8List.fromList(bytes);
  }

  return null;
}

showSnackBar(String content, BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(content),
    ),
  );
}
