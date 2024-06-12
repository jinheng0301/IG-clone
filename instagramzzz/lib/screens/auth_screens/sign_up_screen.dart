import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instagramzzz/resources/auth_methods.dart';
import 'package:instagramzzz/responsive/mobile_screen_layout.dart';
import 'package:instagramzzz/responsive/responsive_layout_screen.dart';
import 'package:instagramzzz/responsive/web_screen_layout.dart';
import 'package:instagramzzz/screens/auth_screens/login_screen.dart';
import 'package:instagramzzz/utils/colors.dart';
import 'package:instagramzzz/utils/utils.dart';
import 'package:instagramzzz/widgets/text_fields.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  Uint8List? _image;
  bool _isLoading = false;

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _bioController.dispose();
    _usernameController.dispose();
  }

  void selectImage() async {
    Uint8List? im = await pickImage(ImageSource.gallery);

    if (im != null) {
      setState(() {
        _image = im;
      });
    } else {
      print("Image selection canceled or failed");
    }
  }

  void signUpUser() async {
    print("Sign Up button clicked");
    setState(() {
      _isLoading = true;
    });

    String res = await AuthMethods().signUpUser(
      email: _emailController.text,
      password: _passwordController.text,
      username: _usernameController.text,
      bio: _bioController.text,
      file: _image!, // image with not null
    );

    setState(() {
      _isLoading = false;
    });

    if (res == 'Success') {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ResponsiveLayout(
            webScreenLayout: WebScreenLayout(
              uid: FirebaseAuth.instance.currentUser!.uid,
            ),
            mobileScreenLayout: MobileScreenLayout(
              uid: FirebaseAuth.instance.currentUser!.uid,
            ),
          ),
        ),
      );
    } else {
      showSnackBar(res, context);
    }
  }

  void navigateToLogIn() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => LoginScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            height: MediaQuery.of(context).size.height,
            // provides a fixed height to the container containing your form,
            // which helps in solving the layout issues when using a SingleChildScrollView.
            padding: EdgeInsets.symmetric(horizontal: 32),
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: 40,
                ),
                SvgPicture.asset(
                  'images/ic_instagram.svg',
                  color: primaryColor,
                  height: 64,
                ),
                SizedBox(
                  height: 30,
                ),
                Stack(
                  children: [
                    _image != null
                        ? CircleAvatar(
                            radius: 64,
                            backgroundImage: MemoryImage(_image!),
                          )
                        : CircleAvatar(
                            radius: 64,
                            backgroundImage: AssetImage(
                              'images/Default_pfp.svg.png',
                            ),
                          ),
                    Positioned(
                      bottom: -10,
                      left: 80,
                      child: IconButton(
                        onPressed: selectImage,
                        icon: Icon(
                          Icons.add_a_photo,
                        ),
                      ),
                    )
                  ],
                ),
                SizedBox(
                  height: 30,
                ),
                TextFieldInput(
                  hintText: 'Enter your username: ',
                  textEditingController: _usernameController,
                  textInputType: TextInputType.text,
                ),
                SizedBox(
                  height: 20,
                ),
                TextFieldInput(
                  hintText: 'Enter your email: ',
                  textEditingController: _emailController,
                  textInputType: TextInputType.emailAddress,
                ),
                SizedBox(
                  height: 20,
                ),
                TextFieldInput(
                  hintText: 'Enter your password: ',
                  textEditingController: _passwordController,
                  textInputType: TextInputType.visiblePassword,
                  isPass: true,
                ),
                SizedBox(
                  height: 20,
                ),
                TextFieldInput(
                  hintText: 'Enter your bio: ',
                  textEditingController: _bioController,
                  textInputType: TextInputType.text,
                ),
                SizedBox(
                  height: 30,
                ),
                InkWell(
                  onTap: signUpUser,
                  child: Container(
                    width: double.infinity,
                    alignment: Alignment.center,
                    padding: EdgeInsets.symmetric(vertical: 12),
                    decoration: ShapeDecoration(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      color: Colors.blue,
                    ),
                    child: _isLoading
                        ? Center(
                            child: CircularProgressIndicator(),
                          )
                        : Text(
                            'Sign Up',
                          ),
                  ),
                ),
                Flexible(
                  child: Container(),
                  flex: 2,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        'Already have an account?',
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    GestureDetector(
                      onTap: navigateToLogIn,
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          'Log In',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
