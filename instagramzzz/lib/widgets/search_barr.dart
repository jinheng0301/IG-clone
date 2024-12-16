import 'package:flutter/material.dart';

class SearchBarr extends StatelessWidget {
  late final String hintText;
  late final TextInputType textInputType;
  late final TextEditingController textEditingController;

  SearchBarr({
    required this.hintText,
    required this.textInputType,
    required this.textEditingController,
  });

  @override
  Widget build(BuildContext context) {
    final inputBorder = OutlineInputBorder(
      borderSide: Divider.createBorderSide(context),
    );

    return TextField(
      controller: textEditingController,
      keyboardType: textInputType,
      decoration: InputDecoration(
        hintText: hintText,
        border: inputBorder,
        focusedBorder: inputBorder,
        enabledBorder: inputBorder,
        filled: true,
        contentPadding: EdgeInsets.all(10),
      ),
    );
  }
}
