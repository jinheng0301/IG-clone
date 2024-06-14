import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:instagramzzz/resources/firestore_method.dart';
import 'package:instagramzzz/utils/colors.dart';
import 'package:instagramzzz/utils/utils.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:instagramzzz/widgets/follow_button2.dart';

import '../navigator bar main screens/profile_screen.dart';

class UserLikedScreen extends StatefulWidget {
  final String postId;
  final String uid;
  UserLikedScreen({required this.postId, required this.uid});

  @override
  _UserLikedScreenState createState() => _UserLikedScreenState();
}

class _UserLikedScreenState extends State<UserLikedScreen> {
  TextEditingController searchController = TextEditingController();
  String currentUserId = FirebaseAuth.instance.currentUser!.uid;
  List<Map<String, dynamic>> userLikeList = [];
  List<Map<String, dynamic>> filteredUserLikeList = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    getLikeData();
    searchController.addListener(() {
      filterUserLikeList(searchController.text);
    });
  }

  void getLikeData() async {
    setState(() {
      isLoading = true;
    });

    try {
      DocumentSnapshot postSnap = await FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.postId)
          .get();

      if (postSnap.exists) {
        List<dynamic> likes = postSnap['likes'];
        List<Map<String, dynamic>> tempUserLikeList = [];

        for (String uid in likes) {
          DocumentSnapshot userSnap = await FirebaseFirestore.instance
              .collection('users')
              .doc(uid)
              .get();
          if (userSnap.exists) {
            Map<String, dynamic> userData =
                userSnap.data() as Map<String, dynamic>;
            userData['isFollowing'] = await checkIfFollowing(uid);
            tempUserLikeList.add(userData);
          }
        }

        setState(() {
          userLikeList = tempUserLikeList;
          filteredUserLikeList = userLikeList;
        });
      } else {
        showSnackBar('Post not found', context);
      }
    } catch (e) {
      showSnackBar(e.toString(), context);
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<bool> checkIfFollowing(String uid) async {
    var following = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserId)
        .get();
    List<dynamic> followingList = following['following'];
    return followingList.contains(uid);
  }

  void filterUserLikeList(String query) {
    List<Map<String, dynamic>> filteredList = userLikeList.where((user) {
      return user['username'].toLowerCase().contains(query.toLowerCase());
    }).toList();

    setState(() {
      filteredUserLikeList = filteredList;
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void toggleFollow(String userId, bool isFollowing) async {
    if (isFollowing) {
      await FirestoreMethods().followUser(currentUserId, userId);
    } else {
      await FirestoreMethods().followUser(currentUserId, userId);
    }

    setState(() {
      userLikeList = userLikeList.map((user) {
        if (user['uid'] == userId) {
          user['isFollowing'] = !isFollowing;
        }
        return user;
      }).toList();
      filteredUserLikeList = userLikeList.where((user) {
        return user['username'].toLowerCase().contains(
              searchController.text.toLowerCase(),
            );
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Likes'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search',
                enabledBorder: UnderlineInputBorder(),
              ),
            ),
          ),

          Divider(),

          // Show all the liked accounts
          Expanded(
            child: isLoading
                ? Center(
                    child: LoadingAnimationWidget.hexagonDots(
                      color: Colors.yellow,
                      size: 40,
                    ),
                  )
                : ListView.builder(
                    itemCount: filteredUserLikeList.length,
                    itemBuilder: (context, index) {
                      var user = filteredUserLikeList[index];

                      return GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => ProfileScreen(
                                uid: user['uid'],
                              ),
                            ),
                          );
                        },
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundImage: NetworkImage(user['photoUrl']),
                          ),
                          title: Text(user['username']),
                          trailing: user['uid'] != currentUserId
                              ? FollowButton2(
                                  text: user['isFollowing']
                                      ? 'Following'
                                      : 'Follow',
                                  backgroundColor: user['isFollowing']
                                      ? mobileBackgroundColor
                                      : Colors.blue,
                                  borderColor: user['isFollowing']
                                      ? secondaryColor
                                      : Colors.blue,
                                  textColor: user['isFollowing']
                                      ? primaryColor
                                      : Colors.white,
                                  function: () {
                                    toggleFollow(
                                      user['uid'],
                                      user['isFollowing'],
                                    );
                                  },
                                )
                              : Container(),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
