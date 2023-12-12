import 'package:flutter/material.dart';
import 'package:instagramzzz/providers/user_provider.dart';
import 'package:instagramzzz/utils/global_variables.dart';
import 'package:provider/provider.dart';

class ResponsiveLayout extends StatefulWidget {
  late final Widget webScreenLayout;
  late final Widget mobileScreenLayout;

  ResponsiveLayout({
    required this.webScreenLayout,
    required this.mobileScreenLayout,
  });

  @override
  State<ResponsiveLayout> createState() => _ResponsiveLayoutState();
}

class _ResponsiveLayoutState extends State<ResponsiveLayout> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    addData();
  }

  addData() async {
    UserProvider _userProvider = Provider.of(context, listen: false);
    await _userProvider.refreshUser();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, Constraints) {
        if (Constraints.maxWidth > webScreenSize) {
          // web screen
          return widget.webScreenLayout;
        } else {
          // mobile screen
          return widget.mobileScreenLayout;
        }
      },
    );
  }
}
