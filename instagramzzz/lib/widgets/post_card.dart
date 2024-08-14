import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagramzzz/models/user.dart' as model;
import 'package:instagramzzz/providers/user_provider.dart';
import 'package:instagramzzz/resources/firestore_method.dart';
import 'package:instagramzzz/screens/extend_screens/comment_screen.dart';
import 'package:instagramzzz/screens/extend_screens/user_liked_screen.dart';
import 'package:instagramzzz/screens/navigator%20bar%20main%20screens/profile_screen.dart';
import 'package:instagramzzz/utils/colors.dart';
import 'package:instagramzzz/utils/global_variables.dart';
import 'package:instagramzzz/utils/utils.dart';
import 'package:instagramzzz/widgets/like_animation.dart';
import 'package:instagramzzz/widgets/zoom_image.dart';
import 'package:intl/intl.dart';
import 'package:panara_dialogs/panara_dialogs.dart';
import 'package:provider/provider.dart';

class PostCard extends StatefulWidget {
  final snap;
  PostCard({required this.snap});

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool isLikeAnimating = false;
  int commentLength = 0;
  List<String> mutualFollowers = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getComment();
    getMutualFollower();
  }

  void getComment() async {
    try {
      QuerySnapshot snap = await FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.snap['postId'])
          .collection('comments')
          .get();

      commentLength = snap.docs.length;
    } catch (e) {
      showSnackBar(e.toString(), context);
    }

    setState(() {});
  }

  void getMutualFollower() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser!;
      final currentUserDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();

      List following = currentUserDoc.data()!['following'];

      List<String> mutualFollowerIds = [];

      // Check if users who liked the post are in the current user's following list
      for (var uid in widget.snap['likes']) {
        if (following.contains(uid)) {
          mutualFollowerIds.add(uid);
        }
      }

      // Fetch usernames for the mutual followers
      for (var uid in mutualFollowerIds) {
        final userDoc =
            await FirebaseFirestore.instance.collection('users').doc(uid).get();

        String username = userDoc.data()!['username'];
        mutualFollowers.add(username);
      }

      setState(() {});
    } catch (e) {
      showSnackBar(e.toString(), context);
    }
  }

  Future<void> _showDialogBox() async {
    return PanaraConfirmDialog.show(
      context,
      title: 'Delete post',
      message: 'Want to delete post?',
      confirmButtonText: 'Sure!',
      onTapConfirm: () async {
        await FirestoreMethods().deletePost(
          widget.snap['postId'].toString(),
        );
        Navigator.of(context).pop();
      },
      cancelButtonText: 'No, please dont!',
      onTapCancel: () {
        Navigator.of(context).pop();
      },
      padding: EdgeInsets.all(10),
      panaraDialogType: PanaraDialogType.normal,
      barrierDismissible: false,
      // Optional: Prevents dialog from closing when tapped outside
      textColor: Colors.amber,
    );
  }

  @override
  Widget build(BuildContext context) {
    final model.User user = Provider.of<UserProvider>(context).getUser;
    var firebaseAuth = FirebaseAuth.instance.currentUser!.uid;
    final width = MediaQuery.of(context).size.width;

    return Container(
      color: width > webScreenSize ? secondaryColor : mobileBackgroundColor,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        children: [
          // HEADER SECTION
          Container(
            padding: const EdgeInsets.symmetric(
              vertical: 4,
              horizontal: 16,
            ).copyWith(right: 0),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => ProfileScreen(
                          uid: widget.snap['uid'],
                        ),
                      ),
                    );
                  },
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(
                      widget.snap['profImage'],
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => ProfileScreen(
                            uid: widget.snap['uid'],
                          ),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.snap['username'],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                // delete the post
                IconButton(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (context) => Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(10),
                        child: ListView(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          children: [
                            // Check if the current user is the owner of the post
                            if (user.uid == widget.snap['uid'].toString()) ...[
                              ListTile(
                                leading: Icon(Icons.delete_forever),
                                title: Text('Delete post'),
                                onTap: () {
                                  Navigator.of(context).pop();
                                  _showDialogBox();
                                },
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.more_vert,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // IMAGE SECTION
          GestureDetector(
            // to detect the double click at the photo when user click it
            onDoubleTap: () {
              FirestoreMethods().likePost(
                widget.snap['postId'],
                user.uid,
                widget.snap['likes'],
              );
              setState(() {
                isLikeAnimating = true;
              });
            },
            child: Stack(
              alignment: Alignment.center,
              children: [
                AspectRatio(
                  aspectRatio: 18 / 18,
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height,
                    width: double.infinity,
                    child: ZoomImage(
                      imageUrls: [
                        widget.snap['postUrl'],
                      ], // Pass the list of image URLs
                      currentIndex: 0, // Pass the current index
                    ),
                  ),
                ),
                AnimatedOpacity(
                  opacity: isLikeAnimating ? 1 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: LikeAnimation(
                    isAnimating: isLikeAnimating,
                    duration: const Duration(milliseconds: 400),
                    onEnd: () {
                      setState(() {
                        isLikeAnimating = false;
                      });
                    },
                    child: const Icon(
                      Icons.favorite,
                      color: Colors.white,
                      size: 120,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // LIKE COMMENT SECTION
          Container(
            margin: EdgeInsets.only(left: 5),
            child: Row(
              children: [
                LikeAnimation(
                  isAnimating: widget.snap['likes'].contains(user.uid),
                  smallLike: true,
                  child: IconButton(
                    onPressed: () async {
                      await FirestoreMethods().likePost(
                        widget.snap['postId'],
                        user.uid,
                        widget.snap['likes'],
                      );
                    },
                    icon: widget.snap['likes'].contains(user.uid)
                        ? const Icon(
                            Icons.favorite,
                            color: Colors.red,
                          )
                        : const Icon(
                            Icons.favorite_border,
                          ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => UserLikedScreen(
                          postId: widget.snap['postId'],
                          uid: firebaseAuth,
                        ),
                      ),
                    );
                  },
                  child: DefaultTextStyle(
                    style: Theme.of(context).textTheme.titleSmall!.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                    child: Text(
                      '${widget.snap['likes'].length} likes',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => CommentScreen(
                          snap: widget.snap,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.comment_outlined),
                ),
                DefaultTextStyle(
                  style: Theme.of(context).textTheme.titleSmall!.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                  child: Text(commentLength.toString()),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.send),
                ),
                Expanded(
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.bookmark_border),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // DESCRIPTION AND VIEW COMMENTS
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: Theme.of(context).textTheme.titleSmall,
                    children: [
                      const TextSpan(
                        text: 'Liked by ',
                        style: TextStyle(fontWeight: FontWeight.w400),
                      ),
                      // Display mutual followers
                      for (var i = 0; i < mutualFollowers.length; i++) ...[
                        TextSpan(
                          text: '${mutualFollowers[i]}',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        if (i < mutualFollowers.length - 1) ...[
                          const TextSpan(text: ', '),
                        ],
                      ],
                    ],
                  ),
                ),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => ProfileScreen(
                              uid: widget.snap['uid'],
                            ),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.only(top: 8),
                        child: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: widget.snap['username'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.only(left: 10, top: 8),
                        child: RichText(
                          text: TextSpan(
                            text: '${widget.snap['description']}',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                // VIEW COMMENTS
                InkWell(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (context) => Container(
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                          ),
                        ),
                        child: CommentScreen(snap: widget.snap),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: const Text(
                      'View all comments',
                      style: TextStyle(
                        fontSize: 16,
                        color: secondaryColor,
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    DateFormat.yMMMd().format(
                      widget.snap['datePublished'].toDate(),
                    ),
                    style: const TextStyle(
                      fontSize: 15,
                      color: secondaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
