import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagramzzz/utils/utils.dart';

class modalBottomSheet2 extends StatefulWidget {
  late final String uid;
  modalBottomSheet2({required this.uid});

  @override
  State<modalBottomSheet2> createState() => _modalBottomSheet2State();
}

class _modalBottomSheet2State extends State<modalBottomSheet2> {
  var firebaseAuth = FirebaseAuth.instance.currentUser!.uid; // current user ID
  var userData = {};
  bool isLoading = false;

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

      userData = userSnap.data()!;

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
        ? Center(child: CircularProgressIndicator())
        : SizedBox(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.all(8),
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        userData['username'],
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(),
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    margin: const EdgeInsets.all(6),
                    padding: const EdgeInsets.all(12),
                    child: const Text(
                      'Posts',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    margin: const EdgeInsets.all(6),
                    padding: const EdgeInsets.all(12),
                    child: const Text(
                      'Stories',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    margin: const EdgeInsets.all(6),
                    padding: const EdgeInsets.all(12),
                    child: const Text(
                      'Reels',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    margin: const EdgeInsets.all(6),
                    padding: const EdgeInsets.all(12),
                    child: const Text(
                      'Goes live',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Text(
                    'Get notifications when ${userData['username']} shares photos, videos or broadcast channels.',
                    style: const TextStyle(
                      fontWeight: FontWeight.w100,
                    ),
                  ),
                )
              ],
            ),
          );
  }
}
