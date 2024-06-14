import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:instagramzzz/models/user.dart';
import 'package:instagramzzz/providers/user_provider.dart';
import 'package:instagramzzz/resources/firestore_method.dart';
import 'package:instagramzzz/utils/colors.dart';
import 'package:instagramzzz/widgets/comment_card.dart';
import 'package:panara_dialogs/panara_dialogs.dart';
import 'package:provider/provider.dart';

class CommentScreen extends StatefulWidget {
  final snap;
  CommentScreen({required this.snap});

  @override
  State<CommentScreen> createState() => _CommentScreenState();
}

class _CommentScreenState extends State<CommentScreen> {
  final TextEditingController _commentController = TextEditingController();

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _commentController.dispose();
  }

  Future<void> _showDialogBox(
    String postId,
    String commentId,
    bool isOwnerAcc,
  ) async {
    isOwnerAcc
        ? PanaraInfoDialog.show(
            context,
            title: 'Delete comment',
            message: 'Are you sure want to delete comment?',
            buttonText: 'Conlan7firm!',
            onTapDismiss: () async {
              await FirestoreMethods().deleteComment(postId, commentId);
              Navigator.of(context).pop();
            },
            padding: EdgeInsets.all(10),
            panaraDialogType: PanaraDialogType.warning,
            textColor: Colors.red,
          )
        : PanaraInfoDialog.show(
            context,
            title: 'Delete comment',
            message: 'Delete comment function only available to current user.',
            buttonText: 'Conlan7firm!',
            onTapDismiss: () async {
              Navigator.of(context).pop();
            },
            padding: EdgeInsets.all(10),
            panaraDialogType: PanaraDialogType.warning,
            textColor: Colors.amber,
          );
  }

  @override
  Widget build(BuildContext context) {
    final User user = Provider.of<UserProvider>(context).getUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Comment'),
        centerTitle: false,
        // it shows with left align
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('posts')
            .doc(widget.snap['postId'])
            .collection('comments')
            .orderBy('datePublished', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return ListView.builder(
            itemCount: (snapshot.data as dynamic).docs.length,
            itemBuilder: (context, index) {
              var commentSnap = (snapshot.data as dynamic).docs[index];
              var commentData = commentSnap.data();
              String commentId = commentSnap.id;

              return GestureDetector(
                onLongPress: () {
                  _showDialogBox(
                    widget.snap['postId'],
                    commentId,
                    commentData['uid'] == user.uid,
                  );
                },
                // Without the return statement,
                // the CommentCard widgets are not being returned, and as a result,
                // they are not being displayed on the screen.
                child: CommentCard(
                  snap: commentData,
                  postId: widget.snap['postId'],
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          height: kToolbarHeight,
          margin: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          padding: const EdgeInsets.only(left: 16, right: 8),
          child: Row(
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(user.photoUrl),
                radius: 18,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 8, left: 16),
                  child: TextField(
                    controller: _commentController,
                    decoration: InputDecoration(
                      hintText: 'Comment as ${user.username}',
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              InkWell(
                onTap: () async {
                  await FirestoreMethods().postComment(
                    widget.snap['postId'],
                    _commentController.text,
                    user.uid,
                    user.username,
                    user.photoUrl,
                  );
                  setState(() {
                    _commentController.text = '';
                  });
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                  child: const Text(
                    'Post',
                    style: TextStyle(color: blueColor),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
