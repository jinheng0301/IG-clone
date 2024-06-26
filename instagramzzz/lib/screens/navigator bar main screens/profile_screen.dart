import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagramzzz/screens/extend_screens/follower_screen.dart';
import 'package:instagramzzz/screens/extend_screens/following_screen.dart';
import 'package:instagramzzz/screens/extend_screens/profile_post_screen.dart';
import 'package:instagramzzz/screens/navigator%20bar%20main%20screens/add_post_screen.dart';
import 'package:instagramzzz/utils/colors.dart';
import 'package:instagramzzz/utils/utils.dart';
import 'package:instagramzzz/widgets/modal%20bottom%20sheet/modal_bottom_sheet1.dart';
import 'package:instagramzzz/widgets/modal%20bottom%20sheet/modal_bottom_sheet2.dart';
import 'package:instagramzzz/widgets/three_types_of_buttons.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

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
  Column buildStatColumn(int num, String label) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          num.toString(),
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 4),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w400,
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
            body: ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundColor: Colors.grey,
                            backgroundImage: NetworkImage(
                              userData['photoUrl'] ?? 'Photo not available',
                            ),
                          ),
                          Expanded(
                            child: Column(
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    buildStatColumn(
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
                      Container(
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.only(top: 10),
                        child: Text(
                          userData['username'] ?? 'Username not available',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          userData['bio'] ?? 'Bio not available',
                        ),
                      ),

                      threeTypesOfButtons(uid: widget.uid),

                      const Divider(),

                      // show the post in profile screen
                      Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Container(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
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
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
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
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
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
          );
  }
}
