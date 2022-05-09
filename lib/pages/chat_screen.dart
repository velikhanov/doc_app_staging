import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doc_app/api/get_data.dart';
import 'package:doc_app/api/storage_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class ChatScreen extends StatefulWidget {
  final String userId;
  final String userEmail;
  const ChatScreen(this.userId, this.userEmail, {Key? key}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  String? path;
  String? fileName;
  Storage storage = Storage();
  TextEditingController texFieldController = TextEditingController();

  Future _showAttachment(String _url, bool isImg) async {
    return await showGeneralDialog(
        context: context,
        barrierDismissible: true,
        barrierLabel:
            MaterialLocalizations.of(context).modalBarrierDismissLabel,
        barrierColor: Colors.black45,
        transitionDuration: const Duration(milliseconds: 200),
        pageBuilder: (BuildContext buildContext, Animation animation,
            Animation secondaryAnimation) {
          if (isImg == true) {
            return SafeArea(
              child: Material(
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(_url),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: IconButton(
                      onPressed: (() => Navigator.pop(buildContext)),
                      icon: const Icon(
                        Icons.arrow_back_ios,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            );
          } else {
            return SafeArea(
              child: Material(
                child: Stack(
                  children: [
                    SfPdfViewer.network(_url),
                    Align(
                      alignment: Alignment.topLeft,
                      child: IconButton(
                        onPressed: (() => Navigator.pop(buildContext)),
                        icon: const Icon(
                          Icons.arrow_back_ios,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
        });
  }

  _chatBubble(String message, attachment, String attachmentName, time, bool isMe, bool isSameUser,
      bool firstMessage, bool isImg, bool isDocument) {
    if (isMe) {
      return Column(
        children: <Widget>[
          Container(
            alignment: Alignment.topRight,
            child: isImg == true || isDocument == true
                ? FutureBuilder(
                    future: attachment,
                    builder: (BuildContext context, AsyncSnapshot snapshot) {
                      if (snapshot.hasError) {
                        return const SizedBox(
                          height: 90,
                          width: 90,
                          child: Center(
                            child: Text(
                              "Ошибка загрузки..",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        );
                      }

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const SizedBox(
                          height: 90,
                          width: 90,
                          child: Center(
                            child: Text(
                              "Загрузка данных..",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        );
                      }
                      if (snapshot.hasData) {
                        var _data = snapshot.data;
                        return Column(
                          children: [
                            const SizedBox(
                              height: 2.5,
                            ),
                            isImg == true && isDocument == false
                                ? Padding(
                                  padding: const EdgeInsets.only(right: 15),
                                  child: Container(
                                    height: 90,
                                    // width: 90,
                                    decoration: BoxDecoration(
                                      color: Colors.transparent,
                                      image: DecorationImage(
                                          image: NetworkImage(_data),
                                          fit: BoxFit.cover),
                                    ),
                                    child: TextButton(
                                      onPressed: (() =>
                                          _showAttachment(_data, true)),
                                      child: const SizedBox(),
                                    ),
                                  ),
                                )
                                : isImg == false && isDocument == true
                                    ? SizedBox(
                                        height: 110,
                                        // width: 120,
                                        child: 
                                            TextButton(
                                              onPressed: (() =>
                                                  _showAttachment(_data, false)),
                                              // icon: const Icon(
                                              //   Icons.picture_as_pdf,
                                              //   color: Colors.black,
                                              //   size: 90,
                                              // ),
                                              child: 
                                                Column(
                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Image.asset(
                                                        'assets/images/pdf.png',
                                                        width: 65,
                                                        height: 65,
                                                      ),
                                                    const SizedBox(height: 5),
                                                    Text(attachmentName.toString().length > 15 ? attachmentName.substring(0, 15) : attachmentName, style: const TextStyle(fontSize: 15  , fontWeight: FontWeight.bold, color: Colors.grey)),
                                                  ],
                                                ),
                                      ))
                                    : const SizedBox(),
                            const SizedBox(
                              height: 2.5,
                            )
                          ],
                        );
                      } else {
                        return const SizedBox(
                          height: 90,
                          width: 90,
                          child: Center(
                            child: Text(
                              "Ошибка загрузки..",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        );
                      }
                    })
                : Container(
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
              ? Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Text(
                        time,
                        style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black45,
                            fontWeight: FontWeight.bold),
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
                          backgroundImage:
                              AssetImage('assets/images/home_img.png'),
                        ),
                      ),
                    ],
                  ),
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
            child: isImg == true || isDocument == true
                ? FutureBuilder(
                    future: attachment,
                    builder: (BuildContext context, AsyncSnapshot snapshot) {
                      if (snapshot.hasError) {
                        return const SizedBox(
                          height: 90,
                          width: 90,
                          child: Center(
                            child: Text(
                              "Ошибка загрузки..",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        );
                      }

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const SizedBox(
                          height: 90,
                          width: 90,
                          child: Center(
                            child: Text(
                              "Загрузка данных..",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        );
                      }
                      if (snapshot.hasData) {
                        var _data = snapshot.data;
                        return Column(
                          children: [
                            const SizedBox(
                              height: 2.5,
                            ),
                            isImg == true && isDocument == false
                                ? Padding(
                                    padding: const EdgeInsets.only(left: 15),
                                    child: Container(
                                      height: 90,
                                      // width: 90,
                                      decoration: BoxDecoration(
                                        color: Colors.transparent,
                                        image: DecorationImage(
                                            image: NetworkImage(_data),
                                            fit: BoxFit.cover),
                                      ),
                                      child: TextButton(
                                        onPressed: (() =>
                                            _showAttachment(_data, true)),
                                        child: const SizedBox(),
                                      ),
                                    ),
                                  )
                                : isImg == false && isDocument == true
                                    ? SizedBox(
                                        height: 110,
                                        // width: 120,
                                        child: 
                                            TextButton(
                                              onPressed: (() =>
                                                  _showAttachment(_data, false)),
                                              // icon: const Icon(
                                              //   Icons.picture_as_pdf,
                                              //   color: Colors.black,
                                              //   size: 90,
                                              // ),
                                              child: 
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Image.asset(
                                                'assets/images/pdf.png',
                                                width: 65,
                                                height: 65,
                                              ),
                                            const SizedBox(height: 5),
                                            Text(attachmentName.toString().length > 15 ? attachmentName.substring(0, 15) : attachmentName, style: const TextStyle(fontSize: 15  , fontWeight: FontWeight.bold, color: Colors.grey)),
                                          ],
                                        ),
                                        // IconButton(
                                        //   onPressed: (() =>
                                        //       _showAttachment(_data, false)),
                                        //   icon: const Icon(
                                        //     Icons.picture_as_pdf,
                                        //     color: Colors.black,
                                        //     size: 90,
                                        //   ),
                                        // ),
                                      ))
                                    : const SizedBox(),
                            const SizedBox(
                              height: 2.5,
                            )
                          ],
                        );
                      } else {
                        return const SizedBox(
                          height: 90,
                          width: 90,
                          child: Center(
                            child: Text(
                              "Ошибка загрузки..",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        );
                      }
                    })
                : Container(
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
                ? Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Row(
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
                          backgroundImage:
                              AssetImage('assets/images/home_img.png'),
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
                  ),
                )
              : Container(
                  child: null,
                ),
        ],
      );
    }
  }

  _sendMessageArea() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      height: 70,
      color: Colors.white,
      child: Row(
        children: <Widget>[
          IconButton(
            icon: const Icon(Icons.attach_file),
            iconSize: 25,
            color: Theme.of(context).primaryColor,
            onPressed: () async {
              await FilePicker.platform.pickFiles(
                allowMultiple: false,
                type: FileType.custom,
                allowedExtensions: ['png', 'jpg', 'pdf'],
              ).then((value) {
                if (value == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Ни один файл не был выбран'),
                    ),
                  );
                } else {
                  setState(() {
                    path = value.files.single.path!;
                    fileName = value.files.single.name;
                    texFieldController =
                        TextEditingController(text: value.files.single.name);
                  });
                }
              });
            },
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
              if (texFieldController.text.trim().isNotEmpty) {
                FirebaseFirestore.instance
                    .collection('roles')
                    .where('uid',
                        isEqualTo: FirebaseAuth.instance.currentUser!.uid)
                    .get()
                    .then((value) {
                  for (var item in value.docs) {
                    if (item.data()['role'] == 'p') {
                      FirebaseFirestore.instance
                          .collection('chats/' +
                              FirebaseAuth.instance.currentUser!.uid +
                              '/' +
                              widget.userId.toString())
                          .get()
                          .then((lastDocId) {
                        for (var check in lastDocId.docs) {
                          String attachment = '';
                          path != null && fileName != null
                              ? attachment = fileName!
                              : attachment;
                          if (check.data()['id_message'] > 0) {
                            DocumentReference<Map<String, dynamic>> _message =
                                FirebaseFirestore.instance
                                    .collection('chats/' +
                                        FirebaseAuth.instance.currentUser!.uid +
                                        '/' +
                                        widget.userId.toString())
                                    .doc((lastDocId.size + 1).toString());
                            _message.set({
                              'id_message': lastDocId.size + 1,
                              'message': path != null && fileName != null
                                  ? ''
                                  : texFieldController.text.trim(),
                              'attachment': attachment,
                              'sender': FirebaseAuth.instance.currentUser!.uid,
                              'member_1_email':
                                  FirebaseAuth.instance.currentUser!.email,
                              'member_2': widget.userId,
                              'member_2_email': widget.userEmail,
                              'timestamp': DateFormat('yyyy-MM-dd hh:mm')
                                  .format(DateTime.now()),
                            });
                            if (path != null && fileName != null) {
                              if (isDoc == true) {
                                storage.uploadFile(
                                    path!,
                                    widget.userId +
                                        '/' +
                                        FirebaseAuth.instance.currentUser!.uid +
                                        '/' +
                                        fileName!);
                              } else {
                                storage.uploadFile(
                                    path!,
                                    FirebaseAuth.instance.currentUser!.uid +
                                        '/' +
                                        widget.userId +
                                        '/' +
                                        fileName!);
                              }
                            }
                          } else {
                            DocumentReference<Map<String, dynamic>> _message =
                                FirebaseFirestore.instance
                                    .collection('chats/' +
                                        FirebaseAuth.instance.currentUser!.uid +
                                        '/' +
                                        widget.userId.toString())
                                    .doc((lastDocId.size).toString());
                            _message.set({
                              'id_message': lastDocId.size,
                              'message': path != null && fileName != null
                                  ? ''
                                  : texFieldController.text.trim(),
                              'attachment': attachment,
                              'sender': FirebaseAuth.instance.currentUser!.uid,
                              'member_1_email':
                                  FirebaseAuth.instance.currentUser!.email,
                              'member_2': widget.userId,
                              'member_2_email': widget.userEmail,
                              'timestamp': DateFormat('yyyy-MM-dd hh:mm')
                                  .format(DateTime.now()),
                            });
                            if (path != null && fileName != null) {
                              if (isDoc == true) {
                                storage.uploadFile(
                                    path!,
                                    widget.userId +
                                        '/' +
                                        FirebaseAuth.instance.currentUser!.uid +
                                        '/' +
                                        fileName!);
                              } else {
                                storage.uploadFile(
                                    path!,
                                    FirebaseAuth.instance.currentUser!.uid +
                                        '/' +
                                        widget.userId +
                                        '/' +
                                        fileName!);
                              }
                            }
                          }
                        }
                      }).then((v) {
                        setState(() {
                          path = null;
                          fileName = null;
                          texFieldController.clear();
                        });
                      });
                    } else if (item.data()['role'] == 'd') {
                      FirebaseFirestore.instance
                          .collection('chats/' +
                              widget.userId.toString() +
                              '/' +
                              FirebaseAuth.instance.currentUser!.uid)
                          .get()
                          .then((lastDocId) {
                        for (var check in lastDocId.docs) {
                          String attachment = '';
                          path != null && fileName != null
                              ? attachment = fileName!
                              : attachment;
                          if (check.data()['id_message'] > 0) {
                            DocumentReference<Map<String, dynamic>> _message =
                                FirebaseFirestore.instance
                                    .collection('chats/' +
                                        widget.userId.toString() +
                                        '/' +
                                        FirebaseAuth.instance.currentUser!.uid)
                                    .doc((lastDocId.size + 1).toString());
                            _message.set({
                              'id_message': lastDocId.size + 1,
                              'message': path != null && fileName != null
                                  ? ''
                                  : texFieldController.text.trim(),
                              'attachment': attachment,
                              'sender': FirebaseAuth.instance.currentUser!.uid,
                              'member_1_email':
                                  FirebaseAuth.instance.currentUser!.email,
                              'member_2': widget.userId,
                              'member_2_email': widget.userEmail,
                              'timestamp': DateFormat('yyyy-MM-dd hh:mm')
                                  .format(DateTime.now()),
                            });
                            if (path != null && fileName != null) {
                              if (isDoc == true) {
                                storage.uploadFile(
                                    path!,
                                    widget.userId +
                                        '/' +
                                        FirebaseAuth.instance.currentUser!.uid +
                                        '/' +
                                        fileName!);
                              } else {
                                storage.uploadFile(
                                    path!,
                                    FirebaseAuth.instance.currentUser!.uid +
                                        '/' +
                                        widget.userId +
                                        '/' +
                                        fileName!);
                              }
                            }
                          } else {
                            DocumentReference<Map<String, dynamic>> _message =
                                FirebaseFirestore.instance
                                    .collection('chats/' +
                                        widget.userId.toString() +
                                        '/' +
                                        FirebaseAuth.instance.currentUser!.uid)
                                    .doc((lastDocId.size).toString());
                            _message.set({
                              'id_message': lastDocId.size,
                              'message': path != null && fileName != null
                                  ? ''
                                  : texFieldController.text.trim(),
                              'attachment': attachment,
                              'sender': FirebaseAuth.instance.currentUser!.uid,
                              'member_1_email':
                                  FirebaseAuth.instance.currentUser!.email,
                              'member_2': widget.userId,
                              'member_2_email': widget.userEmail,
                              'timestamp': DateFormat('yyyy-MM-dd hh:mm')
                                  .format(DateTime.now()),
                            });
                            if (path != null && fileName != null) {
                              if (isDoc == true) {
                                storage.uploadFile(
                                    path!,
                                    widget.userId +
                                        '/' +
                                        FirebaseAuth.instance.currentUser!.uid +
                                        '/' +
                                        fileName!);
                              } else {
                                storage.uploadFile(
                                    path!,
                                    FirebaseAuth.instance.currentUser!.uid +
                                        '/' +
                                        widget.userId +
                                        '/' +
                                        fileName!);
                              }
                            }
                          }
                        }
                      }).then((v) {
                        setState(() {
                          path = null;
                          fileName = null;
                          texFieldController.clear();
                        });
                      });
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
  bool? isDoc;
  @override
  void initState() {
    super.initState();
    FirebaseFirestore.instance
        .collection('roles')
        .where('uid', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then((value) {
      for (var item in value.docs) {
        if (item.data()['role'] == 'p') {
          setState(() {
            _chatMessages = getChatMessages('chats/' +
                FirebaseAuth.instance.currentUser!.uid +
                '/' +
                widget.userId);
            isDoc = false;
          });
        } else if (item.data()['role'] == 'd') {
          setState(() {
            _chatMessages = getChatMessages('chats/' +
                widget.userId +
                '/' +
                FirebaseAuth.instance.currentUser!.uid);
            isDoc = true;
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
                  if (snapshot.hasData) {
                    if (snapshot.data!.docs.isNotEmpty &&
                        snapshot.data!.docs[0]['id_message'] > 0) {
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
                            int prevIndex = index == 0 ? index : index - 1;
                            prevUserId =
                                snapshot.data!.docs[prevIndex]['sender'];
                            bool firstMessage = index == 0;
                            String attachmentName = _data['attachment'];
                            final bool isSameUser =
                                prevUserId == _data['sender'];
                            if (_data['attachment'].toString().isNotEmpty) {
                              bool isDocument = _data['attachment']
                                  .toString()
                                  .contains('.pdf');
                              bool isImg = _data['attachment']
                                      .toString()
                                      .contains('.png') ||
                                  _data['attachment']
                                      .toString()
                                      .contains('.jpg') ||
                                  _data['attachment']
                                      .toString()
                                      .contains('.jpeg');

                              return _chatBubble(
                                  message,
                                  storage.getImg(isDoc == true
                                      ? widget.userId +
                                          '/' +
                                          FirebaseAuth
                                              .instance.currentUser!.uid +
                                          '/' +
                                          _data['attachment']
                                      : FirebaseAuth.instance.currentUser!.uid +
                                          '/' +
                                          widget.userId +
                                          '/' +
                                          _data['attachment']),
                                  attachmentName,
                                  time,
                                  isMe,
                                  isSameUser,
                                  firstMessage,
                                  isImg,
                                  isDocument);
                            } else {
                              return _chatBubble(message, '', '', time, isMe,
                                  isSameUser, firstMessage, false, false);
                            }
                          });
                    } else {
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
          ),
          _sendMessageArea(),
        ],
      ),
    );
  }
}
