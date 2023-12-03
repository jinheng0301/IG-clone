import 'package:flutter/material.dart';
import 'package:instagramzzz/responsive/mobile_screen_layout.dart';
import 'package:instagramzzz/responsive/responsive_layout_screen.dart';
import 'package:instagramzzz/responsive/web_screen_layout.dart';
import 'package:instagramzzz/utils/colors.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: mobileBackgroundColor,
      ),
      home: ResponsiveLayout(
        webScreenLayout: WebScreenLayout(),
        mobileScreenLayout: MobileScreenLayout(),
      ),
    );
  }
}
