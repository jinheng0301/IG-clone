import 'dart:typed_data';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:instagramzzz/config/cloudinary_config.dart';
import 'package:uuid/uuid.dart';

class StorageMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Replace this with a real public fallback image URL if profile upload is optional.
  static const String DEFAULT_PROFILE_PICTURE =
      'https://res.cloudinary.com/demo/image/upload/v1312461204/sample.jpg';

  // Upload image bytes to Cloudinary and return the hosted URL.
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

      if (!CloudinaryConfig.isConfigured) {
        throw Exception(
          'Cloudinary is not configured. Pass CLOUDINARY_CLOUD_NAME and CLOUDINARY_UPLOAD_PRESET with --dart-define.',
        );
      }

      String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      String userId = _auth.currentUser!.uid;
      String publicId = isPost ? const Uuid().v1() : 'profile_$timestamp';

      final uri = Uri.parse(
        'https://api.cloudinary.com/v1_1/${CloudinaryConfig.cloudName}/image/upload',
      );
      final request = http.MultipartRequest('POST', uri)
        ..fields['upload_preset'] = CloudinaryConfig.uploadPreset
        ..fields['folder'] = '$childName/$userId'
        ..fields['public_id'] = publicId
        ..fields['overwrite'] = isPost ? 'false' : 'true'
        ..files.add(
          http.MultipartFile.fromBytes(
            'file',
            file,
            filename: '$publicId.jpg',
          ),
        );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      final body = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode < 200 || response.statusCode >= 300) {
        final error = body['error'];
        final message = error is Map<String, dynamic>
            ? error['message']
            : response.body;
        throw Exception('Cloudinary upload failed: $message');
      }

      final secureUrl = body['secure_url'] as String?;
      if (secureUrl == null || secureUrl.isEmpty) {
        throw Exception('Cloudinary upload did not return a secure_url.');
      }

      return secureUrl;
    } catch (e) {
      print('Error uploading image: $e');
      if (isPost) {
        rethrow;
      }
      return DEFAULT_PROFILE_PICTURE;
    }
  }
}
