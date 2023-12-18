import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagramzzz/screens/add_post_screen.dart';
import 'package:instagramzzz/screens/feed_screen.dart';
import 'package:instagramzzz/screens/notification_screen.dart';
import 'package:instagramzzz/screens/profile_screen.dart';
import 'package:instagramzzz/screens/search.dart';

const webScreenSize = 600;

List<Widget> homeScreenItems = [
  FeedScreen(),
  SearchScreen(),
  AddPostScreen(),
  NotificationScreen(),
  ProfileScreen(
    uid: FirebaseAuth.instance.currentUser!.uid,
  ),
];
