import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:instagramzzz/providers/user_provider.dart';
import 'package:instagramzzz/resources/auth_methods.dart';
import 'package:instagramzzz/responsive/mobile_screen_layout.dart';
import 'package:instagramzzz/responsive/responsive_layout_screen.dart';
import 'package:instagramzzz/responsive/web_screen_layout.dart';
import 'package:instagramzzz/screens/auth_screens/login_screen.dart';
import 'package:instagramzzz/utils/colors.dart';
import 'package:provider/provider.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    // Initialize Firebase for Web
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyAzYym1SQNPa0Z7WmT46VFddpXHTbnNckc",
        appId: "1:975393109152:web:e17fd81b305e46e061c5c5",
        //  appId: kIsWeb
        //   ? "1:975393109152:web:e17fd81b305e46e061c5c5"
        //   : "1:975393109152:android:544be423787d1ff661c5c5",
        messagingSenderId: "975393109152",
        projectId: "ig-clone-2c574",
        storageBucket: "ig-clone-2c574.appspot.com",
      ),
    );
  } else {
    // Initialize Firebase for Android/iOS (Ensure it's initialized only once)
    await Firebase.initializeApp();
  }

  runApp(MyApp());
}



// ignore: must_be_immutable
class MyApp extends StatelessWidget {
  MyApp({super.key});

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => UserProvider(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark().copyWith(
          scaffoldBackgroundColor: mobileBackgroundColor,
        ),
        home: isLoading
            ? Center(
                child: LoadingAnimationWidget.flickr(
                  leftDotColor: Colors.red,
                  rightDotColor: Colors.blue,
                  size: 40,
                ),
              )
            : StreamBuilder(
                stream: FirebaseAuth.instance.authStateChanges(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.active) {
                    if (snapshot.hasData) {
                      // Check if user exists in Firestore
                      return FutureBuilder(
                        future: AuthMethods().getUserDetails(),
                        builder: (context, userSnapshot) {
                          if (userSnapshot.connectionState ==
                              ConnectionState.done) {
                            if (userSnapshot.hasData) {
                              // if snapshot has data means user has been authenticated
                              // then shows the responsive layout
                              return ResponsiveLayout(
                                webScreenLayout: WebScreenLayout(
                                  uid: FirebaseAuth.instance.currentUser!.uid,
                                ),
                                mobileScreenLayout: MobileScreenLayout(
                                  uid: FirebaseAuth.instance.currentUser!.uid,
                                ),
                              );
                            }
                          }
                          return const LoginScreen(); // Handle error or no user case
                        },
                      );
                    } else if (snapshot.hasError) {
                      return const Center(
                        child: Text(
                          'Some error occurred.',
                        ),
                      );
                    }
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: primaryColor,
                      ),
                    );
                  }

                  return const LoginScreen();
                },
              ),
      ),
    );
  }
}
