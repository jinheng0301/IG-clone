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
  var userData = {};
  int follower = 0;
  List<String> followerList = [];
  List<String> filteredFollowerList = [];
  bool isLoading = false;
  bool isFollowed = false;

  @override
  void initState() {
    super.initState();
    getData();
    searchController.addListener(() {
      filterFollowerList(searchController.text);
    });
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

        // Get the follower list
        followerList = List<String>.from(userSnap.data()!['followers']);
        filteredFollowerList = followerList;
      } else {
        // Handle the case when the document does not exist
        showSnackBar('User not found', context);
      }
    } catch (e) {
      showSnackBar(e.toString(), context);
    }

    setState(() {
      isLoading = false;
    });
  }

  void filterFollowerList(String query){
    List<String> filteredList = followerList.where((uid) {
      return uid.toLowerCase().contains(query.toLowerCase());
    }).toList();

    setState(() {
      filteredFollowerList = filteredList;
    });
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
          Text(
            'All followers',
            style: TextStyle(fontSize: 20),
          ),
          SizedBox(height: 10),
          Expanded(
            child: isLoading
                ? Center(
                    child: LoadingAnimationWidget.hexagonDots(
                      color: Colors.yellow,
                      size: 40,
                    ),
                  )
                : ListView.builder(
                    itemCount: filteredFollowerList.length,
                    itemBuilder: ((context, index) {
                      return FutureBuilder(
                        future: FirebaseFirestore.instance
                            .collection('users')
                            .doc(filteredFollowerList[index])
                            .get(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData || !snapshot.data!.exists) {
                            return Center(
                              child: LoadingAnimationWidget.bouncingBall(
                                color: Colors.yellow,
                                size: 40,
                              ),
                            );
                          }

                          var userData = snapshot.data!.data()!;
                          var uid = userData['uid'];
                          var photoUrl = userData['photoUrl'];
                          var username = userData['username'];
                          bool isFollowed = followerList.contains(uid);

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
                                text: isFollowed ? 'Remove' : '',
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
                                          'We won`t tell ${userData['username']} that they were removed from your followers.',
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () async {
                                              await FirestoreMethods()
                                                  .isFollowedByOtherUser(
                                                FirebaseAuth
                                                    .instance.currentUser!.uid,
                                                uid,
                                              );
                                              setState(() {
                                                followerList.remove(uid);
                                                filteredFollowerList =
                                                    List.from(followerList);
                                                follower--;
                                              });
                                              Navigator.of(context).pop();
                                            },
                                            child: Text(
                                              'Remove',
                                              style: TextStyle(
                                                color: Colors.red,
                                              ),
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
                      );
                    }),
                  ),
          ),
        ],
      ),
    );
  }
}
