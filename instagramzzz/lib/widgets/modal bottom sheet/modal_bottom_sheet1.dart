import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagramzzz/resources/firestore_method.dart';
import 'package:instagramzzz/screens/auth_screens/login_screen.dart';
import 'package:panara_dialogs/panara_dialogs.dart';

class modalBottomSheet1 extends StatefulWidget {
  late final String uid;
  modalBottomSheet1({required this.uid});

  @override
  State<modalBottomSheet1> createState() => _modalBottomSheet1State();
}

class _modalBottomSheet1State extends State<modalBottomSheet1> {
  var firebaseAuth = FirebaseAuth.instance.currentUser!.uid; 
 // current user ID
  Future<void> _showDeleteAccountDialogBox(context, String uid) async {
    return PanaraConfirmDialog.show(
      context,
      title: 'Delete Account',
      message: 'You sure u wanna delete your account?',
      confirmButtonText: 'Conlan7firm!',
      onTapConfirm: () async {
        await FirestoreMethods().deleteAccount(uid);
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const LoginScreen(),
          ),
        );
      },
      cancelButtonText: 'I bettter think again...',
      onTapCancel: () {
        Navigator.of(context).pop();
      },
      padding: const EdgeInsets.all(10),
      panaraDialogType: PanaraDialogType.warning,
      barrierDismissible: false,
      // Optional: Prevents dialog from closing when tapped outside
      textColor: Colors.red,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: SizedBox(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              firebaseAuth == widget.uid
                  ? _buildMenuOption(context, 'Settings', Icons.settings, () {})
                  : _buildMenuOption(context, 'Report...', null, () {}),
              firebaseAuth == widget.uid
                  ? _buildMenuOption(
                      context, 'Threads', Icons.social_distance, () {})
                  : _buildMenuOption(context, 'Block', null, () {}),
              firebaseAuth == widget.uid
                  ? _buildMenuOption(
                      context, 'Your activity', Icons.local_activity, () {})
                  : _buildMenuOption(
                      context, 'About This Account', null, () {}),
              firebaseAuth == widget.uid
                  ? _buildMenuOption(context, 'Archive', Icons.archive, () {})
                  : _buildMenuOption(context, 'Restrict', null, () {}),
              firebaseAuth == widget.uid
                  ? _buildMenuOption(context, 'QR code', Icons.qr_code, () {})
                  : Container(),
              firebaseAuth == widget.uid
                  ? _buildMenuOption(context, 'Saved', Icons.bookmark, () {})
                  : _buildMenuOption(context, 'Restrict', null, () {}),
              firebaseAuth == widget.uid
                  ? _buildMenuOption(
                      context, 'Supervision', Icons.people, () {})
                  : _buildMenuOption(context, 'Restrict', null, () {}),
              firebaseAuth == widget.uid
                  ? _buildMenuOption(
                      context, 'Orders and payments', Icons.credit_card, () {})
                  : _buildMenuOption(
                      context, 'See shared activity', null, () {}),
              firebaseAuth == widget.uid
                  ? _buildMenuOption(
                      context, 'Meta verified', Icons.verified, () {})
                  : _buildMenuOption(context, 'Hide your story', null, () {}),
              firebaseAuth == widget.uid
                  ? _buildMenuOption(
                      context, 'Close friends', Icons.closed_caption, () {})
                  : _buildMenuOption(context, 'Remove follower', null, () {}),
              firebaseAuth == widget.uid
                  ? _buildMenuOption(
                      context, 'Favorites', Icons.star_outline, () {})
                  : _buildMenuOption(context, 'Copy Profile URL', null, () {}),
              firebaseAuth == widget.uid
                  ? GestureDetector(
                      onTap: () {
                        _showDeleteAccountDialogBox(
                          context,
                          widget.uid,
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.all(6),
                        padding: const EdgeInsets.all(12),
                        child: const Row(
                          children: [
                            Icon(Icons.delete),
                            SizedBox(width: 15),
                            Text('Delete account'),
                          ],
                        ),
                      ),
                    )
                  : Container(),
              firebaseAuth == widget.uid
                  ? Container()
                  : _buildMenuOption(context, 'Show QR code', null, () {}),
              firebaseAuth == widget.uid
                  ? Container()
                  : _buildMenuOption(
                      context, 'Share this profile', null, () {}),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuOption(
    BuildContext context,
    String title,
    IconData? icon,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(6),
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(icon),
              const SizedBox(
                width: 15,
              ),
            ],
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
