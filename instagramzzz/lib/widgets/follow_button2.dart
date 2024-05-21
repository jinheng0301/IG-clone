import 'package:flutter/material.dart';

class FollowButton2 extends StatelessWidget {
  late final String text;
  late final Color backgroundColor;
  late final Color borderColor;
  late final Color textColor;
  final Function()? function;

  FollowButton2({
    required this.text,
    this.function,
    required this.backgroundColor,
    required this.borderColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      height: 40,
      padding: EdgeInsets.only(top: 2),
      child: TextButton(
        onPressed: function,
        style: TextButton.styleFrom(
          backgroundColor: backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(color: borderColor),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
