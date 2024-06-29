import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagramzzz/resources/firestore_method.dart';
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
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search',
                enabledBorder: UnderlineInputBorder(),
              ),
            ),
          ),

          Divider(),

          // Show all follower accounts
          Expanded(
            child: isLoading
                ? Center(
                    child: LoadingAnimationWidget.inkDrop(
                      color: Colors.red,
                      size: 40,
                    ),
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
                          trailing: FollowButton2(
                            text: 'Remove',
                            backgroundColor: mobileBackgroundColor,
                            borderColor: secondaryColor,
                            textColor: primaryColor,
                            function: () {
                              return showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text('Remove follower?'),
                                    content: Text(
                                      'We won\'t tell $username that they were removed from your followers.',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          removeFollower(uid);
                                          Navigator.of(context).pop();
                                        },
                                        child: Text(
                                          'Remove',
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
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
