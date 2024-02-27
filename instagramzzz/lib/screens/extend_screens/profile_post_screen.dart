import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagramzzz/utils/global_variables.dart';
import 'package:instagramzzz/widgets/post_card.dart';

class ProfilePostScreen extends StatefulWidget {
  late final String userUid;

  ProfilePostScreen({
    required this.userUid,
  });

  @override
  State<ProfilePostScreen> createState() => _ProfilePostScreenState();
}

class _ProfilePostScreenState extends State<ProfilePostScreen> {
  int postLength = 0;
  bool isLoading = false;

  @override
  void initState() {
    // TODO: implement initState
    getPhoto();
    super.initState();
  }

  void getPhoto() async {
    setState(() {
      isLoading = true;
    });

    try {
      // get post length
      var postSnap = await FirebaseFirestore.instance
          .collection('posts')
          .where('uid', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .get();

      postLength = postSnap.docs.length;

      setState(() {});
    } catch (e) {
      e.toString();
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text('Posts'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('posts')
            .where('uid', isEqualTo: widget.userUid)
            .orderBy('datePublished', descending: true)
            .snapshots(),
        builder: (
          context,
          AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot,
        ) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
            // Handle the case where there are no documents in the snapshot
            return Center(
              child: Text('No posts available'),
            );
          }

          return ListView.builder(
            physics: BouncingScrollPhysics(),
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
          );
        },
      ),
    );
  }
}
