import 'package:flutter/material.dart';

// ignore: must_be_immutable
class ListtileInSetting extends StatelessWidget {
  late final Icon icons;
  late final Text title;
  final Text? text; // Make text optional

  ListtileInSetting({
    required this.icons,
    required this.title,
    this.text, // Optional parameter
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        print('Listtile pressed.');
      },
      child: ListTile(
        leading: icons,
        title: title,
        tileColor: Colors.transparent,
        trailing: Row(
          mainAxisSize:
              MainAxisSize.min, // Prevents Row from taking up too much space
          children: [
            // Conditionally display the text only if it's provided
            if (text != null) ...[
              Text(
                // Access the text content from the Text widget
                text!.data ?? '',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w100,
                ),
              ),
            ],
            Icon(
              Icons.arrow_right,
              size: 30,
            ),
          ],
        ),
      ),
    );
  }
}
