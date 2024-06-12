import 'package:flutter/material.dart';
import 'package:instagramzzz/utils/global_variables.dart';

class ReelsScreen extends StatefulWidget {
  const ReelsScreen({super.key});

  @override
  State<ReelsScreen> createState() => _ReelsScreenState();
}

class _ReelsScreenState extends State<ReelsScreen> {
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Center(
        child: width < webScreenSize
            ? const Text('Reels screen')
            : const Text('Notification screen'),
      ),
    );
  }
}
