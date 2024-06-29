import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagramzzz/resources/auth_methods.dart';
import 'package:instagramzzz/resources/firestore_method.dart';
import 'package:instagramzzz/screens/auth_screens/login_screen.dart';
import 'package:instagramzzz/screens/extend_screens/message_screen.dart';
import 'package:instagramzzz/utils/colors.dart';
import 'package:instagramzzz/utils/utils.dart';
import 'package:instagramzzz/widgets/add_people_button.dart';
import 'package:instagramzzz/widgets/follow_button.dart';
import 'package:instagramzzz/widgets/message_or_share_profile_button.dart';
import 'package:instagramzzz/widgets/modal%20bottom%20sheet/modal_bottom_sheet3.dart';
import 'package:panara_dialogs/panara_dialogs.dart';

class threeTypesOfButtons extends StatefulWidget {
  late final String uid;
  threeTypesOfButtons({required this.uid});

  @override
  State<threeTypesOfButtons> createState() => _ThreeTypesOfButtonsState();
}

class _ThreeTypesOfButtonsState extends State<threeTypesOfButtons> {
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

  void updateFollowState(bool following, bool followBack) {
    setState(() {
      isFollowing = following;
      isFollowBack = followBack;
    });
  }

  Future<void> _showDialogBox() async {
    return PanaraConfirmDialog.show(
      context,
      title: 'Log out',
      message: 'Log out mou?',
      confirmButtonText: 'Conlan7firm!',
      onTapConfirm: () async {
        await AuthMethods().logOut();
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const LoginScreen(),
          ),
        );
      },
      cancelButtonText: 'Bukanlah balik!',
      onTapCancel: () {
        Navigator.of(context).pop();
      },
      padding: EdgeInsets.all(10),
      panaraDialogType: PanaraDialogType.warning,
      barrierDismissible: false,
      // Optional: Prevents dialog from closing when tapped outside
      textColor: Colors.amber,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // whatever uid we enter in the parameter is equal to firebase auth current user
        // then we will know this is our account
        firebaseAuth == widget.uid
            ? FollowButton(
                text: 'Log out',
                backgroundColor: mobileBackgroundColor,
                textColor: primaryColor,
                borderColor: Colors.grey,
                function: _showDialogBox,
              )
            : isFollowing
                ? FollowButton(
                    text: 'Following',
                    backgroundColor: Colors.white,
                    textColor: Colors.black,
                    borderColor: Colors.grey,
                    function: () async {
                      showModalBottomSheet(
                        context: context,
                        builder: (BuildContext context) {
                          return modalBottomSheet3(
                            uid: widget.uid,
                            initialFollowingState: isFollowing,
                            initialFollowBackState: isFollowBack,
                            onUpdate: updateFollowState,
                          );
                        },
                      );
                    },
                  )
                : isFollowBack
                    ? FollowButton(
                        text: 'Follow Back',
                        backgroundColor: Colors.blue,
                        textColor: Colors.white,
                        borderColor: Colors.blue,
                        function: () async {
                          await FirestoreMethods().followUser(
                            FirebaseAuth.instance.currentUser!.uid,
                            userData['uid'],
                          );
                          setState(() {
                            isFollowing = true;
                            followers++;
                          });
                        },
                      )
                    : FollowButton(
                        text: 'Follow ',
                        backgroundColor: Colors.blue,
                        textColor: Colors.white,
                        borderColor: Colors.blue,
                        function: () async {
                          await FirestoreMethods().followUser(
                            FirebaseAuth.instance.currentUser!.uid,
                            userData['uid'],
                          );
                          setState(() {
                            isFollowing = true;
                            followers++;
                          });
                        },
                      ),

        // message or share profile button
        firebaseAuth == widget.uid
            ? MessageOrShareProfileButton(
                text: 'Share profile',
                backgroundColor: mobileBackgroundColor,
                textColor: primaryColor,
                borderColor: Colors.grey,
                function: null,
              )
            : MessageOrShareProfileButton(
                text: 'Message',
                backgroundColor: mobileBackgroundColor,
                borderColor: Colors.grey,
                textColor: primaryColor,
                function: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => MessageScreen(),
                    ),
                  );
                },
              ),

        AddPeopleButton(
          backgroundColor: mobileBackgroundColor,
          borderColor: Colors.grey,
          iconColor: Colors.white,
          function: null,
        ),
      ],
    );
  }
}
