import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagramzzz/resources/auth_methods.dart';
import 'package:instagramzzz/resources/firestore_method.dart';
import 'package:instagramzzz/screens/auth_screens/login_screen.dart';
import 'package:instagramzzz/screens/extend_screens/follow_screen.dart';
import 'package:instagramzzz/screens/extend_screens/profile_post_screen.dart';
import 'package:instagramzzz/utils/colors.dart';
import 'package:instagramzzz/utils/utils.dart';
import 'package:instagramzzz/widgets/follow_button.dart';

class ProfileScreen extends StatefulWidget {
  final String uid;
  ProfileScreen({required this.uid});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  var userData = {};
  int postLength = 0;
  int followers = 0;
  int following = 0;
  bool isFollowing = false;
  bool isLoading = false;
  bool isUser = false;

  // since we have three column widgets in the profile screen
  Column buildStatColumn(int num, String label) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          num.toString(),
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        Container(
          margin: EdgeInsets.only(top: 4),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: Colors.grey,
            ),
          ),
        ),
      ],
    );
  }

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

      // get post length
      var postSnap = await FirebaseFirestore.instance
          .collection('posts')
          .where('uid', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .get();

      userData = userSnap.data()!;
      postLength = postSnap.docs.length;
      followers = userSnap.data()!['followers'].length;
      following = userSnap.data()!['following'].length;
      isFollowing = userSnap
          .data()!['followers']
          .contains(FirebaseAuth.instance.currentUser!.uid);

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
            child: CircularProgressIndicator(),
          )
        : Scaffold(
            appBar: AppBar(
              backgroundColor: mobileBackgroundColor,
              title: Text(userData['username'] ?? 'Username not available'),
              // ?? null aware operator
              centerTitle: false,
              actions: [
                IconButton(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (BuildContext context) {
                        return SingleChildScrollView(
                          child: SizedBox(
                            width: double.infinity,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                FirebaseAuth.instance.currentUser!.uid ==
                                        widget.uid
                                    ? GestureDetector(
                                        onTap: () {},
                                        child: Container(
                                          margin: EdgeInsets.all(8),
                                          padding: EdgeInsets.all(15),
                                          child: Row(
                                            children: [
                                              Icon(Icons.settings),
                                              SizedBox(width: 15),
                                              Text('Settings'),
                                            ],
                                          ),
                                        ),
                                      )
                                    : GestureDetector(
                                        onTap: () {},
                                        child: Container(
                                          margin: EdgeInsets.all(8),
                                          padding: EdgeInsets.all(5),
                                          child: Text('Report...'),
                                        ),
                                      ),
                                FirebaseAuth.instance.currentUser!.uid ==
                                        widget.uid
                                    ? GestureDetector(
                                        onTap: () {},
                                        child: Container(
                                          margin: EdgeInsets.all(8),
                                          padding: EdgeInsets.all(15),
                                          child: Row(
                                            children: [
                                              Icon(Icons.social_distance),
                                              SizedBox(width: 15),
                                              Text('Threads'),
                                            ],
                                          ),
                                        ),
                                      )
                                    : GestureDetector(
                                        onTap: () {},
                                        child: Container(
                                          margin: EdgeInsets.all(8),
                                          padding: EdgeInsets.all(5),
                                          child: Text('Block'),
                                        ),
                                      ),
                                FirebaseAuth.instance.currentUser!.uid ==
                                        widget.uid
                                    ? GestureDetector(
                                        onTap: () {},
                                        child: Container(
                                          margin: EdgeInsets.all(8),
                                          padding: EdgeInsets.all(15),
                                          child: Row(
                                            children: [
                                              Icon(Icons.local_activity),
                                              SizedBox(width: 15),
                                              Text('Your activity'),
                                            ],
                                          ),
                                        ),
                                      )
                                    : GestureDetector(
                                        onTap: () {},
                                        child: Container(
                                          margin: EdgeInsets.all(8),
                                          padding: EdgeInsets.all(5),
                                          child: Text('About This Account'),
                                        ),
                                      ),
                                FirebaseAuth.instance.currentUser!.uid ==
                                        widget.uid
                                    ? GestureDetector(
                                        onTap: () {},
                                        child: Container(
                                          margin: EdgeInsets.all(8),
                                          padding: EdgeInsets.all(15),
                                          child: Row(
                                            children: [
                                              Icon(Icons.archive),
                                              SizedBox(width: 15),
                                              Text('Archive'),
                                            ],
                                          ),
                                        ),
                                      )
                                    : GestureDetector(
                                        onTap: () {},
                                        child: Container(
                                          margin: EdgeInsets.all(8),
                                          padding: EdgeInsets.all(5),
                                          child: Text('Restrict'),
                                        ),
                                      ),
                                FirebaseAuth.instance.currentUser!.uid ==
                                        widget.uid
                                    ? GestureDetector(
                                        onTap: () {},
                                        child: Container(
                                          margin: EdgeInsets.all(8),
                                          padding: EdgeInsets.all(15),
                                          child: Row(
                                            children: [
                                              Icon(Icons.qr_code),
                                              SizedBox(width: 15),
                                              Text('QR code'),
                                            ],
                                          ),
                                        ),
                                      )
                                    : Container(),
                                FirebaseAuth.instance.currentUser!.uid ==
                                        widget.uid
                                    ? GestureDetector(
                                        onTap: () {},
                                        child: Container(
                                          margin: EdgeInsets.all(8),
                                          padding: EdgeInsets.all(15),
                                          child: Row(
                                            children: [
                                              Icon(Icons.bookmark),
                                              SizedBox(width: 15),
                                              Text('Saved'),
                                            ],
                                          ),
                                        ),
                                      )
                                    : GestureDetector(
                                        onTap: () {},
                                        child: Container(
                                          margin: EdgeInsets.all(8),
                                          padding: EdgeInsets.all(5),
                                          child: Text('Restrict'),
                                        ),
                                      ),
                                FirebaseAuth.instance.currentUser!.uid ==
                                        widget.uid
                                    ? GestureDetector(
                                        onTap: () {},
                                        child: Container(
                                          margin: EdgeInsets.all(8),
                                          padding: EdgeInsets.all(15),
                                          child: Row(
                                            children: [
                                              Icon(Icons.people),
                                              SizedBox(width: 15),
                                              Text('Supervision'),
                                            ],
                                          ),
                                        ),
                                      )
                                    : GestureDetector(
                                        onTap: () {},
                                        child: Container(
                                          margin: EdgeInsets.all(8),
                                          padding: EdgeInsets.all(5),
                                          child: Text('Restrict'),
                                        ),
                                      ),
                                FirebaseAuth.instance.currentUser!.uid ==
                                        widget.uid
                                    ? GestureDetector(
                                        onTap: () {},
                                        child: Container(
                                          margin: EdgeInsets.all(8),
                                          padding: EdgeInsets.all(15),
                                          child: Row(
                                            children: [
                                              Icon(Icons.credit_card),
                                              SizedBox(width: 15),
                                              Text('Orders and payments'),
                                            ],
                                          ),
                                        ),
                                      )
                                    : GestureDetector(
                                        onTap: () {},
                                        child: Container(
                                          margin: EdgeInsets.all(8),
                                          padding: EdgeInsets.all(5),
                                          child: Text('See shared activity'),
                                        ),
                                      ),
                                FirebaseAuth.instance.currentUser!.uid ==
                                        widget.uid
                                    ? GestureDetector(
                                        onTap: () {},
                                        child: Container(
                                          margin: EdgeInsets.all(8),
                                          padding: EdgeInsets.all(15),
                                          child: Row(
                                            children: [
                                              Icon(Icons.verified),
                                              SizedBox(width: 15),
                                              Text('Meta verified'),
                                            ],
                                          ),
                                        ),
                                      )
                                    : GestureDetector(
                                        onTap: () {},
                                        child: Container(
                                          margin: EdgeInsets.all(8),
                                          padding: EdgeInsets.all(5),
                                          child: Text('Hide your story'),
                                        ),
                                      ),
                                FirebaseAuth.instance.currentUser!.uid ==
                                        widget.uid
                                    ? GestureDetector(
                                        onTap: () {},
                                        child: Container(
                                          margin: EdgeInsets.all(8),
                                          padding: EdgeInsets.all(15),
                                          child: Row(
                                            children: [
                                              Icon(Icons.closed_caption),
                                              SizedBox(width: 15),
                                              Text('Closed friends'),
                                            ],
                                          ),
                                        ),
                                      )
                                    : GestureDetector(
                                        onTap: () {},
                                        child: Container(
                                          margin: EdgeInsets.all(8),
                                          padding: EdgeInsets.all(5),
                                          child: Text('Remove follower'),
                                        ),
                                      ),
                                FirebaseAuth.instance.currentUser!.uid ==
                                        widget.uid
                                    ? GestureDetector(
                                        onTap: () {},
                                        child: Container(
                                          margin: EdgeInsets.all(8),
                                          padding: EdgeInsets.all(15),
                                          child: Row(
                                            children: [
                                              Icon(Icons.star_outline),
                                              SizedBox(width: 15),
                                              Text('Favourites'),
                                            ],
                                          ),
                                        ),
                                      )
                                    : GestureDetector(
                                        onTap: () {},
                                        child: Container(
                                          margin: EdgeInsets.all(8),
                                          padding: EdgeInsets.all(5),
                                          child: Text('Copy Profile URL'),
                                        ),
                                      ),
                                FirebaseAuth.instance.currentUser!.uid ==
                                        widget.uid
                                    ? Container()
                                    : GestureDetector(
                                        onTap: () {},
                                        child: Container(
                                          margin: EdgeInsets.all(8),
                                          padding: EdgeInsets.all(5),
                                          child: Text('Show QR code'),
                                        ),
                                      ),
                                FirebaseAuth.instance.currentUser!.uid ==
                                        widget.uid
                                    ? Container()
                                    : GestureDetector(
                                        onTap: () {},
                                        child: Container(
                                          margin: EdgeInsets.all(8),
                                          padding: EdgeInsets.all(5),
                                          child: Text('Share this profile'),
                                        ),
                                      ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                  icon: FirebaseAuth.instance.currentUser!.uid == widget.uid
                      ? Icon(Icons.more_horiz_outlined)
                      : Icon(Icons.more_vert),
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
                                    buildStatColumn(postLength, 'posts'),
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                FollowScreen(),
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
                                                FollowScreen(),
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
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    // whatever uid we enter in the parameter is equal to firebase auth current user
                                    // then we will know this is our account
                                    FirebaseAuth.instance.currentUser!.uid ==
                                            widget.uid
                                        ? FollowButton(
                                            text: 'Log out',
                                            backgroundColor:
                                                mobileBackgroundColor,
                                            textColor: primaryColor,
                                            borderColor: Colors.grey,
                                            function: () async {
                                              await AuthMethods().logOut();
                                              Navigator.of(context)
                                                  .pushReplacement(
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      LoginScreen(),
                                                ),
                                              );
                                            },
                                          )
                                        : isFollowing
                                            ? FollowButton(
                                                text: 'Unfollow',
                                                backgroundColor: Colors.white,
                                                textColor: Colors.black,
                                                borderColor: Colors.grey,
                                                function: () async {
                                                  await FirestoreMethods()
                                                      .followUser(
                                                    FirebaseAuth.instance
                                                        .currentUser!.uid,
                                                    userData['uid'],
                                                  );
                                                  setState(() {
                                                    isFollowing = false;
                                                    followers--;
                                                  });
                                                },
                                              )
                                            : FollowButton(
                                                text: 'Follow',
                                                backgroundColor: Colors.blue,
                                                textColor: Colors.white,
                                                borderColor: Colors.blue,
                                                function: () async {
                                                  await FirestoreMethods()
                                                      .followUser(
                                                    FirebaseAuth.instance
                                                        .currentUser!.uid,
                                                    userData['uid'],
                                                  );
                                                  setState(() {
                                                    isFollowing = true;
                                                    followers++;
                                                  });
                                                },
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
                        padding: EdgeInsets.only(top: 15),
                        child: Text(
                          userData['username'] ?? 'Username not available',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        alignment: Alignment.centerLeft,
                        padding: EdgeInsets.only(top: 15),
                        child: Text(
                          userData['bio'] ?? 'Bio not available',
                        ),
                      ),

                      Divider(),

                      // show the post in profile screen
                      FutureBuilder(
                        future: FirebaseFirestore.instance
                            .collection('posts')
                            .where('uid', isEqualTo: widget.uid)
                            .get(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(
                              child: CircularProgressIndicator(),
                            );
                          } else {
                            return GridView.builder(
                              shrinkWrap: true,
                              itemCount:
                                  (snapshot.data as dynamic)?.docs?.length ?? 0,
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                crossAxisSpacing: 5,
                                mainAxisSpacing: 1.5,
                                childAspectRatio: 1,
                              ),
                              itemBuilder: (context, index) {
                                DocumentSnapshot snap =
                                    (snapshot.data! as dynamic).docs[index];

                                // Check if the 'posturl' field is not null before creating NetworkImage
                                if ((snap.data()! as dynamic)['postUrl'] !=
                                    null) {
                                  return Container(
                                    child: GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                ProfilePostScreen(
                                              userUid: widget.uid,
                                            ),
                                          ),
                                        );
                                      },
                                      child: Image(
                                        image: NetworkImage(
                                          (snap.data()! as dynamic)['postUrl']
                                              .toString(),
                                        ),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  );
                                } else {
                                  // Handle the case where 'posturl' is null (you can show a placeholder)
                                  return Container(
                                    // Your placeholder widget or text here
                                    child: Text('No image available'),
                                  );
                                }
                              },
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
  }
}
