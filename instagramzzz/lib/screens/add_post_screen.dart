import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instagramzzz/models/user.dart';
import 'package:instagramzzz/providers/user_provider.dart';
import 'package:instagramzzz/resources/firestore_method.dart';
import 'package:instagramzzz/utils/colors.dart';
import 'package:instagramzzz/utils/utils.dart';
import 'package:provider/provider.dart';

class AddPostScreen extends StatefulWidget {
  const AddPostScreen({super.key});

  @override
  State<AddPostScreen> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  Uint8List? _file;
  bool _isLoading = false;
  final TextEditingController _desciptionController = TextEditingController();

  void postImage(String uid, String username, String profImage) async {
    setState(() {
      _isLoading = true;
    });

    try {
      String res = await FirestoreMethods().uploadPost(
        _desciptionController.text,
        username,
        profImage,
        _file!,
        uid,
      );

      if (res == 'Success') {
        setState(() {
          _isLoading = false;
        });

        showSnackBar('Posted', context);

        clearImage();
      } else {
        setState(() {
          _isLoading = false;
        });

        showSnackBar(res, context);
      }
    } catch (err) {
      showSnackBar(err.toString(), context);
    }
  }

  _selectImage(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: Text('Create a post'),
          children: [
            SimpleDialogOption(
              padding: EdgeInsets.all(20),
              child: Text(
                'Take a photo',
              ),
              onPressed: () async {
                Navigator.of(context).pop();
                Uint8List? file = await pickImage(ImageSource.camera);
                setState(() {
                  _file = file;
                });
              },
            ),
            SimpleDialogOption(
              padding: EdgeInsets.all(20),
              child: Text(
                'Choose from gallery',
              ),
              onPressed: () async {
                Navigator.of(context).pop();
                Uint8List? file = await pickImage(ImageSource.gallery);
                setState(() {
                  _file = file;
                });
              },
            ),
            SimpleDialogOption(
              padding: EdgeInsets.all(20),
              child: Text(
                'Cancel',
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void clearImage() {
    setState(() {
      _file == null;
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _desciptionController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final User user = Provider.of<UserProvider>(context).getUser;

    return _file == null
        ? Center(
            child: IconButton(
              onPressed: () => _selectImage(context),
              icon: Icon(
                Icons.upload,
              ),
            ),
          )
        : Scaffold(
            appBar: AppBar(
              backgroundColor: mobileBackgroundColor,
              leading: IconButton(
                onPressed: clearImage,
                icon: Icon(
                  Icons.arrow_back,
                ),
              ),
              title: Text(
                'Post To',
              ),
              actions: [
                TextButton(
                  onPressed: () => postImage(
                    user.uid,
                    user.username,
                    user.photoUrl,
                  ),
                  child: Text(
                    'Post',
                    style: TextStyle(
                      color: Colors.blueAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                )
              ],
            ),
            body: Column(
              children: [
                _isLoading
                    ? LinearProgressIndicator()
                    : Padding(
                        padding: EdgeInsets.only(top: 0),
                      ),
                Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    CircleAvatar(
                      backgroundImage: NetworkImage(
                        user.photoUrl,
                      ),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.6,
                      child: TextField(
                        controller: _desciptionController,
                        decoration: InputDecoration(
                          hintText: 'Write a caption...',
                          border: InputBorder.none,
                        ),
                        maxLines: 8,
                      ),
                    ),
                    SizedBox(
                      height: 45,
                      width: 45,
                      child: AspectRatio(
                        aspectRatio: 487 / 451,
                        child: Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: MemoryImage(_file!),
                              fit: BoxFit.fill,
                              alignment: FractionalOffset.topCenter,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Divider(),
                  ],
                )
              ],
            ),
          );
  }
}
