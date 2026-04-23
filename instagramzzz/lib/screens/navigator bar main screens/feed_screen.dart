import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:instagramzzz/models/user.dart';
import 'package:instagramzzz/screens/extend_screens/message_screen.dart';
import 'package:instagramzzz/screens/extend_screens/notification_screen.dart';
import 'package:instagramzzz/utils/colors.dart';
import 'package:instagramzzz/utils/global_variables.dart';
import 'package:instagramzzz/utils/utils.dart';
import 'package:instagramzzz/widgets/post_card.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:image_picker/image_picker.dart';

class FeedScreen extends StatefulWidget {
  final uid;
  FeedScreen({required this.uid, super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final GlobalKey<RefreshIndicatorState> _refreshKey = GlobalKey();
  static const int _feedPageSize = 20;

  List<String> _storyUserIds(String currentUid, List<dynamic> following) {
    final ids = <String>{currentUid};
    for (final uid in following) {
      if (uid is String && uid.isNotEmpty) {
        ids.add(uid);
      }
      if (ids.length >= 10) {
        break;
      }
    }
    return ids.toList();
  }

  Future<void> _refreshFeed() async {
    try {
      // Force refresh from server (not cache)
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.uid)
          .get(GetOptions(source: Source.server));

      await FirebaseFirestore.instance
          .collection('posts')
          .orderBy('datePublished', descending: true)
          .limit(1)
          .get(GetOptions(source: Source.server));

      // Trigger rebuild by calling setState
      if (mounted) {
        setState(() {});
      }

      await Future.delayed(Duration(milliseconds: 300));
    } catch (e) {
      print('Error refreshing feed: $e');
      if (mounted) {
        showSnackBar('Failed to refresh feed', context);
      }
    }
  }

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
                  icon: Icon(Icons.messenger_outline_rounded),
                ),
              ],
            ),
      body: RefreshIndicator(
        key: _refreshKey,
        onRefresh: _refreshFeed,
        // Using StreamBuilder to fetch user data and posts
        child: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(widget.uid)
              .snapshots(),
          builder: (context, AsyncSnapshot<DocumentSnapshot> userSnapshot) {
            List<dynamic> following = userSnapshot.data?.get('following') ?? [];
            List<String> userIdsToShow = [
              widget.uid,
              ...following.cast<String>()
            ];

            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: LoadingAnimationWidget.flickr(
                  leftDotColor: Colors.red,
                  rightDotColor: Colors.blue,
                  size: 40,
                ),
              );
            }

            if (!userSnapshot.hasData || userSnapshot.data == null) {
              return Center(
                child: Text('User not found'),
              );
            }

            if (userIdsToShow.isEmpty) {
              return Center(
                child: Text('Follow users to see their posts'),
              );
            }

            // Add the second StreamBuilder for posts here
            // Used to fetch posts from followed users
            return StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('posts')
                  .orderBy('datePublished', descending: true)
                  .limit(_feedPageSize)
                  .snapshots(),
              builder: (
                context,
                AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot,
              ) {
                var size = MediaQuery.of(context).size;

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: LoadingAnimationWidget.flickr(
                      leftDotColor: Colors.red,
                      rightDotColor: Colors.blue,
                      size: 40,
                    ),
                  );
                }

                if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Text('No posts available'),
                  );
                }

                // Filter posts to only show from followed users
                var filteredPosts = snapshot.data!.docs.where((doc) {
                  return userIdsToShow.contains(doc.data()['uid']);
                }).toList();

                if (filteredPosts.isEmpty) {
                  return Center(
                    child: Text('No posts from followed users'),
                  );
                }

                // List of story circle avatars
                final storyIds = _storyUserIds(widget.uid, following);
                var storyCircleAvatars = FutureBuilder(
                  future: FirebaseFirestore.instance
                      .collection('users')
                      .where(FieldPath.documentId, whereIn: storyIds)
                      .get(),
                  builder: (
                    context,
                    AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>>
                        userSnapshot,
                  ) {
                    if (userSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return LoadingAnimationWidget.dotsTriangle(
                        color: Colors.yellow,
                        size: 40,
                      );
                    }

                    if (!userSnapshot.hasData ||
                        userSnapshot.data!.docs.isEmpty) {
                      return Center(
                        child: Text('No registered users'),
                      );
                    }

                    int currentUserIndex = userSnapshot.data!.docs.indexWhere(
                      (user) => user.id == widget.uid,
                    );

                    List<Widget> circleAvatars = [];

                    if (currentUserIndex != -1) {
                      circleAvatars.add(
                        Padding(
                          padding: EdgeInsets.only(right: 10),
                          child: Column(
                            children: [
                              Stack(
                                children: [
                                  InkWell(
                                    onTap: () {},
                                    child: CircleAvatar(
                                      radius: 35,
                                      backgroundImage:
                                          CachedNetworkImageProvider(
                                        userSnapshot.data!.docs[currentUserIndex]
                                            ['photoUrl'],
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: -18,
                                    left: 30,
                                    child: IconButton(
                                      color: Colors.white,
                                      onPressed: () async {
                                        await pickImage(ImageSource.camera);
                                        Navigator.of(context).pop();
                                      },
                                      iconSize: 28,
                                      icon: Icon(Icons.add),
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                userSnapshot.data!.docs[currentUserIndex]
                                    ['username'],
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    for (int index = 0;
                        index < userSnapshot.data!.docs.length;
                        index++) {
                      if (index != currentUserIndex) {
                        User user =
                            User.fromSnap(userSnapshot.data!.docs[index]);
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
                                    backgroundImage:
                                        CachedNetworkImageProvider(
                                      user.photoUrl,
                                    ),
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
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: filteredPosts.length,
                      itemBuilder: (context, index) {
                        return Container(
                          margin: EdgeInsets.symmetric(
                            horizontal: width > webScreenSize ? width * 0.3 : 0,
                            vertical: width > webScreenSize ? 15 : 0,
                          ),
                          child: PostCard(
                            snap: filteredPosts[index].data(),
                          ),
                        );
                      },
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}
