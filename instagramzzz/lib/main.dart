import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:instagramzzz/responsive/mobile_screen_layout.dart';
import 'package:instagramzzz/responsive/responsive_layout_screen.dart';
import 'package:instagramzzz/responsive/web_screen_layout.dart';
import 'package:instagramzzz/screens/login_screen.dart';
import 'package:instagramzzz/screens/sign_up_screen.dart';
import 'package:instagramzzz/utils/colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyAzYym1SQNPa0Z7WmT46VFddpXHTbnNckc",
        appId: "1:975393109152:web:e17fd81b305e46e061c5c5",
        messagingSenderId: "975393109152",
        projectId: "975393109152",
        storageBucket: "ig-clone-2c574.appspot.com",
      ),
    );
  } else {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: 'AIzaSyAzYym1SQNPa0Z7WmT46VFddpXHTbnNckc',
        appId: '1:975393109152:android:544be423787d1ff661c5c5',
        messagingSenderId: '975393109152',
        projectId: 'ig-clone-2c574',
      ),
    );
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: mobileBackgroundColor,
      ),
      // home: ResponsiveLayout(
      //   webScreenLayout: WebScreenLayout(),
      //   mobileScreenLayout: MobileScreenLayout(),
      // ),
      home: SignUpScreen(),
    );
  }
}
