import 'package:flutter/material.dart';
import 'package:talkie/screens/home_screen.dart';

void main() {
  runApp(const MyApp());
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
          iconTheme:
              IconThemeData(color: const Color.fromARGB(255, 10, 81, 139)),
          titleTextStyle: TextStyle(
              color: Colors.greenAccent,
              fontWeight: FontWeight.w700,
              fontSize: 19),
          backgroundColor: Colors.white54,
        )),
        home: HomeScreen());
  }
}
