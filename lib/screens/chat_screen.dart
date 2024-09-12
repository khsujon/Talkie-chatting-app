import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart'; // <-- Import emoji picker package
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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

  //for handling message text changes
  final _textController = TextEditingController();

  //for emoji handling and image upload check
  bool _showEmoji = false, _isUploading = false;

  // Define a focus node to control when the text field has focus
  final FocusNode _focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: SafeArea(
        child: WillPopScope(
          onWillPop: () {
            if (_showEmoji) {
              setState(() {
                _showEmoji = !_showEmoji;
              });
              return Future.value(false);
            } else {
              return Future.value(true);
            }
          },
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

                        _list = data
                                ?.map((e) => Message.fromJson(e.data()))
                                .toList() ??
                            [];

                        if (_list.isNotEmpty) {
                          return (ListView.builder(
                              reverse: true,
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

              //Progress indicator for showing image uploading
              if (_isUploading)
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.blue,
                    ),
                  ),
                ),
              // Chat input bar
              _chatInput(),

              // Start of edited code: Display the emoji picker when _showEmoji is true
              if (_showEmoji)
                SizedBox(
                  height: mq.height * 0.35,
                  child: EmojiPicker(
                    onEmojiSelected: (category, emoji) {
                      _textController.text += emoji.emoji;
                    },
                    onBackspacePressed: () {
                      _textController.text = _textController.text.characters
                          .skipLast(1)
                          .toString();
                    },
                    config: Config(
                      columns: 7,
                      emojiSizeMax: 32 * (Platform.isIOS ? 1.30 : 1.0),
                      verticalSpacing: 0,
                      horizontalSpacing: 0,
                      initCategory: Category.RECENT,
                      bgColor: Color.fromARGB(255, 152, 202, 147),
                      indicatorColor: Colors.blue,
                      iconColor: Colors.grey,
                      iconColorSelected: Colors.blue,
                      backspaceColor: Colors.blue,
                      skinToneDialogBgColor: Colors.white,
                      skinToneIndicatorColor: Colors.grey,
                      enableSkinTones: true,
                      recentTabBehavior: RecentTabBehavior.RECENT,
                      recentsLimit: 28,
                      noRecents: const Text(
                        'No Recents',
                        style: TextStyle(fontSize: 20, color: Colors.black26),
                        textAlign: TextAlign.center,
                      ),
                      loadingIndicator: const SizedBox.shrink(),
                      tabIndicatorAnimDuration: kTabScrollDuration,
                      categoryIcons: const CategoryIcons(),
                      buttonMode: ButtonMode.MATERIAL,
                    ),
                  ),
                ),
              // End of edited code
            ]),
          ),
        ),
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
                  // Emoji Button
                  IconButton(
                      onPressed: () {
                        setState(() {
                          // Start of edited code: Toggle emoji keyboard visibility
                          _showEmoji = !_showEmoji;
                          if (_showEmoji) {
                            // If emoji picker is shown, unfocus the text field
                            _focusNode.unfocus();
                          } else {
                            // If emoji picker is hidden, focus the text field
                            _focusNode.requestFocus();
                          }
                          // End of edited code
                        });
                      },
                      icon: Icon(Icons.emoji_emotions,
                          color: Colors.blueAccent, size: 26)),

                  // Send message text field
                  Expanded(
                      child: TextField(
                    controller: _textController,
                    focusNode:
                        _focusNode, // <-- Edited code: Attach the focus node
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    onTap: () {
                      // Start of edited code: Hide emoji picker when the text field is tapped
                      if (_showEmoji) {
                        setState(() {
                          _showEmoji = false;
                        });
                      }
                      // End of edited code
                    },
                    decoration: InputDecoration(
                        hintText: 'Type your message...',
                        hintStyle: TextStyle(
                            color: Colors.blueAccent.shade100, fontSize: 15),
                        border: InputBorder.none),
                  )),

                  // Image from gallery
                  IconButton(
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();
                        // Pick multiple images image.
                        final List<XFile> images =
                            await picker.pickMultiImage(imageQuality: 70);

                        for (var i in images) {
                          setState(() {
                            _isUploading = true;
                          });
                          await APIs.sendChatImage(widget.user, File(i.path));
                          setState(() {
                            _isUploading = false;
                          });
                        }
                      },
                      icon: Icon(
                        Icons.image,
                        color: Colors.blueAccent,
                        size: 26,
                      )),
                  // Image from Camera
                  IconButton(
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();
                        // Pick an image.
                        final XFile? image = await picker.pickImage(
                            source: ImageSource.camera, imageQuality: 70);

                        if (image != null)
                          await APIs.sendChatImage(
                              widget.user, File(image.path));
                      },
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

          // Send Button
          MaterialButton(
            onPressed: () {
              if (_textController.text.isNotEmpty) {
                APIs.sendMessage(widget.user, _textController.text, Type.text);
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
