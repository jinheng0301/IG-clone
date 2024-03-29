import 'package:flutter/material.dart';

class MessageOrShareProfileButton extends StatelessWidget {
  late final String text;
  late final Color backgroundColor;
  late final Color borderColor;
  late final Color textColor;
  final Function()? function;

  MessageOrShareProfileButton({
    required this.backgroundColor,
    required this.borderColor,
    required this.textColor,
    required this.text,
    this.function,
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
