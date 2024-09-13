import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:talkie/api/apis.dart';
import 'package:talkie/auth/login_screen.dart';
import 'package:talkie/helper/dialogue.dart';
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
  final _formKey = GlobalKey<FormState>();
  String? _image;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      //hide keyboard
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            "Profile",
            style: TextStyle(color: Colors.black87),
          ),
        ),

        //floating button for logout user
        // Floating button for logging out the user
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: FloatingActionButton.extended(
            backgroundColor: Colors.redAccent.shade100,
            onPressed: () async {
              // Show progress dialog
              Dialogs.showProgressBar(context);

              if (APIs.user != null) {
                await APIs.updateActiveStatus(false);

                // Sign out from Firebase and Google
                await APIs.auth.signOut().then((_) async {
                  await GoogleSignIn().signOut().then((_) {
                    // Hide progress bar
                    Navigator.pop(context);

                    // Reset FirebaseAuth instance
                    APIs.auth = FirebaseAuth.instance;

                    // Navigate to the login screen
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => LoginScreen()),
                    );
                  });
                });
              } else {
                // Handle the case where the user is already logged out
                log('User is already logged out');
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => LoginScreen()),
                );
              }
            },
            icon: Icon(
              Icons.logout,
              color: Colors.red.shade900,
            ),
            label: Text("Logout"),
          ),
        ),

        body: Form(
          key: _formKey,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: mq.width * .05),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  //for adding space
                  SizedBox(width: mq.width, height: mq.height * .03),

                  Stack(
                    children: [
                      //profile picture
                      _image != null
                          ? ClipRRect(
                              borderRadius:
                                  BorderRadius.circular(mq.height * 0.1),
                              child: Image.file(
                                File(_image!),
                                height: mq.height * 0.2,
                                width: mq.height * 0.2,
                                fit: BoxFit.cover,
                              ))
                          : ClipRRect(
                              borderRadius:
                                  BorderRadius.circular(mq.height * 0.1),
                              child: CachedNetworkImage(
                                height: mq.height * 0.2,
                                width: mq.height * 0.2,
                                fit: BoxFit.cover,
                                imageUrl: widget.user.image,
                                //placeholder: (context, url) => CircularProgressIndicator(),
                                errorWidget: (context, url, error) =>
                                    CircleAvatar(
                                        child: Icon(CupertinoIcons.person)),
                              ),
                            ),

                      //Edit image Button
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: MaterialButton(
                          elevation: 1,
                          onPressed: () {
                            _showBottomSheet();
                          },
                          shape: CircleBorder(),
                          color: Colors.white,
                          child: Icon(
                            Icons.edit,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    ],
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
                    onSaved: (val) => APIs.me.name = val ?? '',
                    validator: (val) =>
                        val != null && val.isNotEmpty ? null : 'Required Field',
                    decoration: InputDecoration(
                      prefixIcon:
                          Icon(Icons.person, color: Colors.blue.shade700),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      hintText: "eg. Walter White",
                      label: Text("User Name"),
                    ),
                  ),

                  SizedBox(height: mq.height * .02),

                  //About section
                  TextFormField(
                    initialValue: widget.user.about,
                    onSaved: (val) => APIs.me.about = val ?? '',
                    validator: (val) =>
                        val != null && val.isNotEmpty ? null : 'Required Field',
                    decoration: InputDecoration(
                      prefixIcon:
                          Icon(Icons.info_outline, color: Colors.blue.shade700),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
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
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();
                          APIs.updateUserInfo().then((value) {
                            Dialogs.showsnackbar(
                                context, 'Profile Updated Successfully');
                          });
                        }
                      },
                      icon: Icon(
                        Icons.system_update,
                        color: Colors.green.shade900,
                        size: 27,
                      ),
                      label: Text(
                        'Update',
                        style: TextStyle(
                            fontSize: 16, color: Colors.green.shade900),
                      ))
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

//bottom sheet for picking profile image
  void _showBottomSheet() {
    showModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20))),
        builder: (_) {
          return ListView(
            shrinkWrap: true,
            padding:
                EdgeInsets.only(top: mq.height * .03, bottom: mq.height * 0.05),
            children: [
              Text(
                'Select Profile Picture',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.green.shade800),
              ),
              SizedBox(
                height: mq.height * 0.03,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade100,
                          shape: CircleBorder(),
                          fixedSize: Size(mq.width * 0.3, mq.height * 0.15)),
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();
                        // Pick an image.
                        final XFile? image = await picker.pickImage(
                            source: ImageSource.gallery, imageQuality: 80);

                        if (image != null) {
                          setState(() {
                            _image = image.path;
                          });

                          APIs.updateProfilePicture(File(_image!));

                          Navigator.pop(context);
                        }
                      },
                      child: Image.asset('images/add_img.png')),
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade100,
                          shape: CircleBorder(),
                          fixedSize: Size(mq.width * 0.3, mq.height * 0.15)),
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();
                        // Pick an image.
                        final XFile? image =
                            await picker.pickImage(source: ImageSource.camera);

                        if (image != null) {
                          setState(() {
                            _image = image.path;
                          });
                          APIs.updateProfilePicture(File(_image!));

                          Navigator.pop(context);
                        }
                      },
                      child: Image.asset('images/camera.png'))
                ],
              )
            ],
          );
        });
  }
}
