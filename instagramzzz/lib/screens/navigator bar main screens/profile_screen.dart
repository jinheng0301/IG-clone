import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instagramzzz/resources/auth_methods.dart';
import 'package:instagramzzz/resources/firestore_method.dart';
import 'package:instagramzzz/screens/auth_screens/login_screen.dart';
import 'package:instagramzzz/screens/extend_screens/follower_screen.dart';
import 'package:instagramzzz/screens/extend_screens/following_screen.dart';
import 'package:instagramzzz/screens/extend_screens/message_screen.dart';
import 'package:instagramzzz/screens/extend_screens/profile_post_screen.dart';
import 'package:instagramzzz/screens/navigator%20bar%20main%20screens/add_post_screen.dart';
import 'package:instagramzzz/utils/colors.dart';
import 'package:instagramzzz/utils/utils.dart';
import 'package:instagramzzz/widgets/add_people_button.dart';
import 'package:instagramzzz/widgets/follow_button.dart';
import 'package:instagramzzz/widgets/message_or_share_profile_button.dart';
import 'package:instagramzzz/widgets/modal%20bottom%20sheet/modal_bottom_sheet1.dart';
import 'package:instagramzzz/widgets/modal%20bottom%20sheet/modal_bottom_sheet2.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:panara_dialogs/panara_dialogs.dart';

class ProfileScreen extends StatefulWidget {
  final String uid;

  ProfileScreen({required this.uid});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  var firebaseAuth = FirebaseAuth.instance.currentUser!.uid; // current user ID
  var userData = {};
  int postLength = 0;
  int followers = 0;
  int following = 0;
  bool isFollowing = false;
  bool isFollowBack = false;
  bool isLoading = false;
  bool isUser = false;
  bool showPost1 = false;
  bool showPost2 = false;
  bool showPost3 = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getData();
    showProfilePost();
  }

  // since we have three column widgets in the profile screen
  Column buildStatColumn(String userName, int num, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          userName,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 17,
          ),
        ),
        const SizedBox(height: 6),
        Padding(
          padding: const EdgeInsets.only(left: 6),
          child: Text(
            num.toString(),
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 2),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.normal,
              color: Colors.grey,
            ),
          ),
        ),
      ],
    );
  }

  FutureBuilder<QuerySnapshot<Map<String, dynamic>>> showProfilePost() {
    print("showProfilePost is called");
    return FutureBuilder(
      future: FirebaseFirestore.instance
          .collection('posts')
          .where('uid', isEqualTo: widget.uid)
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.none) {
          return const Center(
            child: Text('No images to show.'),
          );
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: LoadingAnimationWidget.hexagonDots(
              color: Colors.yellow,
              size: 40,
            ),
          );
        } else {
          return GridView.builder(
            shrinkWrap: true,
            itemCount: (snapshot.data as dynamic)?.docs?.length ?? 0,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 5,
              mainAxisSpacing: 1.5,
              childAspectRatio: 1,
            ),
            itemBuilder: (context, index) {
              DocumentSnapshot snap = (snapshot.data! as dynamic).docs[index];

              // Check if the 'posturl' field is not null before creating NetworkImage
              if ((snap.data()! as dynamic)['postUrl'] != null) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProfilePostScreen(
                          uid: widget.uid,
                          postId: snap.id,
                          initialIndex: index,
                        ),
                      ),
                    );
                  },
                  child: Image(
                    image: NetworkImage(
                      (snap.data()! as dynamic)['postUrl'].toString(),
                    ),
                    fit: BoxFit.cover,
                  ),
                );
              } else {
                // Handle the case where 'posturl' is null (you can show a placeholder)
                return const Text('No image available');
              }
            },
          );
        }
      },
    );
  }

  Container reelsSaved() {
    print('reelsSaved function is called.');
    return Container(
      child: const Text('reels by owner'),
    );
  }

  Container photoTagged() {
    print('photoTagged function is called.');
    return Container(
      child: const Text('photo tagged area'),
    );
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
      padding: const EdgeInsets.all(10),
      panaraDialogType: PanaraDialogType.warning,
      barrierDismissible: false,
      // Optional: Prevents dialog from closing when tapped outside
      textColor: Colors.amber,
    );
  }

  Future<void> _refreshProfileScreen() async {
    try {
      // Refresh logic here, e.g., re-fetch data from Firestore
      // In this example, we are just delaying for 2 seconds
      await Future.delayed(const Duration(seconds: 2));
    } catch (e) {
      print('Error refereshing new profile screen: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Center(
            child: LoadingAnimationWidget.hexagonDots(
              color: Colors.yellow,
              size: 40,
            ),
          )
        : Scaffold(
            appBar: AppBar(
              backgroundColor: mobileBackgroundColor,
              title: Text(
                userData['username'] ?? 'Username not available',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              // ?? null aware operator
              centerTitle: false,
              actions: [
                IconButton(
                  onPressed: () {},
                  icon: firebaseAuth == widget.uid
                      ? GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const AddPostScreen(),
                              ),
                            );
                          },
                          child: const Icon(Icons.add_circle_outline_outlined),
                        )
                      : GestureDetector(
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              builder: (BuildContext context) {
                                return modalBottomSheet2(uid: widget.uid);
                              },
                            );
                          },
                          child: const Icon(Icons.notification_add),
                        ),
                ),
                IconButton(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (BuildContext context) {
                        return modalBottomSheet1(uid: widget.uid);
                      },
                    );
                  },
                  icon: firebaseAuth == widget.uid
                      ? const Icon(Icons.more_horiz_outlined)
                      : const Icon(Icons.more_vert),
                ),
              ],
            ),
            body: RefreshIndicator(
              onRefresh: _refreshProfileScreen,
              child: ListView(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              Stack(
                                children: [
                                  CircleAvatar(
                                    radius: 40,
                                    backgroundColor: Colors.grey,
                                    backgroundImage: NetworkImage(
                                      userData['photoUrl'],
                                    ),
                                  ),
                                  if (firebaseAuth == widget.uid) ...[
                                    Positioned(
                                      bottom: -18,
                                      left: 40,
                                      child: IconButton(
                                        color: Colors.white,
                                        onPressed: () async {
                                          print('icon button pressed');
                                          await pickImage(ImageSource.camera);
                                          Navigator.of(context).pop();
                                        },
                                        icon: const Icon(Icons.add),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        buildStatColumn(
                                          userData['username'],
                                          postLength,
                                          'posts',
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    FollowerScreen(
                                                  uid: firebaseAuth,
                                                ),
                                              ),
                                            );
                                          },
                                          child: buildStatColumn(
                                            '',
                                            followers,
                                            'followers',
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    FollowingScreen(
                                                  uid: firebaseAuth,
                                                ),
                                              ),
                                            );
                                          },
                                          child: buildStatColumn(
                                            '',
                                            following,
                                            'following',
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(bottom: 6),
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            userData['bio'] ?? 'Bio not available',
                          ),
                        ),

                        Row(
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
                                              return SizedBox(
                                                width: double.infinity,
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Container(
                                                      margin:
                                                          const EdgeInsets.all(
                                                              8),
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Text(
                                                            userData[
                                                                'username'],
                                                            style:
                                                                const TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
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
                                                        margin: const EdgeInsets
                                                            .all(8),
                                                        padding:
                                                            const EdgeInsets
                                                                .all(15),
                                                        child: const Text(
                                                          'Add to close friend list',
                                                          style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    GestureDetector(
                                                      onTap: () {},
                                                      child: Container(
                                                        margin: const EdgeInsets
                                                            .all(8),
                                                        padding:
                                                            const EdgeInsets
                                                                .all(15),
                                                        child: const Text(
                                                          'Mute',
                                                          style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    GestureDetector(
                                                      onTap: () {},
                                                      child: Container(
                                                        margin: const EdgeInsets
                                                            .all(8),
                                                        padding:
                                                            const EdgeInsets
                                                                .all(15),
                                                        child: const Text(
                                                          'Restrict',
                                                          style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    GestureDetector(
                                                      onTap: () async {
                                                        await FirestoreMethods()
                                                            .followUser(
                                                          firebaseAuth,
                                                          userData['uid'],
                                                        );
                                                        setState(() {
                                                          isFollowing = false;
                                                          followers--;
                                                        });
                                                        Navigator.of(context)
                                                            .pop();
                                                        // dismiss the modal bottom sheet after unfollow button is tapped
                                                      },
                                                      child: Container(
                                                        margin: const EdgeInsets
                                                            .all(8),
                                                        padding:
                                                            const EdgeInsets
                                                                .all(15),
                                                        child: const Text(
                                                          'Unfollow',
                                                          style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
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
                                              await FirestoreMethods()
                                                  .followUser(
                                                firebaseAuth,
                                                widget.uid,
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
                                              await FirestoreMethods()
                                                  .followUser(
                                                firebaseAuth,
                                                widget.uid,
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
                        ),

                        const Divider(),

                        // show the post in profile screen
                        Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  child: IconButton(
                                    icon: const Icon(Icons.grid_on),
                                    onPressed: () {
                                      setState(() {
                                        print('first button pressed');
                                        showPost1 = true;
                                      });
                                    },
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  child: IconButton(
                                    icon: const Icon(Icons.tiktok),
                                    onPressed: () {
                                      setState(() {
                                        print("second button pressed");
                                        showPost2 = true;
                                      });
                                    },
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  child: IconButton(
                                    icon: const Icon(Icons.tag_faces_rounded),
                                    onPressed: () {
                                      setState(() {
                                        print("third button pressed");
                                        showPost3 = true;
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),

                            const Divider(),

                            // to test the show profile post function
                            showPost1
                                ? showProfilePost()
                                : showPost2
                                    ? reelsSaved()
                                    : showPost3
                                        ? photoTagged()
                                        : Container(),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
  }
}
