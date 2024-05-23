import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
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
  late PageController _pageController;
  List<DocumentSnapshot> posts = [];
  int postLength = 0;
  var userData = {};
  var postData = {};
  bool isLoading = false;

  @override
  void initState() {
    // TODO: implement initState
    getPhoto();
    getData();
    _pageController = PageController(
      initialPage: widget.initialIndex,
    );
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

      posts = postSnap.docs;

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
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${userData['username']} posts'),
      ),
      body: isLoading
          ? Center(
              child: LoadingAnimationWidget.hexagonDots(
                color: Colors.yellow,
                size: 40,
              ),
            )
          : PageView.builder(
            controller: _pageController,
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
