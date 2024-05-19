import 'package:flutter/material.dart';
import 'package:instagramzzz/providers/user_provider.dart';
import 'package:instagramzzz/resources/firestore_method.dart';
import 'package:instagramzzz/screens/navigator%20bar%20main%20screens/profile_screen.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class CommentCard extends StatefulWidget {
  final snap;
  final String postId;
  
  CommentCard({
    required this.snap,
    required this.postId,
  });

  @override
  State<CommentCard> createState() => _CommentCardState();
}

class _CommentCardState extends State<CommentCard> {
  @override
  Widget build(BuildContext context) {
    // Get the required parameters from the widget's snapshot
    final postId = widget.postId;
    final commentId = widget.snap['commentId'];
    final uid = Provider.of<UserProvider>(context).getUser.uid;
    final likes = List<String>.from(widget.snap['likes'] ?? []);
    final user = Provider.of<UserProvider>(context).getUser;

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

          // Implement like function
          GestureDetector(
            onTap: () async {
              await FirestoreMethods().likeComment(
                postId,
                commentId,
                uid,
                likes,
              );
            },
            child: Container(
              padding: EdgeInsets.all(8),
              child: Column(
                children: [
                  likes.contains(user.uid)
                      ? Icon(
                          Icons.favorite,
                          size: 20,
                          color: Colors.red,
                        )
                      : Icon(
                          Icons.favorite_outline,
                          size: 20,
                          color: Colors.white,
                        ),
                  Text(
                    '${likes.length} likes',
                    style: TextStyle(
                      fontSize: 11,
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
