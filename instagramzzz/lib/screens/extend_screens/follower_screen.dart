import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagramzzz/resources/firestore_method.dart';
import 'package:instagramzzz/screens/extend_screens/message_screen.dart';
import 'package:instagramzzz/utils/colors.dart';
import 'package:instagramzzz/utils/utils.dart';
import 'package:instagramzzz/widgets/follow_button2.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../navigator bar main screens/profile_screen.dart';

class FollowerScreen extends StatefulWidget {
  final String uid;
  FollowerScreen({required this.uid});

  @override
  State<FollowerScreen> createState() => _FollowerScreenState();
}

class _FollowerScreenState extends State<FollowerScreen> {
  TextEditingController searchController = TextEditingController();
  List<Map<String, dynamic>> followerList = [];
  List<Map<String, dynamic>> filteredFollowerList = [];
  var userData = {};
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    getData();
    searchController.addListener(() {
      filterFollowerList(searchController.text);
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
        List<dynamic> followers = userSnap.data()!['followers'];
        List<Map<String, dynamic>> tempFollowerList = [];

        for (String uid in followers) {
          DocumentSnapshot userSnap = await FirebaseFirestore.instance
              .collection('users')
              .doc(uid)
              .get();
          if (userSnap.exists) {
            Map<String, dynamic> userData =
                userSnap.data() as Map<String, dynamic>;
            tempFollowerList.add(userData);
          }
        }

        setState(() {
          followerList = tempFollowerList;
          filteredFollowerList = followerList;
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

  void filterFollowerList(String query) {
    List<Map<String, dynamic>> filteredList = followerList.where((user) {
      return user['username'].toLowerCase().contains(query.toLowerCase());
    }).toList();

    setState(() {
      filteredFollowerList = filteredList;
    });
  }

  void removeFollower(String uid) async {
    setState(() {
      followerList.removeWhere((user) => user['uid'] == uid);
      filteredFollowerList = List.from(followerList);
    });

    await FirestoreMethods().removeUser(
      FirebaseAuth.instance.currentUser!.uid,
      uid,
    );
  }

  Future<void> _showRemoveFollowerDialog(
    String uid,
    String username,
    String photoUrl,
  ) {
    return showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          margin: EdgeInsets.all(10),
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: NetworkImage(photoUrl),
                      radius: 30,
                    ),
                    SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Remove follower?',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'We won\'t tell $username that they were removed from your followers.',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Divider(),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    removeFollower(uid);
                  },
                  child: ListTile(
                    title: Text(
                      'Remove',
                      style: TextStyle(
                        color: Colors.red,
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        );
      },
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
            ),
          ),

          const Divider(),

          // Show all follower accounts
          Expanded(
            child: isLoading
                ? Center(
                    child: LoadingAnimationWidget.inkDrop(
                      color: Colors.red,
                      size: 40,
                    ),
                  )
                : filteredFollowerList.isEmpty
                    ? const Center(
                        child: Text('No follower account shown.'),
                      )
                    : ListView.builder(
                        itemCount: filteredFollowerList.length,
                        itemBuilder: (context, index) {
                          var user = filteredFollowerList[index];
                          var uid = user['uid'];
                          var photoUrl = user['photoUrl'];
                          var username = user['username'];

                          return GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => ProfileScreen(uid: uid),
                                ),
                              );
                            },
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundImage: NetworkImage(photoUrl),
                              ),
                              title: Text(username),
                              trailing: Wrap(
                                children: [
                                  FollowButton2(
                                    text: 'Message',
                                    backgroundColor: mobileBackgroundColor,
                                    borderColor: secondaryColor,
                                    textColor: primaryColor,
                                    function: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) => MessageScreen(),
                                        ),
                                      );
                                    },
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      _showRemoveFollowerDialog(
                                        user['uid'],
                                        user['username'],
                                        user['photoUrl'],
                                      );
                                    },
                                    icon: Icon(Icons.more_vert),
                                  ),
                                ],
                              ),
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
