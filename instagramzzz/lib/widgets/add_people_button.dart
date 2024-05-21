import 'package:flutter/material.dart';

class AddPeopleButton extends StatelessWidget {
  late final Color backgroundColor;
  late final Color borderColor;
  late final Color iconColor;
  final Function()? function;

  AddPeopleButton({
    required this.backgroundColor,
    required this.borderColor,
    required this.iconColor,
    this.function,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
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
          child: Icon(
            Icons.add,
            color: iconColor,
          ),
        ),
      ),
    );
  }
}
