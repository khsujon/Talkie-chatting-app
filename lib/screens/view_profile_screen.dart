import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:talkie/helper/my_date_util.dart';
import 'package:talkie/models/chat_user.dart';

import '../main.dart';

//profile screen to view chat user profile info
class ViewProfileScreen extends StatefulWidget {
  final ChatUser user;

  const ViewProfileScreen({super.key, required this.user});

  @override
  State<ViewProfileScreen> createState() => _ViewProfileScreenState();
}

class _ViewProfileScreenState extends State<ViewProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      //hide keyboard
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.user.name,
            style: TextStyle(color: Colors.black87),
          ),
        ),
        floatingActionButton: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Joined On: ',
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 16,
                )),
            Text(
              MyDateUtil.getLastMessageTime(
                  context: context,
                  time: widget.user.createdAt,
                  showYear: true),
              style: TextStyle(
                color: Colors.black54,
                fontSize: 16,
              ),
            ),
          ],
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: mq.width * .05),
          child: SingleChildScrollView(
            child: Column(
              children: [
                //for adding space
                SizedBox(width: mq.width, height: mq.height * .03),

                ClipRRect(
                  borderRadius: BorderRadius.circular(mq.height * 0.1),
                  child: CachedNetworkImage(
                    height: mq.height * 0.2,
                    width: mq.height * 0.2,
                    fit: BoxFit.cover,
                    imageUrl: widget.user.image,
                    //placeholder: (context, url) => CircularProgressIndicator(),
                    errorWidget: (context, url, error) =>
                        CircleAvatar(child: Icon(CupertinoIcons.person)),
                  ),
                ),

                SizedBox(height: mq.height * .03),

                Text(
                  widget.user.email,
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 16,
                  ),
                ),

                SizedBox(height: mq.height * .02),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('About: ',
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 16,
                        )),
                    Text(
                      widget.user.about,
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
