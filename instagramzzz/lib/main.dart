import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:instagramzzz/providers/user_provider.dart';
import 'package:instagramzzz/responsive/mobile_screen_layout.dart';
import 'package:instagramzzz/responsive/responsive_layout_screen.dart';
import 'package:instagramzzz/responsive/web_screen_layout.dart';
import 'package:instagramzzz/screens/login_screen.dart';
import 'package:instagramzzz/utils/colors.dart';
import 'package:provider/provider.dart';

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
        storageBucket: 'ig-clone-2c574.appspot.com',
      ),
    );
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
        home: StreamBuilder(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.active) {
              if (snapshot.hasData) {
                // if snapshot has data means useer has been authenticated
                // then shhows the responsive layout
                return ResponsiveLayout(
                  webScreenLayout: const WebScreenLayout(),
                  mobileScreenLayout: const MobileScreenLayout(),
                );
              } else if (snapshot.hasError) {
                return const Center(
                  child: Text(
                    'Some error occured.',
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
            // snapshot doesnt have any data means user has not been authenticated
          },
        ),
      ),
    );
  }
}
