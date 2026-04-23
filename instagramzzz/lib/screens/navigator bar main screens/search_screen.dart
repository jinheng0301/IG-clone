import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:instagramzzz/screens/extend_screens/profile_post_screen.dart';
import 'package:instagramzzz/screens/navigator%20bar%20main%20screens/profile_screen.dart';
import 'package:instagramzzz/utils/colors.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class SearchScreen extends StatefulWidget {
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController searchController = TextEditingController();
  bool isShowUsers = false;

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    searchController.dispose();
  }

  Future<void> _refreshSearchScreen() async {
    try {
      // Refresh logic here, e.g., re-fetch data from Firestore
      // In this example, we are just delaying for 2 seconds
      await Future.delayed(Duration(seconds: 2));
    } catch (e) {
      print('Error refereshing new profile screen: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: mobileBackgroundColor,
        title: TextFormField(
          controller: searchController,
          decoration: const InputDecoration(
            labelText: 'Search for a user',
          ),
          onFieldSubmitted: (String _) {
            setState(() {
              isShowUsers = true;
            });
          },
        ),
      ),
      body: isShowUsers
          ? FutureBuilder(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .where(
                    'username',
                    isGreaterThanOrEqualTo: searchController.text,
                  )
                  .limit(20)
                  .get(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  // if snapshot has no data
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                // search the user
                return ListView.builder(
                  itemCount: (snapshot.data! as dynamic).docs.length,
                  itemBuilder: (context, index) {
                    var userData =
                        (snapshot.data! as dynamic).docs[index].data();
                    var uid = userData['uid'];
                    var photoUrl = userData['photoUrl'];
                    var username = userData['username'];

                    // Check if the required fields exist
                    if (uid != null && photoUrl != null && username != null) {
                      return InkWell(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => ProfileScreen(uid: uid),
                            ),
                          );
                        },
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundImage:
                                CachedNetworkImageProvider(photoUrl),
                          ),
                          title: Text(username),
                        ),
                      );
                    } else {
                      // Handle the case where one or more fields are missing
                      return Container(); // or some other fallback widget
                    }
                  },
                );
              },
            )
          : RefreshIndicator(
            onRefresh: _refreshSearchScreen,
            child: FutureBuilder(
                future: FirebaseFirestore.instance
                    .collection('posts')
                    .orderBy('datePublished', descending: true)
                    .limit(60)
                    .get(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    // if snapshot has no data
                    return Center(
                      child: LoadingAnimationWidget.newtonCradle(
                        color: Colors.cyan,
                        size: 60,
                      ),
                    );
                  }
            
                  return MasonryGridView.count(
                    crossAxisCount: 3,
                    itemCount: (snapshot.data! as dynamic).docs.length,
                    itemBuilder: (context, index) {
                      DocumentSnapshot snap =
                          (snapshot.data! as dynamic).docs[index];
            
                      var posturl = (snap.data()! as dynamic)['postUrl'];
                      var uid = (snap.data()! as dynamic)['uid'];
            
                      if (posturl != null && uid != null) {
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProfilePostScreen(
                                  uid: uid,
                                  postId: snap.id,
                                  initialIndex: index,
                                ),
                              ),
                            );
                          },
                          child: CachedNetworkImage(
                            imageUrl:
                                (snapshot.data! as dynamic).docs[index]['postUrl'],
                            fit: BoxFit.cover,
                            placeholder: (context, url) => const AspectRatio(
                              aspectRatio: 1,
                              child: ColoredBox(color: Colors.black12),
                            ),
                            errorWidget: (context, url, error) => const SizedBox(
                              height: 120,
                              child: Center(child: Icon(Icons.broken_image)),
                            ),
                          ),
                        );
                      } else {
                        return const Text('No image available');
                      }
                    },
                    mainAxisSpacing: 8.0,
                    crossAxisSpacing: 8.0,
                  );
                },
              ),
          ),
    );
  }
}
