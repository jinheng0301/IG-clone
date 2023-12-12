import 'package:flutter/foundation.dart';
import 'package:instagramzzz/models/user.dart';
import 'package:instagramzzz/resources/auth_methods.dart';

class UserProvider with ChangeNotifier {
  final AuthMethods _authMethods = AuthMethods();
  User? _user;

  User get getUser =>
      _user ??
      User(
        email: '',
        uid: '',
        photoUrl: '',
        username: '',
        bio: '',
        followers: 0,
        following: 0,
      );

  //return to user without null

  Future<void> refreshUser() async {
    User user = await _authMethods.getUserDetails();
    _user = user;
    notifyListeners();
  }
}
