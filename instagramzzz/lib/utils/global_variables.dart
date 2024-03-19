import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagramzzz/screens/navigator%20bar%20main%20screens/add_post_screen.dart';
import 'package:instagramzzz/screens/navigator%20bar%20main%20screens/feed_screen.dart';
import 'package:instagramzzz/screens/navigator%20bar%20main%20screens/profile_screen.dart';
import 'package:instagramzzz/screens/navigator%20bar%20main%20screens/reels_screen.dart';
import 'package:instagramzzz/screens/navigator%20bar%20main%20screens/search.dart';

const webScreenSize = 600;

List<Widget> homeScreenItems = [
  FeedScreen(
    uid: FirebaseAuth.instance.currentUser!.uid,
  ),
  SearchScreen(),
  AddPostScreen(),
  ReelsScreen(),
  ProfileScreen(
    uid: FirebaseAuth.instance.currentUser!.uid,
  ),
];
