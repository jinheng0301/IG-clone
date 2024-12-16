import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:instagramzzz/utils/colors.dart';
import 'package:instagramzzz/utils/global_variables.dart';
import 'package:instagramzzz/utils/utils.dart';

class MobileScreenLayout extends StatefulWidget {
  final String uid;
  const MobileScreenLayout({super.key, required this.uid});

  @override
  State<MobileScreenLayout> createState() => _MobileScreenLayoutState();
}

class _MobileScreenLayoutState extends State<MobileScreenLayout> {
  var userData = {};
  int _page = 0;
  bool isLoading = false;
  bool isDisplayedAvatar = false;
  late PageController pageController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getData();
    pageController = PageController();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    pageController.dispose();
  }

  void navigationTapped(int page) {
    pageController.jumpToPage(page);
  }

  void onPageChanged(int page) {
    setState(() {
      _page = page;
    });
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
      isDisplayedAvatar = true;

      setState(() {});
    } catch (e) {
      try {
  if (mounted) {
    setState(() {
      // Update your state here
    });
  }
} catch (e) {
  if (mounted) {
    showSnackBar(e.toString(), context);
  }
}

    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: pageController,
        onPageChanged: onPageChanged,
        physics: NeverScrollableScrollPhysics(),
        children: homeScreenItems,
      ),
      bottomNavigationBar: CupertinoTabBar(
        onTap: navigationTapped,
        items: [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.home,
              size: 30,
              color: _page == 0 ? primaryColor : secondaryColor,
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.search,
              size: 30,
              color: _page == 1 ? primaryColor : secondaryColor,
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.add_circle_outline,
              size: 30,
              color: _page == 2 ? primaryColor : secondaryColor,
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.tiktok,
              size: 30,
              color: _page == 3 ? primaryColor : secondaryColor,
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: isDisplayedAvatar
                ? CircleAvatar(
                    radius: 13,
                    backgroundColor: Colors.grey,
                    backgroundImage: NetworkImage(
                      userData['photoUrl'] ?? 'Photo not available',
                    ),
                  )
                : Icon(
                    Icons.person,
                    size: 30,
                    color: _page == 4 ? primaryColor : secondaryColor,
                  ),
            label: '',
          ),
        ],
      ),
    );
  }
}
