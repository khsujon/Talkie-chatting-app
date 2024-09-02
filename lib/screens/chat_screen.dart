import 'dart:convert';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:talkie/api/apis.dart';
import 'package:talkie/models/chat_user.dart';
import 'package:talkie/widgets/message_card.dart';

import '../main.dart';
import '../models/message.dart';

class ChatScreen extends StatefulWidget {
  final ChatUser user;
  const ChatScreen({super.key, required this.user});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  //for storing all messages
  List<Message> _list = [];

  final _textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          flexibleSpace: _appBar(),
        ),
        backgroundColor: Colors.green.shade100,
        body: Column(children: [
          Expanded(
            child: StreamBuilder(
              stream: APIs.getAllMessages(widget.user),
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  //if data is loading
                  case ConnectionState.waiting:
                  case ConnectionState.none:
                    return Center(
                      child: CircularProgressIndicator(),
                    );

                  //if some or all data is loaded then show
                  case ConnectionState.active:
                  case ConnectionState.done:
                    final data = snapshot.data?.docs;

                    _list =
                        data?.map((e) => Message.fromJson(e.data())).toList() ??
                            [];

                    if (_list.isNotEmpty) {
                      return (ListView.builder(
                          padding: EdgeInsets.only(top: mq.height * .01),
                          physics: BouncingScrollPhysics(),
                          itemCount: _list.length,
                          itemBuilder: (context, index) {
                            return MessageCard(
                              message: _list[index],
                            );
                          }));
                    } else {
                      return Center(
                          child: Text(
                        "Say Hii! 👋",
                        style: TextStyle(
                            fontSize: 20, color: Colors.green.shade600),
                      ));
                    }
                }
              },
            ),
          ),

          //Chat input bar
          _chatInput(),
        ]),
      ),
    );
  }

  Widget _appBar() {
    return InkWell(
      onTap: () {},
      child: Row(
        children: [
          //back button
          IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(
                Icons.arrow_back,
                color: Colors.black54,
              )),

          //user profile picture
          ClipRRect(
            borderRadius: BorderRadius.circular(mq.height * 0.3),
            child: CachedNetworkImage(
              height: mq.height * 0.05,
              width: mq.height * 0.05,
              imageUrl: widget.user.image,
              //placeholder: (context, url) => CircularProgressIndicator(),
              errorWidget: (context, url, error) =>
                  CircleAvatar(child: Icon(CupertinoIcons.person)),
            ),
          ),
          SizedBox(
            width: 12,
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //user name
              Text(
                widget.user.name,
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87),
              ),
              SizedBox(
                height: 2,
              ),

              //last seen status
              Text(
                'Last seen unavailable',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: Colors.black54),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _chatInput() {
    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: mq.height * 0.01, horizontal: mq.width * 0.025),
      child: Row(
        children: [
          Expanded(
            child: Card(
              child: Row(
                children: [
                  //Emoji Button
                  IconButton(
                      onPressed: () {},
                      icon: Icon(Icons.emoji_emotions,
                          color: Colors.blueAccent, size: 26)),

                  //Send message text field
                  Expanded(
                      child: TextField(
                    controller: _textController,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    decoration: InputDecoration(
                        hintText: 'Type your message...',
                        hintStyle: TextStyle(
                            color: Colors.blueAccent.shade100, fontSize: 15),
                        border: InputBorder.none),
                  )),

                  //Image from gallery
                  IconButton(
                      onPressed: () {},
                      icon: Icon(
                        Icons.image,
                        color: Colors.blueAccent,
                        size: 26,
                      )),
                  //Image from Camera
                  IconButton(
                      onPressed: () {},
                      icon: Icon(
                        Icons.camera_alt_rounded,
                        color: Colors.blueAccent,
                        size: 26,
                      )),
                  SizedBox(
                    width: mq.width * 0.02,
                  )
                ],
              ),
            ),
          ),

          //send Button

          MaterialButton(
            onPressed: () {
              if (_textController.text.isNotEmpty) {
                APIs.sendMessage(widget.user, _textController.text);
                _textController.text = "";
              }
            },
            minWidth: 0,
            padding: EdgeInsets.only(top: 10, bottom: 10, right: 5, left: 10),
            shape: CircleBorder(),
            color: Colors.green,
            child: Icon(
              Icons.send,
              color: Colors.white,
              size: 28,
            ),
          )
        ],
      ),
    );
  }
}
