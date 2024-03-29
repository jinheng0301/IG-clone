import 'package:flutter/material.dart';

class FollowScreen extends StatefulWidget {
  final snap;

  FollowScreen({this.snap});

  @override
  State<FollowScreen> createState() => _FollowScreenState();
}

class _FollowScreenState extends State<FollowScreen> {
  var userData = {};
  bool isLoading = false;

  @override
  void initState() {
    // TODO: implement initState
    getData();
    super.initState();
  }

  void getData() async {
    setState(() {
      isLoading = true;
    });

    try {
      // var userSnap = FirebaseFirestore.instance
      //     .collection('users')
      //     .doc(widget.snap['followers'])
      //     .get();
    } catch (e) {
      e.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(userData['username'] ?? 'Username not available'),
      ),
    );
  }
}
