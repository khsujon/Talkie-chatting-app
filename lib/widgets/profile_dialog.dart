import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:talkie/main.dart';
import 'package:talkie/models/chat_user.dart';
import 'package:talkie/screens/view_profile_screen.dart';

class ProfileDialog extends StatelessWidget {
  const ProfileDialog({super.key, required this.user});
  final ChatUser user;
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: EdgeInsets.all(mq.height * 0.02),
      backgroundColor: Colors.lightGreen.shade100.withOpacity(0.8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      content: SizedBox(
        height: mq.height * 0.35,
        width: mq.width * 0.6,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                    width: mq.width * 0.55,
                    child: Text(
                      user.name,
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                    )),
                InkWell(
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ViewProfileScreen(user: user),
                          ));
                    },
                    child: Icon(Icons.info_rounded)),
              ],
            ),
            SizedBox(
              height: mq.height * 0.04,
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(mq.height * 0.25),
              child: CachedNetworkImage(
                width: mq.width * 0.5,
                height: mq.height * 0.22,
                fit: BoxFit.cover,
                imageUrl: user.image,
                //placeholder: (context, url) => CircularProgressIndicator(),
                errorWidget: (context, url, error) =>
                    CircleAvatar(child: Icon(CupertinoIcons.person)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
