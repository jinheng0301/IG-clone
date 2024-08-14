import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagramzzz/resources/firestore_method.dart';
import 'package:instagramzzz/screens/extend_screens/message_screen.dart';
import 'package:instagramzzz/screens/navigator%20bar%20main%20screens/profile_screen.dart';
import 'package:instagramzzz/utils/colors.dart';
import 'package:instagramzzz/utils/utils.dart';
import 'package:instagramzzz/widgets/follow_button2.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class FollowingScreen extends StatefulWidget {
  final String uid;

  FollowingScreen({required this.uid});

  @override
  State<FollowingScreen> createState() => _FollowingScreenState();
}

class _FollowingScreenState extends State<FollowingScreen> {
  TextEditingController searchController = TextEditingController();
  var userData = {};
  List<Map<String, dynamic>> followingList = [];
  List<Map<String, dynamic>> filteredFollowingList = [];
  String currentUserId = FirebaseAuth.instance.currentUser!.uid;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    getData();
    searchController.addListener(() {
      filterFollowingList(searchController.text);
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
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

      if (userSnap.exists) {
        userData = userSnap.data()!;

        // Get the following list
        List<dynamic> following = userSnap.data()!['following'];
        List<Map<String, dynamic>> tempFollowingList = [];

        for (String uid in following) {
          DocumentSnapshot userSnap = await FirebaseFirestore.instance
              .collection('users')
              .doc(uid)
              .get();

          if (userSnap.exists) {
            Map<String, dynamic> userData =
                userSnap.data() as Map<String, dynamic>;
            userData['isFollowing'] = await checkIfFollowing(uid);
            tempFollowingList.add(userData);
          }
        }

        setState(() {
          followingList = tempFollowingList;
          filteredFollowingList = followingList;
        });
      } else {
        showSnackBar('User not found', context);
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

  void filterFollowingList(String query) {
    List<Map<String, dynamic>> filteredList = followingList.where((user) {
      return user['username'].toLowerCase().contains(query.toLowerCase());
    }).toList();

    setState(() {
      filteredFollowingList = filteredList;
    });
  }

  void toggleFollow(String userId, bool isFollowing) async {
    setState(() {
      for (var user in followingList) {
        if (user['uid'] == userId) {
          user['isFollowing'] = !isFollowing;
          break;
        }
      }
      filteredFollowingList = followingList.where((user) {
        return user['username']
            .toLowerCase()
            .contains(searchController.text.toLowerCase());
      }).toList();
    });

    if (isFollowing) {
      await FirestoreMethods().followUser(currentUserId, userId);
    } else {
      await FirestoreMethods().followUser(currentUserId, userId);
    }
  }

  Future<void> _showFollowOptions(
      String photoUrl, String username, String uid, bool isFollowing) async {
    return await showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.all(20),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: NetworkImage(photoUrl),
                  ),
                  SizedBox(width: 10),
                  Text(
                    username,
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Divider(),
            ListTile(
              title: Text('Manage notification'),
            ),
            ListTile(
              title: Text('See shared activity'),
            ),
            ListTile(
              title: Text('Mute'),
            ),
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
                toggleFollow(uid, isFollowing);
              },
              child: ListTile(
                title: Text(
                  isFollowing ? 'Unfollow' : 'Follow',
                  style: TextStyle(
                    color: Colors.red,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(userData['username'] ?? 'Username not available'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: TextField(
              controller: searchController,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search',
                enabledBorder: UnderlineInputBorder(),
              ),
              onChanged: (value) => filterFollowingList(value),
            ),
          ),
          const Divider(),
          Expanded(
            child: isLoading
                ? Center(
                    child: LoadingAnimationWidget.inkDrop(
                      color: Colors.red,
                      size: 40,
                    ),
                  )
                : filteredFollowingList.isEmpty
                    ? const Center(
                        child: Text('No followed account shown.'),
                      )
                    : ListView.builder(
                        itemCount: filteredFollowingList.length,
                        itemBuilder: (context, index) {
                          var user = filteredFollowingList[index];

                          return GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ProfileScreen(uid: user['uid']),
                                ),
                              );
                            },
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundImage: NetworkImage(user['photoUrl']),
                              ),
                              title: Text(user['username']),
                              trailing: user['uid'] != currentUserId
                                  ? Wrap(
                                      children: [
                                        FollowButton2(
                                          text: 'Message',
                                          backgroundColor:
                                              mobileBackgroundColor,
                                          borderColor: secondaryColor,
                                          textColor: primaryColor,
                                          function: () {
                                            Navigator.of(context).push(
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    MessageScreen(),
                                              ),
                                            );
                                          },
                                        ),
                                        IconButton(
                                          onPressed: () {
                                            _showFollowOptions(
                                              user['photoUrl'],
                                              user['username'],
                                              user['uid'],
                                              user['isFollowing'],
                                            );
                                          },
                                          icon: Icon(Icons.more_vert),
                                        ),
                                      ],
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
