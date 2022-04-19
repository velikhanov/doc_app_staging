import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doc_app/api/get_data.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
// import 'package:doc_app/chat/message_model.dart';
// import 'package:doc_app/chat/user_model.dart';

class ChatScreen extends StatefulWidget {
  final String userId;
  final String userEmail;
  const ChatScreen(this.userId, this.userEmail, {Key? key}) : super(key: key);
  
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  _chatBubble(String message, time, bool isMe, bool isSameUser, bool firstMessage) {
    if (isMe) {
      return Column(
        children: <Widget>[
          Container(
            alignment: Alignment.topRight,
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.80,
              ),
              padding: const EdgeInsets.all(10),
              margin: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 5,
                  ),
                ],
              ),
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ),
          !isSameUser || firstMessage
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Text(
                      time,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black45,
                        fontWeight: FontWeight.bold
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Container(
                      decoration: BoxDecoration(
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
                        radius: 15,
                        backgroundImage: AssetImage('assets/images/home_img.png'),
                      ),
                    ),
                  ],
                )
              : Container(
                  child: null,
                ),
        ],
      );
    } else {
      return Column(
        children: <Widget>[
          Container(
            alignment: Alignment.topLeft,
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.80,
              ),
              padding: const EdgeInsets.all(10),
              margin: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 5,
                  ),
                ],
              ),
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.black54,
                ),
              ),
            ),
          ),
          !isSameUser || firstMessage
              ? Row(
                  children: <Widget>[
                    Container(
                      decoration: BoxDecoration(
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
                        radius: 15,
                        backgroundImage: AssetImage('assets/images/home_img.png'),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Text(
                      time,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black45,
                      ),
                    ),
                  ],
                )
              : Container(
                  child: null,
                ),
        ],
      );
    }
  }

  _sendMessageArea() {
    TextEditingController texFieldController = TextEditingController();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      height: 70,
      color: Colors.white,
      child: Row(
        children: <Widget>[
          IconButton(
            icon: const Icon(Icons.photo),
            iconSize: 25,
            color: Theme.of(context).primaryColor,
            onPressed: null,
          ),
           Expanded(
            child: TextField(
              controller: texFieldController,
              decoration: const InputDecoration.collapsed(
                hintText: 'Отправьте сообщение..',
              ),
              textCapitalization: TextCapitalization.sentences,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            iconSize: 25,
            color: Theme.of(context).primaryColor,
            onPressed: () {
              if(texFieldController.text.trim().isNotEmpty){

                FirebaseFirestore.instance.collection('roles').where('uid', isEqualTo: FirebaseAuth.instance.currentUser!.uid).get()
                .then((value){
                  for (var item in value.docs) {
                    if(item.data()['role'] == 'p'){
                      FirebaseFirestore.instance.collection('chats/' + FirebaseAuth.instance.currentUser!.uid + '/' + widget.userId.toString()).get().then((lastDocId){
                        for(var check in lastDocId.docs){
                          if(check.data()['id_message'] > 0){
                            DocumentReference<Map<String, dynamic>> _message = FirebaseFirestore.instance.collection('chats/' + FirebaseAuth.instance.currentUser!.uid + '/' + widget.userId.toString()).doc((lastDocId.size + 1).toString());
                              _message.set({
                                'id_message': lastDocId.size + 1,
                                'message': texFieldController.text.trim(),
                                'sender': FirebaseAuth.instance.currentUser!.uid,
                                'member_1_email': FirebaseAuth.instance.currentUser!.email,
                                // 'member_1': FirebaseAuth.instance.currentUser!.uid,
                                'member_2': widget.userId,
                                'member_2_email': widget.userEmail,
                                'timestamp': DateFormat('yyyy-MM-dd hh:mm').format(DateTime.now()),
                            });
                              // texFieldController.clear();
                          }else{
                            DocumentReference<Map<String, dynamic>> _message = FirebaseFirestore.instance.collection('chats/' + FirebaseAuth.instance.currentUser!.uid + '/' + widget.userId.toString()).doc((lastDocId.size).toString());
                              _message.set({
                                'id_message': lastDocId.size,
                                'message': texFieldController.text.trim(),
                                'sender': FirebaseAuth.instance.currentUser!.uid,
                                'member_1_email': FirebaseAuth.instance.currentUser!.email,
                                // 'member_1': FirebaseAuth.instance.currentUser!.uid,
                                'member_2': widget.userId,
                                'member_2_email': widget.userEmail,
                                'timestamp': DateFormat('yyyy-MM-dd hh:mm').format(DateTime.now()),
                            });
                              // texFieldController.clear();
                          }
                        }
                      }).then((v) => texFieldController.clear());
                    }else if(item.data()['role'] == 'd'){
                      FirebaseFirestore.instance.collection('chats/' + widget.userId.toString() + '/' + FirebaseAuth.instance.currentUser!.uid).get().then((lastDocId){
                        for(var check in lastDocId.docs){
                          if(check.data()['id_message'] > 0){
                            DocumentReference<Map<String, dynamic>> _message = FirebaseFirestore.instance.collection('chats/' + widget.userId.toString() + '/' + FirebaseAuth.instance.currentUser!.uid).doc((lastDocId.size + 1).toString());
                              _message.set({
                                'id_message': lastDocId.size + 1,
                                'message': texFieldController.text.trim(),
                                'sender': FirebaseAuth.instance.currentUser!.uid,
                                'member_1_email': FirebaseAuth.instance.currentUser!.email,
                                // 'member_1': FirebaseAuth.instance.currentUser!.uid,
                                'member_2': widget.userId,
                                'member_2_email': widget.userEmail,
                                'timestamp': DateFormat('yyyy-MM-dd hh:mm').format(DateTime.now()),
                            });
                              // texFieldController.clear();
                          }else{
                            DocumentReference<Map<String, dynamic>> _message = FirebaseFirestore.instance.collection('chats/' +  widget.userId.toString() + '/' + FirebaseAuth.instance.currentUser!.uid).doc((lastDocId.size).toString());
                              _message.set({
                                'id_message': lastDocId.size,
                                'message': texFieldController.text.trim(),
                                'sender': FirebaseAuth.instance.currentUser!.uid,
                                'member_1_email': FirebaseAuth.instance.currentUser!.email,
                                // 'member_1': FirebaseAuth.instance.currentUser!.uid,
                                'member_2': widget.userId,
                                'member_2_email': widget.userEmail,
                                'timestamp': DateFormat('yyyy-MM-dd hh:mm').format(DateTime.now()),
                            });
                              // texFieldController.clear();
                          }
                        }
                      }).then((v) => texFieldController.clear());
                    }
                  }
                });
              }
            },
          ),
        ],
      ),
    );
  }
  
  Stream<QuerySnapshot<Map<String, dynamic>>>? _chatMessages;
  @override
    void initState() {
      super.initState();
      FirebaseFirestore.instance.collection('roles').where('uid', isEqualTo: FirebaseAuth.instance.currentUser!.uid).get()
      .then((value){
        for (var item in value.docs) {
          if(item.data()['role'] == 'p'){
            setState(() {
              _chatMessages = getChatMessages('chats/' + FirebaseAuth.instance.currentUser!.uid + '/' + widget.userId);
            });
          }else if(item.data()['role'] == 'd'){
            setState(() {
              _chatMessages = getChatMessages('chats/' + widget.userId + '/' + FirebaseAuth.instance.currentUser!.uid);
            });
        }
        }
      });
    }
  @override
  Widget build(BuildContext context) {
    String prevUserId;
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: AppBar(
        // brightness: Brightness.dark,
        centerTitle: true,
        title: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            children: [
              TextSpan(
                  text: widget.userEmail,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  )),
              // const TextSpan(text: '\n'),
              // widget.userId.isNotEmpty
              //     ? const TextSpan(
              //         text: 'В сети',
              //         style: TextStyle(
              //           fontSize: 11,
              //           fontWeight: FontWeight.w400,
              //         ),
              //       )
              //     : const TextSpan(
              //         text: 'Не в сети',
              //         style: TextStyle(
              //           fontSize: 11,
              //           fontWeight: FontWeight.w400,
              //         ),
              //       )
            ],
          ),
        ),
        leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            color: Colors.white,
            onPressed: () {
              Navigator.pop(context);
            }),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
                // future: _chatMessages,
                stream: _chatMessages,
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return Column(
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
                    );
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Column(
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
                    );
                  }
                  if (snapshot.hasData){
                    if(snapshot.data!.docs.isNotEmpty && snapshot.data!.docs[0]['id_message'] > 0){
                      return ListView.builder(
                        reverse: true, 
                        padding: const EdgeInsets.all(20),
                        itemCount: snapshot.data!.size,
                        // itemCount: 1,
                        itemBuilder: (BuildContext context, int index) {
                          var _data = snapshot.data!.docs[index];
                          final String message = _data['message'];
                          final time = _data['timestamp'];
                          final bool isMe = _data['sender'] ==
                              FirebaseAuth.instance.currentUser!.uid;
                          // prevUserId = _data['sender'];
                          int prevIndex = index == 0 ? index : index - 1;
                          // bool lastMessage = index == snapshot.data!.docs.length - 1;
                          // int nextIndex = lastMessage ? index : index + 1;
                          prevUserId = snapshot.data!.docs[prevIndex]['sender'];
                          // nextUserId = snapshot.data!.docs[nextIndex]['sender'];
                          bool firstMessage = index == 0;
                          final bool isSameUser = prevUserId == _data['sender'];
                          return _chatBubble(message, time, isMe, isSameUser, firstMessage);
                        });
                    }else{
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const <Widget>[
                          Flexible(
                            child: Text(
                              "Пока что здесь нет сообщений",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      );
                    }
                  } else {
                    return Column(
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
                    );
                  }
                }),
            // child: ListView.builder(
            //   reverse: true,
            //   padding: const EdgeInsets.all(20),
            //   itemCount: messages.length,
            //   itemBuilder: (BuildContext context, int index) {
            //     final Message message = messages[index];
            //     final bool isMe =
            //         message.sender.id.toString() == widget.userId.toString();
            //     prevUserId = message.sender.id;
            //     final bool isSameUser = prevUserId == message.sender.id;
            //     return _chatBubble(message, isMe, isSameUser);
            //   },
            // ),
          ),
          _sendMessageArea(),
        ],
      ),
    );
  }
}
