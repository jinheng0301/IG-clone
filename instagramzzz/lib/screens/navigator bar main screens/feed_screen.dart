import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:instagramzzz/models/user.dart';
import 'package:instagramzzz/screens/extend_screens/message_screen.dart';
import 'package:instagramzzz/screens/extend_screens/notification_screen.dart';
import 'package:instagramzzz/utils/colors.dart';
import 'package:instagramzzz/utils/global_variables.dart';
import 'package:instagramzzz/widgets/post_card.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class FeedScreen extends StatelessWidget {
  final uid;
  FeedScreen({required this.uid});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: width > webScreenSize
          // as we dont want appbar show in web version
          ? null
          : AppBar(
              backgroundColor: width > webScreenSize
                  ? webBackgroundColor
                  : mobileBackgroundColor,
              centerTitle: false,
              title: SvgPicture.asset(
                'images/ic_instagram.svg',
                color: primaryColor,
                height: 32,
              ),
              actions: [
                IconButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => NotificationScreen(),
                      ),
                    );
                  },
                  icon: Icon(
                    Icons.favorite_outline,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => MessageScreen(),
                      ),
                    );
                  },
                  icon: Icon(
                    Icons.messenger_rounded,
                  ),
                ),
              ],
            ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('posts')
            .orderBy('datePublished', descending: true)
            .snapshots(),
        builder: (
          context,
          AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot,
        ) {
          var size = MediaQuery.of(context).size;

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: LoadingAnimationWidget.hexagonDots(
                color: Colors.yellow,
                size: 40,
              ),
            );
          }

          if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
            // Handle the case where there are no documents in the snapshot
            return Center(
              child: Text('No posts available'),
            );
          }

          // List of story circle avatars
          var storyCircleAvatars = FutureBuilder(
            future: FirebaseFirestore.instance.collection('users').get(),
            builder: (
              context,
              AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> userSnapshot,
            ) {
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return LoadingAnimationWidget.dotsTriangle(
                  color: Colors.yellow,
                  size: 40,
                );
              }

              if (!userSnapshot.hasData || userSnapshot.data!.docs.isEmpty) {
                return Center(
                  child: Text('No registered users'),
                );
              }

              print('Profile Photo: $uid');

              // Find the index of the current user in the userSnapshot
              int currentUserIndex = userSnapshot.data!.docs.indexWhere(
                (user) => user.id == uid,
                // Assuming 'id' is the field for user's uid
              );

              print('Current User Index: $currentUserIndex');

              List<Widget> circleAvatars = [];

              // Add the current user's avatar with add button
              circleAvatars.add(
                Padding(
                  padding: EdgeInsets.only(right: 10),
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          InkWell(
                            onTap: () {
                              print('show the current user avatar');
                            },
                            child: CircleAvatar(
                              radius: 35,
                              backgroundImage: NetworkImage(
                                userSnapshot.data!.docs[currentUserIndex]
                                    ['photoUrl'],
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: -18,
                            left: 30,
                            child: IconButton(
                              onPressed: () {},
                              iconSize: 28,
                              icon: Icon(Icons.add),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        userSnapshot.data!.docs[currentUserIndex]['username'],
                      ),
                    ],
                  ),
                ),
              );

              // Add other registered users' avatars without add button
              for (int index = 0;
                  index < userSnapshot.data!.docs.length;
                  index++) {
                if (index != currentUserIndex) {
                  User user = User.fromSnap(userSnapshot.data!.docs[index]);
                  circleAvatars.add(
                    Padding(
                      padding: EdgeInsets.only(right: 10),
                      child: Column(
                        children: [
                          InkWell(
                            onTap: () {
                              print('other user avatar');
                            },
                            child: CircleAvatar(
                              radius: 35,
                              backgroundImage: NetworkImage(user.photoUrl),
                            ),
                          ),
                          Text(user.username),
                        ],
                      ),
                    ),
                  );
                }
              }

              return ListView.builder(
                physics: BouncingScrollPhysics(),
                scrollDirection: Axis.horizontal,
                itemCount: circleAvatars.length,
                itemBuilder: (context, index) {
                  return circleAvatars[index];
                },
              );
            },
          );

          // Combined ListView with story circle avatars and post cards
          return ListView(
            physics: BouncingScrollPhysics(),
            children: [
              Container(
                margin: EdgeInsets.symmetric(
                  horizontal: width > webScreenSize ? width * 0.3 : 0,
                  vertical: width > webScreenSize ? 15 : 0,
                ),
                width: size.width,
                height: size.height * 0.14,
                child: storyCircleAvatars,
              ),
              ListView.builder(
                physics: BouncingScrollPhysics(),
                shrinkWrap: true,
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: EdgeInsets.symmetric(
                      horizontal: width > webScreenSize ? width * 0.3 : 0,
                      vertical: width > webScreenSize ? 15 : 0,
                    ),
                    child: PostCard(
                      snap: snapshot.data!.docs[index].data(),
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
