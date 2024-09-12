import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:talkie/api/apis.dart';
import 'package:talkie/helper/my_date_util.dart';
import 'package:talkie/main.dart';
import 'package:talkie/models/message.dart';

import '../models/chat_user.dart';
import '../screens/chat_screen.dart';

class ChatUserCard extends StatefulWidget {
  final ChatUser user;

  const ChatUserCard({super.key, required this.user});

  @override
  State<ChatUserCard> createState() => _ChatUserCardState();
}

class _ChatUserCardState extends State<ChatUserCard> {
  Message? _message;
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: mq.width * .04, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      //color: Colors.green.shade100,
      elevation: 0.5,
      child: InkWell(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => ChatScreen(
                          user: widget.user,
                        )));
          },
          child: StreamBuilder(
            stream: APIs.getLastMessages(widget.user),
            builder: (context, snapshot) {
              final data = snapshot.data?.docs;
              final list =
                  data?.map((e) => Message.fromJson(e.data())).toList() ?? [];

              if (list.isNotEmpty) {
                _message = list[0];
              }

              return ListTile(
                //User Profile Picture
                //leading: CircleAvatar(child: Icon(CupertinoIcons.person)),
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(mq.height * 0.3),
                  child: CachedNetworkImage(
                    height: mq.height * 0.055,
                    width: mq.height * 0.055,
                    imageUrl: widget.user.image,
                    //placeholder: (context, url) => CircularProgressIndicator(),
                    errorWidget: (context, url, error) =>
                        CircleAvatar(child: Icon(CupertinoIcons.person)),
                  ),
                ),

                //User Name
                title: Text(widget.user.name),

                //User last message
                subtitle: Text(
                    _message != null
                        ? _message!.type == Type.image
                            ? 'Image'
                            : _message!.msg
                        : widget.user.about,
                    maxLines: 1),

                //last message time
                // trailing: Text(
                //   '12:00 PM',
                //   style: TextStyle(
                //     color: Colors.black45,
                //   ),
                trailing: _message == null
                    ? null //show nothing when no message is sent
                    : _message!.read.isEmpty &&
                            _message!.fromId != APIs.user.uid

                        //show for unread message
                        ? Container(
                            height: 10,
                            width: 10,
                            decoration: BoxDecoration(
                                color: Colors.green.shade600,
                                borderRadius: BorderRadius.circular(7)),
                          )

                        //message sent time
                        : Text(
                            MyDateUtil.getLastMessageTime(
                                context: context, time: _message!.sent),
                            style: TextStyle(color: Colors.black54),
                          ),
              );
            },
          )),
    );
  }
}
