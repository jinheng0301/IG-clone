import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagramzzz/resources/firestore_method.dart';
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
      userData = userSnap.data()!;

      // Get the following List
      List<dynamic> following = userSnap.data()!['following'];
      List<Map<String, dynamic>> tempFollowingList = [];

      for (String uid in following) {
        DocumentSnapshot userSnap =
            await FirebaseFirestore.instance.collection('users').doc(uid).get();
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
        .doc(FirebaseAuth.instance.currentUser!.uid)
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

          // Show all following account
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
