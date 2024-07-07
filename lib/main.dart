import 'package:flutter/material.dart';
//import 'package:talkie/auth/login_screen.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:talkie/screens/splash_screen.dart';
import 'firebase_options.dart';
//import 'package:talkie/screens/home_screen.dart';

//global object for accessing device screen size
late Size mq;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  //enter full screen
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  //for setting orientation portrait only
  SystemChrome.setPreferredOrientations(
          [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown])
      .then((value) {
    _initializeFirebase();
    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Talkie',
        theme: ThemeData(
            appBarTheme: AppBarTheme(
          centerTitle: true,
          elevation: 3,
          iconTheme: IconThemeData(color: Color.fromARGB(255, 48, 148, 230)),
          titleTextStyle: TextStyle(
              color: Colors.greenAccent,
              fontWeight: FontWeight.w700,
              fontSize: 19),
          backgroundColor: Colors.white54,
        )),
        home: SplashScreen());
  }
}

_initializeFirebase() async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}
