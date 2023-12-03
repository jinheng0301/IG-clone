import 'package:flutter/material.dart';
import 'package:instagramzzz/utils/dimensions.dart';

class ResponsiveLayout extends StatelessWidget {
  late final Widget webScreenLayout;
  late final Widget mobileScreenLayout;

  ResponsiveLayout({
    required this.webScreenLayout,
    required this.mobileScreenLayout,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, Constraints) {
        if (Constraints.maxWidth > webScreenSize) {
          // web screen
          return webScreenLayout;
        } else {
          // mobile screen
          return mobileScreenLayout;
        }
      },
    );
  }
}
