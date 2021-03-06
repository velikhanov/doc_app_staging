import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doc_app/api/get_data.dart';
import 'package:doc_app/api/storage_service.dart';
import 'package:doc_app/pages/home_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class DocumentsPage extends StatefulWidget {
  const DocumentsPage({Key? key}) : super(key: key);

  @override
  State<DocumentsPage> createState() => _DocumentsPageState();
}

class _DocumentsPageState extends State<DocumentsPage> {
  bool? isDoc;
  String? _email;
  @override
  void initState() {
    super.initState();
    FirebaseFirestore.instance
        .collection('roles')
        .where('uid', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then((e) {
      if (e.docs[0].data()['role'] == 'p') {
        isDoc = false;
      } else if (e.docs[0].data()['role'] == 'd') {
        isDoc = true;
      }
    });
  }

  int _routeStack = 0;
  bool _isFirstPage = true;
  var _allDocs = getDocuments(FirebaseAuth.instance.currentUser!.uid, true);

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: AppBar(
        centerTitle: true,
        title: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            children: [
              TextSpan(
                  text: _routeStack > 0 ? _email : '?????? ????????????????',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  )),
            ],
          ),
        ),
        leading: Padding(
          padding: const EdgeInsets.only(left: 20),
          child: IconButton(
              icon: const Icon(Icons.arrow_back_ios),
              color: Colors.white,
              onPressed: () {
                if (_routeStack > 0) {
                  setState(() {
                    _isFirstPage = true;
                    _allDocs = getDocuments(
                        FirebaseAuth.instance.currentUser!.uid, true);
                    _routeStack--;
                    _email = null;
                  });
                } else {
                  Navigator.pop(context);
                }
              }),
        ),
        actions: [
          _routeStack > 0
              ? Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: IconButton(
                    icon: const Icon(Icons.home),
                    color: Colors.white,
                    onPressed: (() => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const HomePage(false, ''),
                        ))),
                  ))
              : const SizedBox(),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.only(
            top: _routeStack > 0 ? 15 : 5, bottom: _routeStack > 0 ? 15 : 5),
        child: FutureBuilder(
            future: _allDocs,
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.hasError) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Flexible(
                      child: Text(
                        "???????????? ???????????????? ????????????.\n????????????????????, ?????????????????? ?????????????? ??????????: ${snapshot.error.toString()}",
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
                        "???????????????? ????????????, ????????????????????, ??????????????????..",
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
                if (_isFirstPage == true && snapshot.data.isNotEmpty) {
                  return ListView.separated(
                      separatorBuilder: (BuildContext context, int index) =>
                          const SizedBox(),
                      itemCount: snapshot.data.length,
                      itemBuilder: (context, index) {
                        var _data = snapshot.data![index];
                        return Card(
                          color: const Color.fromARGB(255, 152, 215, 225),
                          child: ListTile(
                            onTap: (() => setState(() {
                                  _isFirstPage = false;
                                  _allDocs = getDocuments(
                                      FirebaseAuth.instance.currentUser!.uid,
                                      false,
                                      email: _data);
                                  _email = _data;
                                  _routeStack++;
                                })),
                            title: Text(_data,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            leading: const CircleAvatar(
                                backgroundImage:
                                    AssetImage('assets/images/attachment.png')),
                            // trailing: Icon(Icons.access_time_filled, color: Colors.black,)));
                            trailing: const Icon(
                              Icons.document_scanner,
                              color: Colors.black,
                            ),
                          ),
                        );
                      });
                } else if (_isFirstPage == false && snapshot.data.isNotEmpty) {
                  return GridView.count(
                    physics: const ScrollPhysics(),
                    crossAxisCount: 3,
                    children: List.generate(snapshot.data.length, (index) {
                      var _data = snapshot.data[index];
                      String attachmentName = _data['attachment'];
                      var attachment = Storage().getImg(isDoc == true &&
                              FirebaseAuth.instance.currentUser!.uid ==
                                  _data['sender']
                          ? _data['member_2'] +
                              '/' +
                              FirebaseAuth.instance.currentUser!.uid +
                              '/' +
                              _data['attachment']
                          : isDoc == true &&
                                  FirebaseAuth.instance.currentUser!.uid !=
                                      _data['sender']
                              ? _data['sender'] +
                                  '/' +
                                  FirebaseAuth.instance.currentUser!.uid +
                                  '/' +
                                  _data['attachment']
                              : isDoc == false &&
                                      FirebaseAuth.instance.currentUser!.uid ==
                                          _data['sender']
                                  ? FirebaseAuth.instance.currentUser!.uid +
                                      '/' +
                                      _data['member_2'] +
                                      '/' +
                                      _data['attachment']
                                  : FirebaseAuth.instance.currentUser!.uid +
                                      '/' +
                                      _data['member_2'] +
                                      '/' +
                                      _data['attachment']);
                      return FutureBuilder(
                          future: attachment,
                          builder:
                              (BuildContext context, AsyncSnapshot snapshot) {
                            if (snapshot.hasError) {
                              return const SizedBox(
                                height: 90,
                                width: 90,
                                child: Center(
                                  child: Text(
                                    "???????????? ????????????????..",
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              );
                            }

                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const SizedBox(
                                height: 90,
                                width: 90,
                                child: Center(
                                  child: Text(
                                    "???????????????? ????????????..",
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
                                  _data.toString().isNotEmpty &&
                                          _data.toString().contains('.pdf')
                                      // ? SizedBox(
                                      //     height: 90,
                                      //     width: 90,
                                      //     child: IconButton(
                                      //         onPressed: (() => _showAttachment(
                                      //             _data, false)),
                                      //         icon: const Icon(
                                      //           Icons.picture_as_pdf,
                                      //           color: Colors.black,
                                      //           size: 90,
                                      //         )),
                                      //   )
                                      ? SizedBox(
                                        height: 110,
                                        // width: 120,
                                        child: 
                                            TextButton(
                                              onPressed: (() =>
                                                  _showAttachment(_data, false)),
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
                                      : Container(
                                          height: 90,
                                          width: 90,
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
                                    "???????????? ????????????????..",
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              );
                            }
                          });
                    }),
                  );
                } else {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const <Widget>[
                      Flexible(
                        child: Text(
                          '???????? ?????? ?????????? ??????????',
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
                        "???????????? ???????????????? ????????????.\n????????????????????, ?????????????????? ?????????????? ??????????",
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
    );
  }
}
