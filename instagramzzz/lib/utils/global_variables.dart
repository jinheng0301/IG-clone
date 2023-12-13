import 'package:flutter/material.dart';
import 'package:instagramzzz/screens/add_post_screen.dart';
import 'package:instagramzzz/screens/feed_screen.dart';

const webScreenSize = 600;

const homeScreenItems = [
  FeedScreen(),
  Text('search'),
  AddPostScreen(),
  Text('notification'),
  Text('profile'),
];
