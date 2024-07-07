import 'package:flutter/material.dart';
import 'package:talkie/main.dart';
import 'package:talkie/screens/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isAnimate = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 500), () {
      setState(() {
        _isAnimate = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    //mq = MediaQuery.of(context).size;

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
          AnimatedPositioned(
              top: mq.height * .15,
              width: mq.width * .5,
              left: _isAnimate ? mq.width * .25 : -mq.width * .5,
              duration: Duration(seconds: 1),
              child: Image.asset("images/appIcon.png")),
          Positioned(
              bottom: mq.height * .15,
              width: mq.width * .7,
              left: mq.width * .15,
              height: mq.height * .06,
              child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 223, 255, 187),
                    shape: StadiumBorder(),
                    elevation: 1,
                  ),
                  onPressed: () {
                    Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (_) => HomeScreen()));
                  },
                  icon: Image.asset(
                    "images/google.png",
                    height: mq.height * .03,
                  ),
                  label: Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: RichText(
                        text: TextSpan(
                            style: TextStyle(color: Colors.black, fontSize: 16),
                            children: [
                          TextSpan(text: 'Login with '),
                          TextSpan(
                              text: "Google",
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                              ))
                        ])),
                  ))),
        ],
      ),
    );
  }
}
