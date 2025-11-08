import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagramzzz/resources/firestore_method.dart';
import 'package:instagramzzz/widgets/post_card.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class ProfilePostScreen extends StatefulWidget {
  late final String uid;
  late final String postId;
  late final initialIndex;

  ProfilePostScreen({
    required this.uid,
    required this.postId,
    required this.initialIndex,
  });

  @override
  State<ProfilePostScreen> createState() => _ProfilePostScreenState();
}

class _ProfilePostScreenState extends State<ProfilePostScreen> {
  PageController? _pageController;
  List<DocumentSnapshot> posts = [];
  int postLength = 0;
  var firebaseAuth = FirebaseAuth.instance.currentUser!.uid;
  var userData = {};
  var postData = {};
  bool isLoading = false;
  bool isFollowing = false;
  bool isFollowClicked = false;

  @override
  void initState() {
    // TODO: implement initState
    getPhoto();
    getData();
    super.initState();
  }

  // fetches all user data from firebase
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

      isFollowing = userSnap.data()!['followers'].contains(firebaseAuth);

      setState(() {});
    } catch (e) {
      print(e.toString());
    }

    setState(() {
      isLoading = false;
    });
  }

  // fetches all posts of the user from firebase
  void getPhoto() async {
    setState(() {
      isLoading = true;
    });

    try {
      // get post length
      var postSnap = await FirebaseFirestore.instance
          .collection('posts')
          .where('uid', isEqualTo: widget.uid)
          .get();

      // ✅ Sort manually
      posts = postSnap.docs;
      posts.sort((a, b) {
        Timestamp? aTime = (a.data() as Map<String, dynamic>)['datePublished'];
        Timestamp? bTime = (b.data() as Map<String, dynamic>)['datePublished'];

        if (aTime == null) return 1;
        if (bTime == null) return -1;

        return bTime.compareTo(aTime);
      });

      // ✅ Initialize PageController AFTER sorting
      _pageController = PageController(
        initialPage: widget.initialIndex,
      );

      print('=== ProfilePostScreen DEBUG ===');
      print('Total posts: ${posts.length}');
      print('Initial index: ${widget.initialIndex}');
      if (posts.isNotEmpty && widget.initialIndex < posts.length) {
        var postData =
            posts[widget.initialIndex].data() as Map<String, dynamic>;
        print(
            'Post at index ${widget.initialIndex}: ${postData['description']}');
      }
      print('==============================');

      setState(() {});
    } catch (e) {
      print(e.toString());
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _pageController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          // Add special characters ('s)
          '${userData['username']}\'s posts',
        ),
        actions: [
          if (!isFollowing && firebaseAuth != widget.uid) ...[
            TextButton(
              onPressed: () async {
                setState(() {
                  isFollowClicked = true;
                });

                await FirestoreMethods().followUser(
                  firebaseAuth,
                  userData['uid'],
                );

                setState(() {
                  isFollowing = true;
                });

                Future.delayed(Duration(seconds: 3), () {
                  setState(() {
                    isFollowClicked = false;
                  });
                });
              },
              child: Text(
                isFollowClicked ? 'Following' : 'Follow',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.blue,
                ),
              ),
            ),
          ],
        ],
      ),
      body: isLoading || _pageController == null
          // ✅ Check if PageController is ready
          ? Center(
              child: LoadingAnimationWidget.hexagonDots(
                color: Colors.yellow,
                size: 40,
              ),
            )
          : PageView.builder(
              controller: _pageController!,
              // non-null assertion since we check for null above
              physics: BouncingScrollPhysics(),
              scrollDirection: Axis.vertical,
              itemCount: posts.length,
              itemBuilder: (context, index) {
                return PostCard(
                  snap: posts[index].data() as Map<String, dynamic>,
                );
              },
            ),
    );
  }
}
