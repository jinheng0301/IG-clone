import 'package:flutter/material.dart';

class FollowButton extends StatelessWidget {
  late final String text;
  late final Color backgroundColor;
  late final Color borderColor;
  late final Color textColor;
  final Function()? function;
  // ? means which can be null

  FollowButton({
    required this.text,
    this.function,
    // function can be nullable value, so dont put required keyword
    required this.backgroundColor,
    required this.borderColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        width: 200,
        height: 50,
        padding: EdgeInsets.only(top: 2),
        child: TextButton(
          onPressed: function,
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: backgroundColor,
              border: Border.all(
                color: borderColor,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              text,
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
