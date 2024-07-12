import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:talkie/main.dart';

class ChatUserCard extends StatefulWidget {
  const ChatUserCard({super.key});

  @override
  State<ChatUserCard> createState() => _ChatUserCardState();
}

class _ChatUserCardState extends State<ChatUserCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: mq.width * .04, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      //color: Colors.green.shade100,
      elevation: 0.5,
      child: InkWell(
        onTap: () {},
        child: ListTile(
          //User Profile Picture
          leading: CircleAvatar(
              child: Icon(
            CupertinoIcons.person,
          )),

          //User Name
          title: Text("Demo User"),

          //User last message
          subtitle: Text(
            "Last message",
            maxLines: 1,
          ),

          //last message time
          trailing: Text(
            '12:00 PM',
            style: TextStyle(
              color: Colors.black45,
            ),
          ),
        ),
      ),
    );
  }
}
