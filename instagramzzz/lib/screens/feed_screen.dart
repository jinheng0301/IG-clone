import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:instagramzzz/utils/colors.dart';
import 'package:instagramzzz/utils/global_variables.dart';
import 'package:instagramzzz/widgets/post_card.dart';

class FeedScreen extends StatelessWidget {
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
                  onPressed: () {},
                  icon: Icon(
                    Icons.messenger_rounded,
                  ),
                ),
              ],
            ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('posts').snapshots(),
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
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              return Container(
                margin: EdgeInsets.symmetric(
                    horizontal: width > webScreenSize ? width * 0.3 : 0,
                    vertical: width > webScreenSize ? 15 : 0),
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
