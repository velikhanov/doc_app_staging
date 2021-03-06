import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doc_app/api/get_data.dart';
import 'package:doc_app/pages/home_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PatientHistoryPage extends StatefulWidget {
  final String? uid;
  const PatientHistoryPage({this.uid, Key? key}) : super(key: key);

  @override
  State<PatientHistoryPage> createState() => _PatientHistoryPageState();
}

class _PatientHistoryPageState extends State<PatientHistoryPage> {
  int _routeStack = 0;
  String? _name;
  bool _isFirstPage = true;
  dynamic _userHistory;

  bool isDoc = false;
  @override
  void initState() {
    super.initState();
    if(widget.uid != null){
      _userHistory = getPlannedVisits(FirebaseAuth.instance.currentUser!.uid, returnAll: true, firstPage: false, docUid: widget.uid);
      _routeStack++;
      _isFirstPage = false;
    }else{
      _userHistory = getPlannedVisits(FirebaseAuth.instance.currentUser!.uid, returnAll: true, firstPage: true);
      _routeStack = 0;
      _isFirstPage = true;
    }
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
  TextEditingController detailsController = TextEditingController();
  Future<void> _showDetails(BuildContext context, int _date, {String? userId}) async {
      if(isDoc == true){
        FirebaseFirestore.instance
        .collection('appointments/' + FirebaseAuth.instance.currentUser!.uid + '/' + FirebaseAuth.instance.currentUser!.uid)
        .where('date', isEqualTo: _date)
        .get().then((value){
          detailsController.text = value.docs[0].data()['details'] != null && value.docs[0].data()['details'].toString().isNotEmpty ? value.docs[0].data()['details'].toString() : "";
          return showDialog(
            context: context,
            builder: (BuildContext detailContext) {
              return AlertDialog(
                title: const Text(
                  '???????????? ????????????',
                  textAlign: TextAlign.center,
                ),
                content: 
                // Column(
                //   children: <Widget>[
                    TextField(
                      keyboardType: TextInputType.text,
                      controller: detailsController,
                      readOnly: isDoc == true ? false : true,
                      minLines: 1,
                      maxLines: 10,
                      // maxLength: 30,
                      decoration: InputDecoration(
                        hintText: detailsController.text.trim().isEmpty ? '???????? ?????? ??????????' : '',
                        // prefixIcon: Text('??????.: ', style: TextStyle(fontWeight: FontWeight.bold)),
                        // prefixIconConstraints: BoxConstraints(minWidth: 0, minHeight: 0),
                      ),
                    ),
                //   ],
                // ),
                actions: [
                  Row(
                  mainAxisAlignment: isDoc == true ? MainAxisAlignment.spaceAround : MainAxisAlignment.center,
                  children: <Widget>[
                      TextButton(
                          onPressed: (() => Navigator.pop(detailContext)),
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all(Colors.red),
                            shape:
                                MaterialStateProperty.resolveWith<OutlinedBorder>(
                                    (_) {
                              return RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              );
                            }),
                          ),
                          child: const Text(
                            '??????????????',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 19,
                                fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          )),
                      Visibility(
                        visible: isDoc == true ? true : false,
                        child: TextButton(
                          onPressed: () async {

                            await FirebaseFirestore.instance
                            .collection('appointments/' + FirebaseAuth.instance.currentUser!.uid + '/' + FirebaseAuth.instance.currentUser!.uid)
                            .where('date', isEqualTo: _date).get().then((value) async{
                              await FirebaseFirestore.instance
                              .collection('appointments/' + FirebaseAuth.instance.currentUser!.uid + '/' + FirebaseAuth.instance.currentUser!.uid)
                              .doc(value.docs[0].id)
                              .update({
                                "details": detailsController.text
                              });
                            }).then((value) async{
                              await FirebaseFirestore.instance
                              .collection('planned_visits/' + userId! + '/' + userId)
                              .where('date', isEqualTo: _date).get().then((value) async{
                                await FirebaseFirestore.instance
                                .collection('planned_visits/' + userId + '/' + userId)
                                .doc(value.docs[0].id)
                                .update({
                                  "details": detailsController.text
                                });
                              });
                            });
                            // then((value) {
                              Navigator.of(detailContext).pop();
                            // });
                          },
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all(Colors.blue),
                            shape:
                                MaterialStateProperty.resolveWith<OutlinedBorder>(
                                    (_) {
                              return RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              );
                            }),
                          ),
                          child: const Text(
                            '??????????????????',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 19,
                                fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          )),
                      ),
                    ],
                  ),
                ],
              );
            }
          );
        });
      }else{
        FirebaseFirestore.instance
        .collection('planned_visits/' + FirebaseAuth.instance.currentUser!.uid + '/' + FirebaseAuth.instance.currentUser!.uid)
        .where('date', isEqualTo: _date)
        .get().then((value){
        detailsController.text = value.docs[0].data()['details'] != null && value.docs[0].data()['details'].toString().isNotEmpty ? value.docs[0].data()['details'].toString() : "";
          return showDialog(
            context: context,
            builder: (BuildContext detailContext) {
              return AlertDialog(
                title: const Text(
                  '???????????? ????????????',
                  textAlign: TextAlign.center,
                ),
                content: 
                // Column(
                //   children: <Widget>[
                    TextField(
                      keyboardType: TextInputType.text,
                      controller: detailsController,
                      readOnly: isDoc == true ? false : true,
                      minLines: 1,
                      maxLines: 10,
                      // maxLength: 30,
                      decoration: InputDecoration(
                        hintText: detailsController.text.trim().isEmpty ? '???????? ?????? ??????????' : '',
                        // prefixIcon: Text('??????.: ', style: TextStyle(fontWeight: FontWeight.bold)),
                        // prefixIconConstraints: BoxConstraints(minWidth: 0, minHeight: 0),
                      ),
                    ),
                //   ],
                // ),
                actions: [
                  Row(
                  mainAxisAlignment: isDoc == true ? MainAxisAlignment.spaceAround : MainAxisAlignment.center,
                  children: <Widget>[
                      TextButton(
                          onPressed: (() => Navigator.pop(detailContext)),
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all(Colors.red),
                            shape:
                                MaterialStateProperty.resolveWith<OutlinedBorder>(
                                    (_) {
                              return RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              );
                            }),
                          ),
                          child: const Text(
                            '??????????????',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 19,
                                fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          )),
                      Visibility(
                        visible: isDoc == true ? true : false,
                        child: TextButton(
                          onPressed: null,
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all(Colors.blue),
                            shape:
                                MaterialStateProperty.resolveWith<OutlinedBorder>(
                                    (_) {
                              return RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              );
                            }),
                          ),
                          child: const Text(
                            '??????????????????',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 19,
                                fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          )),
                      ),
                    ],
                  ),
                ],
              );
            }
          );
        });
      }
    }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 20),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            color: Colors.white,
            onPressed: () {
              if (_routeStack > 0) {
                setState(() {
                  _isFirstPage = true;
                  _userHistory = getPlannedVisits(FirebaseAuth.instance.currentUser!.uid, returnAll: true, firstPage: true);
                  _routeStack--;
                  _name = null;
                });
              } else {
                Navigator.pop(context);
              }
            }),
        ),
        centerTitle: true,
        title: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            children: [
              TextSpan(
                  text: _routeStack > 0 ? _name : '?????????????? ??????????????????',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  )),
            ],
          ),
        ),
        // const Text(
        //   '?????????????? ??????????????????',
        //   style: TextStyle(
        //     color: Colors.white,
        //   ),
        // ),
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
      body: FutureBuilder(
              future: _userHistory,
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Column(
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
                            "???????????????? ????????????, ????????????????????, ??????????????????..",
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
                
                if(snapshot.hasData){
                  if (_isFirstPage == true && snapshot.data.isNotEmpty) {
                  return ListView.separated(
                      separatorBuilder: (BuildContext context, int index) =>
                          const SizedBox(),
                      itemCount: snapshot.data.length,
                      itemBuilder: (context, index) {
                        var _data = snapshot.data![index];
                        return Card(
                          // color: const Color.fromARGB(255, 141, 1, 180),
                          color: const Color.fromARGB(255, 152, 215, 225),
                          child: ListTile(
                            onTap: (() => setState(() {
                                  _isFirstPage = false;
                                  _userHistory = getPlannedVisits(FirebaseAuth.instance.currentUser!.uid, returnAll: true, firstPage: false, docUid: isDoc == true ? _data['user_uid'] : _data['doc_uid']);
                                  // _name = isDoc == true ? _data['name'] : _data['name'] + ' - ' + _data['category'];
                                  _name = _data['email'];
                                  _routeStack++;
                                })),
                            // title: Text(isDoc == true ? _data['name'] : _data['name'] + ' - ' + _data['category'],
                            title: Text(_data['email'],
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            subtitle: Text((DateTime.now().millisecondsSinceEpoch > _data['date'] ? '??????????????????' : '????????????????.') + ' ??????????????????: ' + DateFormat('dd/MM/yyyy').format(DateTime.fromMillisecondsSinceEpoch(_data['date'])).toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
                            leading: const CircleAvatar(
                                backgroundImage:
                                    AssetImage('assets/images/history2.png')),
                            // trailing: Icon(Icons.access_time_filled, color: Colors.black,)));
                            trailing: const Icon(
                              Icons.file_open,
                              color: Colors.black,
                            ),
                          ),
                        );
                      });
                  // } else if (_isFirstPage == false && snapshot.data.size > 0) {
                  } else if (_isFirstPage == false && snapshot.data.length > 0) {
                    return ListView.separated(
                      separatorBuilder: (BuildContext context, int index) =>
                          const SizedBox(),
                      // itemCount: snapshot.data.size,
                      itemCount: snapshot.data.length,
                      itemBuilder: (context, index) {
                        // var _data = snapshot.data!.docs[index].data();
                        var _data = snapshot.data![index].data();
                        return Card(
                          color: const Color.fromARGB(255, 152, 215, 225),
                          child: ListTile(
                            onTap: () => _showDetails(context, _data['date'], userId: _data['user_uid']),
                            title: Text((DateTime.now().millisecondsSinceEpoch > _data['date'] ? '??????????????????' : '????????????????.') + ' ??????????????????: ' + DateFormat('dd/MM/yyyy').format(DateTime.fromMillisecondsSinceEpoch(_data['date'])).toString(),  
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            subtitle: const Text('??????????????, ?????????? ???????????????????? ????????????', style: TextStyle(fontWeight: FontWeight.bold),),
                            leading: const CircleAvatar(
                                backgroundImage:
                                    AssetImage('assets/images/history2.png')),
                            // trailing: Icon(Icons.access_time_filled, color: Colors.black,)));
                            trailing: const Icon(
                              Icons.file_open,
                              color: Colors.black,
                            ),
                          ),
                        );
                      });
                  } else {
                    return Center(
                      child: Column(
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
                      ),
                    );
                  }
                }else{
                  return Center(
                      child: Column(
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
                      ),
                    );
                }
                // return const SizedBox();
            }),
    );
  }
}