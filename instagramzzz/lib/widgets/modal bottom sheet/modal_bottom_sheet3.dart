import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagramzzz/resources/firestore_method.dart';
import 'package:instagramzzz/utils/utils.dart';

class modalBottomSheet3 extends StatefulWidget {
  late final String uid;
  final bool initialFollowingState;
  final bool initialFollowBackState;
  final Function(bool, bool) onUpdate;
  modalBottomSheet3({
    required this.uid,
    required this.initialFollowingState,
    required this.initialFollowBackState,
    required this.onUpdate,
  });

  @override
  State<modalBottomSheet3> createState() => _ModalBottomSheet3State();
}

class _ModalBottomSheet3State extends State<modalBottomSheet3> {
  var firebaseAuth = FirebaseAuth.instance.currentUser!.uid; // current user ID
  var userData = {};
  int postLength = 0;
  int followers = 0;
  int following = 0;
  bool isFollowing = false;
  bool isFollowBack = false;
  bool isLoading = false;
  bool isUser = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getData();
  }

  void getData() async {
    setState(() {
      isLoading = true;
    });

    try {
      var userSnap = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.uid)
          .get();

      // get the following List
      var followingList = userSnap.data()!['following'];

      // get the post length
      var postSnap = await FirebaseFirestore.instance
          .collection('posts')
          .where('uid', isEqualTo: firebaseAuth)
          .get();

      userData = userSnap.data()!;
      postLength = postSnap.docs.length;
      followers = userSnap.data()!['followers'].length;

      // Update following count to the length of the following list
      following = followingList.length;

      // Check if the current user is following this user
      isFollowing = userSnap.data()!['followers'].contains(firebaseAuth);

      // Check if the current user is being followed back by this user
      isFollowBack = followingList.contains(firebaseAuth);

      setState(() {});
    } catch (e) {
      showSnackBar(e.toString(), context);
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Center(child: CircularProgressIndicator())
        : SizedBox(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.all(8),
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        userData['username'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 28,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(),
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    padding: const EdgeInsets.all(15),
                    child: const Text(
                      'Add to close friend list',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    padding: const EdgeInsets.all(15),
                    child: const Text(
                      'Mute',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    padding: const EdgeInsets.all(15),
                    child: const Text(
                      'Restrict',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    await FirestoreMethods().followUser(
                      FirebaseAuth.instance.currentUser!.uid,
                      userData['uid'],
                    );
                    setState(() {
                      isFollowing = false;
                      followers--;
                    });
                    widget.onUpdate(false, false);
                    Navigator.of(context).pop();
                    // dismiss the modal bottom sheet after unfollow button is tapped
                  },
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    padding: const EdgeInsets.all(15),
                    child: const Text(
                      'Unfollow',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
  }
}
