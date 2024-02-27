import 'package:flutter/material.dart';
import 'package:instagramzzz/resources/firestore_method.dart';
import 'package:instagramzzz/screens/navigator%20bar%20main%20screens/profile_screen.dart';
import 'package:intl/intl.dart';

class CommentCard extends StatefulWidget {
  final snap;

  CommentCard({required this.snap});

  @override
  State<CommentCard> createState() => _CommentCardState();
}

class _CommentCardState extends State<CommentCard> {
  void _showDeleteCommentDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Delete Comment'),
          content: Text('Are you sure you want to delete this comment?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                print('Comment Data: ${widget.snap}');
                print(
                  'postId: ${widget.snap['postId']}, commentId: ${widget.snap['commentId']}',
                );
                Navigator.of(dialogContext).pop(); // Close the dialog
                await _deleteComment();
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteComment() async {
    try {
      if (widget.snap['postId'] != null && widget.snap['commentId'] != null) {
        await FirestoreMethods().deleteComment(
          widget.snap['postId'],
          widget.snap['commentId'],
        );
        // Optionally, you can update the UI by rebuilding the widget or refreshing the comments
        // Example: You can call setState(() { /* update UI */ }); or trigger a stream update.
      } else {
        print('Comment data is missing');
      }
    } catch (e) {
      print('Error deleting comment: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ProfileScreen(
                    uid: widget.snap['uid'],
                  ),
                ),
              );
            },
            child: CircleAvatar(
              backgroundImage: NetworkImage(
                widget.snap['profPic'],
              ),
              radius: 18,
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => ProfileScreen(
                            uid: widget.snap['uid'],
                          ),
                        ),
                      );
                    },
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: widget.snap['name'],
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  RichText(
                    text: TextSpan(
                      text: '${widget.snap['text']}',
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 4),
                    child: Text(
                      DateFormat.yMMMd().format(
                        widget.snap['datePublished'].toDate(),
                      ),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          //TODO: implement like function
          GestureDetector(
            onTap: () {
              _showDeleteCommentDialog(context);
            },
            child: Container(
              padding: EdgeInsets.all(8),
              child: Icon(
                Icons.favorite,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
