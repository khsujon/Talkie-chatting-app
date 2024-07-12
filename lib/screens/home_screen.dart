import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:talkie/main.dart';
import 'package:talkie/widgets/chat_user_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Icon(CupertinoIcons.home),
        title: const Text("Talkie"),
        actions: [
          //search user button
          IconButton(onPressed: () {}, icon: Icon(Icons.search_sharp)),

          //more feature button
          IconButton(onPressed: () {}, icon: Icon(Icons.more_vert)),
        ],
      ),

      //floating button for add user
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: FloatingActionButton(
          onPressed: () {},
          child: Icon(Icons.add_comment_rounded),
        ),
      ),

      body: ListView.builder(
          padding: EdgeInsets.only(top: mq.height * .01),
          physics: BouncingScrollPhysics(),
          itemCount: 18,
          itemBuilder: ((context, index) {
            return ChatUserCard();
          })),
    );
  }
}
