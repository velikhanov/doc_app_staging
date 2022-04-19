import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doc_app/api/get_data.dart';
import 'package:doc_app/pages/chat_screen.dart';
import 'package:doc_app/pages/home_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:doc_app/chat/message_model.dart';

class ChatsPage extends StatelessWidget {
  const ChatsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var _chats = getChats('all_chats', FirebaseAuth.instance.currentUser!.uid);

    return
        // Container(
        //   color: Colors.white,
        //   child: DefaultTextStyle(
        //     style: const TextStyle(
        //         color: Colors.black, decoration: TextDecoration.none),
        //     child:
        Scaffold(
      // backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 8,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          color: Colors.white,
          onPressed: () => Navigator.pop(context),
          // () => Navigator.push(
          //   context,
          //   MaterialPageRoute(
          //     builder: (_) => const HomePage(),
          //   ),
          // ),
        ),
        title: const Text(
          'Все чаты',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        // actions: <Widget>[
        //   IconButton(
        //     icon: const Icon(Icons.search),
        //     color: Colors.white,
        //     onPressed: () {},
        //   ),
        // ],
      ),
      body: FutureBuilder(
          // future: _chatMessages,
          future: _chats,
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Flexible(
                      child: Text(
                        "Ошибка загрузки данных.\nПожалуйста, повторите попытку позже: ${snapshot.error.toString()}",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              );
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const <Widget>[
                    Flexible(
                      child: Text(
                        "Загрузка данных, пожалуйста, подождите..",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              );
            }
            if (snapshot.hasData) {
              if (snapshot.data.length > 0 &&
                  snapshot.data[0]['id_message'] > 0) {
                return ListView.builder(
                  itemCount: snapshot.data.length,
                  itemBuilder: (BuildContext context, int index) {
                    // final Message chat = chats[index];
                    var chat = snapshot.data[index];
                    return GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatScreen(
                              chat['member_2'] ==
                                      FirebaseAuth.instance.currentUser!.uid
                                  ? chat['sender']
                                  : chat['member_2'],
                              chat['member_2'] ==
                                      FirebaseAuth.instance.currentUser!.uid
                                  ? chat['member_1_email']
                                  : chat['member_2_email']),
                        ),
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 15,
                        ),
                        child: Row(
                          children: <Widget>[
                            Container(
                              padding: const EdgeInsets.all(2),
                              decoration: chat == null
                                  ? BoxDecoration(
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(40)),
                                      border: Border.all(
                                        width: 2,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                      // shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.5),
                                          spreadRadius: 2,
                                          blurRadius: 5,
                                        ),
                                      ],
                                    )
                                  : BoxDecoration(
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.5),
                                          spreadRadius: 2,
                                          blurRadius: 5,
                                        ),
                                      ],
                                    ),
                              child: const CircleAvatar(
                                radius: 30,
                                // backgroundImage: AssetImage(chat.sender.imageUrl),
                                backgroundImage:
                                    AssetImage('assets/images/home_img.png'),
                              ),
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width * 0.725,
                              padding: const EdgeInsets.only(
                                left: 20,
                              ),
                              child: Column(
                                children: <Widget>[
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Row(
                                        children: <Widget>[
                                          Text(
                                            chat['member_2_email'] ==
                                                    FirebaseAuth.instance
                                                        .currentUser!.email
                                                ? chat['member_1_email']
                                                : chat['member_2_email'],
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          chat == null
                                              ? Container(
                                                  margin: const EdgeInsets.only(
                                                      left: 5),
                                                  width: 7,
                                                  height: 7,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: Theme.of(context)
                                                        .primaryColor,
                                                  ),
                                                )
                                              : Container(
                                                  child: null,
                                                ),
                                        ],
                                      ),
                                      Text(
                                        chat['timestamp'],
                                        style: const TextStyle(
                                          fontSize: 11,
                                          // fontWeight: FontWeight.w300,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black54,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Container(
                                    alignment: Alignment.topLeft,
                                    child: Text(
                                      chat['message'],
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black54,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 2,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  const Divider(
                                    thickness: 2.5,
                                    color: Color.fromARGB(255, 102, 100, 119),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              } else {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: const <Widget>[
                      Flexible(
                        child: Text(
                          "Пока что здесь нет чатов",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                );
              }
            } else {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const <Widget>[
                    Flexible(
                      child: Text(
                        "Ошибка загрузки данных.\nПожалуйста, повторите попытку позже",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              );
            }
          }),
    );
  }
}
