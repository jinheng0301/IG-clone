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
  int following = 0;
  List<String> followingList = [];
  List<String> filteredFollowingList = [];
  bool isLoading = false;
  bool isFollowing = false;

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
    // TODO: implement dispose
    super.dispose();
    searchController.dispose();
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

      // Get the following List
      followingList = List<String>.from(userSnap.data()!['following']);
      filteredFollowingList = followingList;

      userData = userSnap.data()!;

      setState(() {});
    } catch (e) {
      showSnackBar(e.toString(), context);
    }

    setState(() {
      isLoading = false;
    });
  }

  void filterFollowingList(String query) {
    List<String> filteredList = followingList.where((uid) {
      return uid.toLowerCase().contains(query.toLowerCase());
    }).toList();

    setState(() {
      filteredFollowingList = filteredList;
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
              onChanged: (value) => filterFollowingList(value),
            ),
          ),

          Divider(),

          // Show all the following accounts
          Text(
            'All following',
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
                    itemCount: filteredFollowingList.length,
                    itemBuilder: (context, index) {
                      return FutureBuilder(
                        future: FirebaseFirestore.instance
                            .collection('users')
                            .doc(filteredFollowingList[index])
                            .get(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return LoadingAnimationWidget.hexagonDots(
                              color: Colors.yellow,
                              size: 40,
                            );
                          }

                          var userData = snapshot.data!.data()!;
                          var uid = userData['uid'];
                          var photoUrl = userData['photoUrl'];
                          var username = userData['username'];
                          bool isFollowing = followingList.contains(uid);

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
                                  text: isFollowing ? 'Following' : 'Follow',
                                  backgroundColor: isFollowing
                                      ? mobileSearchColor
                                      : Colors.blue,
                                  borderColor: secondaryColor,
                                  textColor: primaryColor,
                                  function: () async {
                                    if (isFollowing) {
                                      await FirestoreMethods().followUser(
                                        FirebaseAuth.instance.currentUser!.uid,
                                        uid,
                                      );
                                      setState(() {
                                        followingList.remove(uid);
                                        filteredFollowingList =
                                            List.from(followingList);
                                        following--;
                                      });
                                    } else {
                                      await FirestoreMethods().followUser(
                                        FirebaseAuth.instance.currentUser!.uid,
                                        uid,
                                      );
                                      setState(() {
                                        followingList.add(uid);
                                        filteredFollowingList =
                                            List.from(followingList);
                                        following++;
                                      });
                                    }
                                  }),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
