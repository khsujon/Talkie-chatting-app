import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:talkie/api/apis.dart';
import 'package:talkie/models/chat_user.dart';

import '../main.dart';

//profile screen to show user info
class ProfileScreen extends StatefulWidget {
  final ChatUser user;

  const ProfileScreen({super.key, required this.user});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Profile",
          style: TextStyle(color: Colors.black87),
        ),
      ),

      //floating button for add user
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: FloatingActionButton.extended(
          backgroundColor: Colors.redAccent.shade100,
          onPressed: () async {
            await APIs.auth.signOut();
            await GoogleSignIn().signOut();
          },
          icon: Icon(
            Icons.logout,
            color: Colors.red.shade900,
          ),
          label: Text("Logout"),
        ),
      ),

      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: mq.width * .05),
        child: Column(
          children: [
            //for adding space
            SizedBox(width: mq.width, height: mq.height * .03),

            ClipRRect(
              borderRadius: BorderRadius.circular(mq.height * 0.1),
              child: CachedNetworkImage(
                height: mq.height * 0.2,
                width: mq.height * 0.2,
                fit: BoxFit.fill,
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
                color: Colors.black54,
                fontSize: 16,
              ),
            ),

            SizedBox(height: mq.height * .05),

            TextFormField(
              initialValue: widget.user.name,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.person, color: Colors.blue.shade700),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                hintText: "eg. Walter White",
                label: Text("User Name"),
              ),
            ),

            SizedBox(height: mq.height * .02),

            //About section
            TextFormField(
              initialValue: widget.user.about,
              decoration: InputDecoration(
                prefixIcon:
                    Icon(Icons.info_outline, color: Colors.blue.shade700),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                hintText: "eg. Urgent Message Only",
                label: Text("About"),
              ),
            ),

            SizedBox(height: mq.height * .05),
            //update profile button
            ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade100,
                    elevation: 5,
                    shape: StadiumBorder(),
                    minimumSize: Size(mq.width * 0.5, mq.height * 0.06),
                    shadowColor: Colors.greenAccent),
                onPressed: () {},
                icon: Icon(
                  Icons.system_update,
                  color: Colors.green.shade900,
                  size: 27,
                ),
                label: Text(
                  'Update',
                  style: TextStyle(fontSize: 16, color: Colors.green.shade900),
                ))
          ],
        ),
      ),
    );
  }
}
