import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:talkie/api/apis.dart';
import 'package:talkie/main.dart';
import 'package:talkie/models/chat_user.dart';
import 'package:talkie/screens/profile_screen.dart';
import 'package:talkie/widgets/chat_user_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<ChatUser> _list = [];

  final List<ChatUser> _searchList = [];
  bool _isSearched = false;

  @override
  void initState() {
    super.initState();
    APIs.getSelfInfo();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: WillPopScope(
        onWillPop: () {
          if (_isSearched) {
            setState(() {
              _isSearched = !_isSearched;
            });
            return Future.value(false);
          } else {
            return Future.value(true);
          }
        },
        child: Scaffold(
          appBar: AppBar(
            leading: Icon(CupertinoIcons.home),
            title: _isSearched
                ? TextField(
                    decoration: InputDecoration(
                        border: InputBorder.none, hintText: 'Name, Email, ...'),
                    autofocus: true,
                    style: TextStyle(fontSize: 18, letterSpacing: 0.5),

                    //update search list
                    onChanged: (val) {
                      //search logic
                      _searchList.clear();

                      for (var i in _list) {
                        if (i.name.toLowerCase().contains(val.toLowerCase()) ||
                            i.email.toLowerCase().contains(val.toLowerCase())) {
                          _searchList.add(i);
                        }
                        setState(() {
                          _searchList;
                        });
                      }
                    },
                  )
                : Text("Talkie"),
            actions: [
              //search user button
              IconButton(
                  onPressed: () {
                    setState(() {
                      _isSearched = !_isSearched;
                    });
                  },
                  icon: Icon(_isSearched
                      ? CupertinoIcons.clear_circled_solid
                      : Icons.search_sharp)),

              //more feature button
              IconButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => ProfileScreen(user: APIs.me)));
                  },
                  icon: Icon(Icons.more_vert)),
            ],
          ),

          //floating button for add user
          floatingActionButton: Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: FloatingActionButton(
              onPressed: () async {
                await APIs.auth.signOut();
                await GoogleSignIn().signOut();
              },
              child: Icon(Icons.add_comment_rounded),
            ),
          ),

          body: StreamBuilder(
            stream: APIs.getAllUsers(),
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
                      data?.map((e) => ChatUser.fromJson(e.data())).toList() ??
                          [];
                  if (_list.isNotEmpty) {
                    return (ListView.builder(
                        padding: EdgeInsets.only(top: mq.height * .01),
                        physics: BouncingScrollPhysics(),
                        itemCount:
                            _isSearched ? _searchList.length : _list.length,
                        itemBuilder: (context, index) {
                          return ChatUserCard(
                            user:
                                _isSearched ? _searchList[index] : _list[index],
                          );
                          // return Text("Name: ${list[index]}");
                        }));
                  } else {
                    return Center(
                        child: Text(
                      "No Connections Found!",
                      style:
                          TextStyle(fontSize: 20, color: Colors.red.shade600),
                    ));
                  }
              }
            },
          ),
        ),
      ),
    );
  }
}
