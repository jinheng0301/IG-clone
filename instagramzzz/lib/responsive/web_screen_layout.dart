import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:instagramzzz/utils/colors.dart';
import 'package:instagramzzz/utils/global_variables.dart';
import 'package:instagramzzz/utils/utils.dart';

class WebScreenLayout extends StatefulWidget {
  final String uid;
  const WebScreenLayout({super.key, required this.uid});

  @override
  State<WebScreenLayout> createState() => _WebScreenLayoutState();
}

class _WebScreenLayoutState extends State<WebScreenLayout> {
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
    setState(() {
      _page = page;
    });
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
      showSnackBar(e.toString(), context);
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: mobileBackgroundColor,
        centerTitle: false,
        title: SvgPicture.asset(
          'images/ic_instagram.svg',
          color: primaryColor,
          height: 32,
        ),
        actions: [
          IconButton(
            onPressed: () {
              navigationTapped(0);
            },
            icon: Icon(
              Icons.home,
            ),
            color: _page == 0 ? primaryColor : secondaryColor,
          ),
          IconButton(
            onPressed: () {
              navigationTapped(1);
            },
            icon: Icon(
              Icons.search,
            ),
            color: _page == 1 ? primaryColor : secondaryColor,
          ),
          IconButton(
            onPressed: () {
              navigationTapped(2);
            },
            icon: Icon(
              Icons.add_a_photo,
            ),
            color: _page == 2 ? primaryColor : secondaryColor,
          ),
          IconButton(
            onPressed: () {
              navigationTapped(3);
            },
            icon: Icon(
              Icons.favorite,
            ),
            color: _page == 3 ? primaryColor : secondaryColor,
          ),
          IconButton(
            onPressed: () {
              navigationTapped(4);
            },
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
                    color: _page == 4 ? primaryColor : secondaryColor,
                  ),
          ),
        ],
      ),
      body: PageView(
        controller: pageController,
        onPageChanged: onPageChanged,
        physics: NeverScrollableScrollPhysics(),
        children: homeScreenItems,
      ),
    );
  }
}
