import 'dart:developer';

// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:talkie/api/apis.dart';
import 'package:talkie/auth/login_screen.dart';
import 'package:talkie/main.dart';
import 'package:talkie/screens/home_screen.dart';
//import 'package:talkie/screens/home_screen.dart';

//splash screen
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 2000), () {
      //exit full screen
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
          systemNavigationBarColor: Colors.white,
          statusBarColor: Colors.white));

      if (APIs.auth.currentUser != null) {
        log('\nUser : ${APIs.auth.currentUser}');
        //Navigate to home Screen
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const HomeScreen()));
      } else {
        //Navigate to home Screen
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const LoginScreen()));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          "Welcome to Talkie",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
      ),
      body: Stack(
        children: [
          Positioned(
              top: mq.height * .15,
              width: mq.width * .5,
              left: mq.width * .25,
              child: Image.asset("images/appIcon.png")),
          Positioned(
            bottom: mq.height * .15,
            width: mq.width * .7,
            left: mq.width * .15,
            height: mq.height * .06,
            child: Text(
              "MADE BY KAMRUL 🇧🇩",
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 16, color: Colors.black87, letterSpacing: .5),
            ),
          )
        ],
      ),
    );
  }
}
