import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doc_app/api/get_data.dart';
import 'package:doc_app/pages/chat_screen.dart';
import 'package:doc_app/pages/home_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DocPage extends StatelessWidget {
  final String _collection;
  final int _id;

  const DocPage(this._collection, this._id, {Key? key}) : super(key: key);

  void _createChatSession(String docId, String userId) {
    Future<QuerySnapshot<Map<String, dynamic>>> _chatDocs = FirebaseFirestore
        .instance
        .collection('chats/' + userId.toString() + '/' + docId.toString())
        .get();

    Future<QuerySnapshot<Map<String, dynamic>>> _allChatDocs =
        FirebaseFirestore.instance.collection('all_chats').get();

    Future<QuerySnapshot<Map<String, dynamic>>> _allChatsAlreadyExists =
        FirebaseFirestore.instance
            .collection('all_chats')
            .where('member_1', isEqualTo: userId)
            .where('member_2', isEqualTo: docId)
            .get();
    _allChatDocs.then((value) {
      int newId = value.size == 0 ? 1 : value.size + 1;
      _allChatsAlreadyExists.then((value) {
        if (value.size == 0) {
          DocumentReference<Map<String, dynamic>> _chat = FirebaseFirestore
              .instance
              .collection('all_chats')
              .doc(newId.toString());

          _chat.set({'member_1': userId, 'member_2': docId});
        }
      });
    });
    _chatDocs.then((value) {
      int newId;
      if (value.size == 0) {
        newId = 1;

        DocumentReference<Map<String, dynamic>> _chat = FirebaseFirestore
            .instance
            .collection('chats/' + userId.toString() + '/' + docId.toString())
            .doc(newId.toString());

        _chat.set({'id_message': 0});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    showAlertDialog(
        BuildContext context, String message, bool isSuccess) async {
      // set up the button
      Widget okButton = TextButton(
        child: const Text('Закрыть',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center),
        onPressed: () {
          if (isSuccess == true) {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DocPage(_collection, _id),
                ));
          } else {
            Navigator.of(context).pop();
          }
        },
      );

      // set up the AlertDialog
      AlertDialog alert = AlertDialog(
        content: Text(message,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center),
        actions: [
          okButton,
        ],
      );

      // show the dialog
      return await showDialog(
        context: context,
        builder: (BuildContext context) {
          return alert;
        },
      );
    }

    Future _showAvailableTime(String docName, String docCategory, String docUid,
        String userUid) async {
      var todaysDate = DateFormat('yyyy-MM-dd hh:mm:ss').format(DateTime(
          DateTime.now().year,
          DateTime.now().month,
          DateTime.now().day,
          10,
          0));

      var todaysDateCheck = DateTime(
          DateTime.now().year,
          DateTime.now().month,
          DateTime.now().day,
          DateTime.now().hour + 2,
          // DateTime.now().hour,
          DateTime.now().minute,
          DateTime.now().second);

      var tomorrowDate = DateFormat('yyyy-MM-dd hh:mm:ss').format(DateTime(
          DateTime.now().year,
          DateTime.now().month,
          DateTime.now().day + 1,
          10,
          0));
      var dayAfterTomorrowDate = DateFormat('yyyy-MM-dd hh:mm:ss').format(
          DateTime(DateTime.now().year, DateTime.now().month,
              DateTime.now().day + 2, 10, 0));

      var todaysOnlyDate = DateFormat('yyyy-MM-dd').format(DateTime(
          DateTime.now().year, DateTime.now().month, DateTime.now().day));
      var tomorrowOnlyDate = DateFormat('yyyy-MM-dd').format(DateTime(
          DateTime.now().year, DateTime.now().month, DateTime.now().day + 1));
      var dayAfterTomorrowOnlyDate = DateFormat('yyyy-MM-dd').format(DateTime(
          DateTime.now().year, DateTime.now().month, DateTime.now().day + 2));

      // Lists with dates from ListView.builder
      var tempItemsToday = List.generate(
          8,
          (counter) => DateTime.parse(todaysDate)
              .add(Duration(hours: counter))
              .toString());
      var tempItemsTomorrow = List.generate(
          8,
          (counter) => DateTime.parse(tomorrowDate)
              .add(Duration(hours: counter))
              .toString());
      var tempItemsDayAfterTomorrow = List.generate(
          8,
          (counter) => DateTime.parse(dayAfterTomorrowDate)
              .add(Duration(hours: counter))
              .toString());

      tempItemsToday.removeWhere((today) =>
          DateTime.parse(today).millisecondsSinceEpoch <
          todaysDateCheck.millisecondsSinceEpoch);

      List<String> itemsToday = [];
      if (tempItemsToday.isNotEmpty) {
        for (var today in tempItemsToday) {
          itemsToday.add(DateFormat('yyyy-MM-dd HH:mm')
              .format(DateTime.parse(today))
              .toString());
        }
      }

      List<String> itemsTomorrow = [];
      for (var tomorrow in tempItemsTomorrow) {
        itemsTomorrow.add(DateFormat('yyyy-MM-dd HH:mm')
            .format(DateTime.parse(tomorrow))
            .toString());
      }

      List<String> itemsDayAfterTomorrow = [];
      for (var dayAfterTomorrow in tempItemsDayAfterTomorrow) {
        itemsDayAfterTomorrow.add(DateFormat('yyyy-MM-dd HH:mm')
            .format(DateTime.parse(dayAfterTomorrow))
            .toString());
      }
      //

      // Booked times
      await FirebaseFirestore.instance
          .collection('planned_visits/' + userUid + '/' + userUid)
          .where('date', isGreaterThan: DateTime.now().millisecondsSinceEpoch)
          .get()
          .then((element) {
        for (var item in element.docs) {
          itemsToday.removeWhere((element) => element.contains(
              DateFormat('yyyy-MM-dd HH:mm')
                  .format(DateTime.parse(
                      DateTime.fromMillisecondsSinceEpoch(item.data()['date'])
                          .toString()))
                  .toString()));
          itemsTomorrow.removeWhere((element) => element.contains(
              DateFormat('yyyy-MM-dd HH:mm')
                  .format(DateTime.parse(
                      DateTime.fromMillisecondsSinceEpoch(item.data()['date'])
                          .toString()))
                  .toString()));
          itemsDayAfterTomorrow.removeWhere((element) => element.contains(
              DateFormat('yyyy-MM-dd HH:mm')
                  .format(DateTime.parse(
                      DateTime.fromMillisecondsSinceEpoch(item.data()['date'])
                          .toString()))
                  .toString()));
        }
      }).then((v) => showGeneralDialog(
              context: context,
              barrierDismissible: true,
              barrierLabel:
                  MaterialLocalizations.of(context).modalBarrierDismissLabel,
              barrierColor: Colors.black45,
              transitionDuration: const Duration(milliseconds: 200),
              pageBuilder: (BuildContext buildContext, Animation animation,
                  Animation secondaryAnimation) {
                String firstEl = itemsToday.isNotEmpty
                    ? itemsToday[0].toString()
                    : (itemsTomorrow.isNotEmpty
                        ? itemsTomorrow[0].toString()
                        : (itemsDayAfterTomorrow.isNotEmpty
                            ? itemsDayAfterTomorrow[0].toString()
                            : ''));
                String _value = itemsToday.isNotEmpty
                    ? DateFormat.Hm()
                        .format(DateTime.parse(itemsToday[0]))
                        .toString()
                    : '';
                String _value2 = itemsToday.isEmpty && itemsTomorrow.isNotEmpty
                    ? DateFormat.Hm()
                        .format(DateTime.parse(itemsTomorrow[0]))
                        .toString()
                    : '';
                String _value3 =
                    itemsTomorrow.isEmpty && itemsDayAfterTomorrow.isNotEmpty
                        ? DateFormat.Hm()
                            .format(DateTime.parse(itemsDayAfterTomorrow[0]))
                            .toString()
                        : '';
                // String _result = itemsToday[0].toString();
                String _result = firstEl;
                bool _isAvailable = true;
                return SafeArea(
                  child: Material(
                    color: Colors.black,
                    child: Column(
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height * 0.85,
                          child: StatefulBuilder(builder:
                              (BuildContext context, StateSetter setState) {
                            return Row(
                              children: <Widget>[
                                itemsToday.isNotEmpty
                                    ? Expanded(
                                        child: ListView.builder(
                                          itemCount: itemsToday.length,
                                          itemBuilder: (BuildContext context,
                                              int index) {
                                            return ListTile(
                                              horizontalTitleGap: 0,
                                              textColor: Colors.black,
                                              title: Text(
                                                DateFormat.Md()
                                                    .format(DateTime.parse(
                                                        todaysOnlyDate))
                                                    .toString(),
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 15,
                                                ),
                                              ),
                                              subtitle: Text(
                                                  DateFormat.Hm()
                                                      .format(DateTime.parse(
                                                          itemsToday[index]))
                                                      .toString(),
                                                  style: const TextStyle(
                                                      fontSize: 15,
                                                      color: Colors.white,
                                                      decoration:
                                                          TextDecoration.none,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      overflow:
                                                          TextOverflow.fade)),
                                              leading: Theme(
                                                data:
                                                    Theme.of(context).copyWith(
                                                  unselectedWidgetColor:
                                                      Colors.blue,
                                                  disabledColor: Colors.blue,
                                                ),
                                                child: Radio(
                                                  value: DateFormat.Hm()
                                                      .format(DateTime.parse(
                                                          itemsToday[index]))
                                                      .toString(),
                                                  groupValue: _value,
                                                  onChanged: (String? value) {
                                                    setState(() {
                                                      _value = value.toString();
                                                      _result = DateFormat(
                                                              'yyyy-MM-dd HH:mm')
                                                          .format(DateTime.parse(
                                                              todaysOnlyDate +
                                                                  ' ' +
                                                                  value
                                                                      .toString() +
                                                                  ':00'))
                                                          .toString();
                                                      _value2 = '';
                                                      _value3 = '';
                                                    });
                                                  },
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      )
                                    : Expanded(
                                        child: Text(
                                        'На ' +
                                            DateFormat.Md()
                                                .format(DateTime.parse(
                                                    todaysOnlyDate))
                                                .toString() +
                                            ' свободных мест нет',
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold),
                                        textAlign: TextAlign.center,
                                      )),
                                // const Divider(),
                                itemsTomorrow.isNotEmpty
                                    ? Expanded(
                                        child: ListView.builder(
                                          itemCount: itemsTomorrow.length,
                                          itemBuilder: (BuildContext context,
                                              int index) {
                                            return ListTile(
                                              horizontalTitleGap: 0,
                                              title: Text(
                                                DateFormat.Md()
                                                    .format(DateTime.parse(
                                                        tomorrowOnlyDate))
                                                    .toString(),
                                                style: const TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 15),
                                              ),
                                              subtitle: Text(
                                                  DateFormat.Hm()
                                                      .format(DateTime.parse(
                                                          itemsTomorrow[index]))
                                                      .toString(),
                                                  style: _isAvailable == true
                                                      ? const TextStyle(
                                                          fontSize: 15,
                                                          decoration:
                                                              TextDecoration
                                                                  .none,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.white,
                                                          overflow:
                                                              TextOverflow.fade)
                                                      : const TextStyle(
                                                          fontSize: 15,
                                                          decoration:
                                                              TextDecoration
                                                                  .lineThrough,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.white,
                                                          overflow: TextOverflow
                                                              .fade)),
                                              leading: Theme(
                                                data:
                                                    Theme.of(context).copyWith(
                                                  unselectedWidgetColor:
                                                      Colors.blue,
                                                  disabledColor: Colors.blue,
                                                ),
                                                child: Radio(
                                                  value: DateFormat.Hm()
                                                      .format(DateTime.parse(
                                                          itemsTomorrow[index]))
                                                      .toString(),
                                                  groupValue: _value2,
                                                  onChanged: (String? value) {
                                                    setState(() {
                                                      _value2 =
                                                          value.toString();
                                                      _result = DateFormat(
                                                              'yyyy-MM-dd HH:mm')
                                                          .format(DateTime.parse(
                                                              tomorrowOnlyDate +
                                                                  ' ' +
                                                                  value
                                                                      .toString() +
                                                                  ':00'))
                                                          .toString();
                                                      _value = '';
                                                      _value3 = '';
                                                    });
                                                  },
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      )
                                    : Expanded(
                                        child: Text(
                                        'На ' +
                                            DateFormat.Md()
                                                .format(DateTime.parse(
                                                    tomorrowOnlyDate))
                                                .toString() +
                                            ' свободных мест нет',
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold),
                                        textAlign: TextAlign.center,
                                      )),
                                // const Divider(),
                                itemsDayAfterTomorrow.isNotEmpty
                                    ? Expanded(
                                        child: ListView.builder(
                                          itemCount:
                                              itemsDayAfterTomorrow.length,
                                          itemBuilder: (BuildContext context,
                                              int index) {
                                            return ListTile(
                                              horizontalTitleGap: 0,
                                              title: Text(
                                                DateFormat.Md()
                                                    .format(DateTime.parse(
                                                        dayAfterTomorrowOnlyDate))
                                                    .toString(),
                                                style: const TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 15),
                                              ),
                                              subtitle: Text(
                                                  DateFormat.Hm()
                                                      .format(DateTime.parse(
                                                          itemsDayAfterTomorrow[
                                                              index]))
                                                      .toString(),
                                                  style: const TextStyle(
                                                      fontSize: 15,
                                                      decoration:
                                                          TextDecoration.none,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.white,
                                                      overflow:
                                                          TextOverflow.fade)),
                                              leading: Theme(
                                                data:
                                                    Theme.of(context).copyWith(
                                                  unselectedWidgetColor:
                                                      Colors.blue,
                                                  disabledColor: Colors.blue,
                                                ),
                                                child: Radio(
                                                  value: DateFormat.Hm()
                                                      .format(DateTime.parse(
                                                          itemsDayAfterTomorrow[
                                                              index]))
                                                      .toString(),
                                                  groupValue: _value3,
                                                  onChanged: (String? value) {
                                                    setState(() {
                                                      _value3 =
                                                          value.toString();
                                                      _result = DateFormat(
                                                              'yyyy-MM-dd HH:mm')
                                                          .format(DateTime.parse(
                                                              dayAfterTomorrowOnlyDate +
                                                                  ' ' +
                                                                  value
                                                                      .toString() +
                                                                  ':00'))
                                                          .toString();
                                                      _value2 = '';
                                                      _value = '';
                                                    });
                                                  },
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      )
                                    : Expanded(
                                        child: Text(
                                        'На ' +
                                            DateFormat.Md()
                                                .format(DateTime.parse(
                                                    dayAfterTomorrowOnlyDate))
                                                .toString() +
                                            ' свободных мест нет',
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold),
                                        textAlign: TextAlign.center,
                                      )),
                              ],
                            );
                          }),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height * 0.1,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              TextButton(
                                onPressed: (() => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          DocPage(_collection, _id),
                                    ))),
                                child: const Text('Закрыть',
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white)),
                              ),
                              TextButton(
                                onPressed: () async {
                                  await FirebaseFirestore.instance
                                      .collection('planned_visits/' +
                                          userUid +
                                          '/' +
                                          userUid)
                                      .where('date',
                                          isEqualTo:
                                              DateTime.parse(_result + ':00')
                                                  .millisecondsSinceEpoch)
                                      .get()
                                      .then((alreadyExists) async {
                                    if (alreadyExists.size > 0 ||
                                        DateTime.parse(_result)
                                                .millisecondsSinceEpoch <
                                            todaysDateCheck
                                                .millisecondsSinceEpoch) {
                                      await showAlertDialog(
                                              context,
                                              'Похоже это время уже занято либо более недоступно',
                                              false)
                                          .then((value) async {
                                        await _showAvailableTime(docName,
                                            docCategory, docUid, userUid);
                                      });
                                    } else {
                                      await FirebaseFirestore.instance
                                          .collection('planned_visits/' +
                                              userUid +
                                              '/' +
                                              userUid)
                                          .where('doc_uid', isEqualTo: docUid)
                                          .get()
                                          .then((alreadyExists) {
                                        List existsTime = [];
                                        for (var el in alreadyExists.docs) {
                                          if (el.data()['date'] >
                                              DateTime.now()
                                                  .millisecondsSinceEpoch) {
                                            existsTime.add(el.data()['date']);
                                          }
                                        }
                                        if (existsTime.isNotEmpty) {
                                          showAlertDialog(
                                              context,
                                              'У вас уже есть запланированный прием к этому врачу на \n' +
                                                  DateFormat('yyyy-MM-dd HH:mm')
                                                      .format(DateTime.parse(
                                                          DateTime.fromMillisecondsSinceEpoch(
                                                                  alreadyExists
                                                                      .docs.last
                                                                      .data()['date'])
                                                              .toString()))
                                                      .toString(),
                                              true);
                                        } else {
                                          FirebaseFirestore.instance
                                              .collection('planned_visits/' +
                                                  userUid +
                                                  '/' +
                                                  userUid)
                                              .get()
                                              .then((planned) async {
                                            int newPlannedId = planned.size == 0
                                                ? 1
                                                : planned.size + 1;
                                            FirebaseFirestore.instance
                                                .collection('planned_visits/' +
                                                    userUid +
                                                    '/' +
                                                    userUid)
                                                .doc(newPlannedId.toString())
                                                .set({
                                              'name': docName,
                                              'category': docCategory,
                                              'doc_uid': docUid,
                                              'role': 'p',
                                              'date': DateTime.parse(
                                                      _result + ':00')
                                                  .millisecondsSinceEpoch
                                            });
                                            await FirebaseFirestore.instance
                                                .collection('appointments/' +
                                                    docUid +
                                                    '/' +
                                                    docUid)
                                                .get()
                                                .then((appointments) async {
                                              int newAppointId =
                                                  appointments.size == 0
                                                      ? 1
                                                      : appointments.size + 1;
                                              await FirebaseFirestore.instance
                                                  .collection('users')
                                                  .where('uid',
                                                      isEqualTo: userUid)
                                                  .get()
                                                  .then((userName) async {
                                                await FirebaseFirestore.instance
                                                    .collection(
                                                        'appointments/' +
                                                            docUid +
                                                            '/' +
                                                            docUid)
                                                    .doc(
                                                        newAppointId.toString())
                                                    .set({
                                                  'name': userName.docs.first
                                                      .data()['name'],
                                                  'user_uid': userUid,
                                                  'role': 'd',
                                                  'date': DateTime.parse(
                                                          _result + ':00')
                                                      .millisecondsSinceEpoch
                                                });
                                              });
                                            });
                                          }).then((value) => showAlertDialog(
                                                  context,
                                                  'Вы успешно забронировали метсто на \n' +
                                                      _result,
                                                  true));
                                        }
                                      });
                                    }
                                  });
                                },
                                child: const Text('Записаться',
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }));
    }

    final _query = getDoctorData(_collection, id: _id);
    return WillPopScope(
      onWillPop: () async => false,
      child: DefaultTextStyle(
        style: const TextStyle(
          decoration: TextDecoration.none,
        ),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.8,
          height: MediaQuery.of(context).size.height * 0.8,
          padding: const EdgeInsets.all(15.0),
          decoration: const BoxDecoration(
            color: Colors.black,
          ),
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Material(
                      color: Colors.black,
                      child: IconButton(
                        onPressed: () async {
                          await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      HomePage(true, _collection)));
                        },
                        icon: const Icon(
                          Icons.arrow_back_sharp,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Material(
                      color: Colors.black,
                      child: IconButton(
                        onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const HomePage(false, ''),
                            )),
                        icon: const Icon(
                          Icons.home,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                    future: _query,
                    builder: (_, snapshot) {
                      if (snapshot.hasError) {
                        return Expanded(
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
                        return Expanded(
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
                        var _data = snapshot.data!.data();
                        return Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              CircleAvatar(
                                radius: 100.0,
                                backgroundImage:
                                    _data?['img'] != null && _data?['img'] != ""
                                        ? AssetImage(
                                            'assets/images/' + _data?['img'])
                                        : const AssetImage(
                                            'assets/images/home_img.png'),
                              ),
                              Text(
                                _data?['name'] ?? '',
                                style: const TextStyle(
                                  fontSize: 35.0,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Pacifico',
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 20, right: 1.5),
                                    child: Text(
                                      _data?['category'] ?? '',
                                      // '',
                                      style: TextStyle(
                                        fontFamily: 'SourceSansPro',
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20.0,
                                        color: Colors.teal.shade100,
                                        letterSpacing: 1.5,
                                      ),
                                    ),
                                  ),
                                  (_data?['license'] != null &&
                                          _data?['license'] == 0)
                                      ? const Icon(
                                          Icons.av_timer,
                                          color: Colors.yellow,
                                          size: 20,
                                        )
                                      : (_data?['license'] != null &&
                                              _data?['license'] == 1)
                                          ? const Icon(
                                              Icons.check,
                                              color: Colors.green,
                                              size: 20,
                                            )
                                          : (_data?['license'] != null &&
                                                  _data?['license'] == 2)
                                              ? const Icon(
                                                  Icons.close,
                                                  color: Colors.red,
                                                  size: 20,
                                                )
                                              : const SizedBox(
                                                  width: 0,
                                                  height: 0,
                                                )
                                ],
                              ),
                              SizedBox(
                                height: 20.0,
                                width: 150.0,
                                child: Divider(
                                  color: Colors.teal.shade100,
                                ),
                              ),
                              Card(
                                margin: const EdgeInsets.symmetric(
                                    vertical: 10.0, horizontal: 25.0),
                                child: ListTile(
                                  leading: const Icon(
                                    Icons.phone,
                                    color: Colors.teal,
                                  ),
                                  title: Text(
                                    _data?['phone'] ??
                                        '+(994) 55-555-55-55',
                                    // '+90 506 922 92 21',
                                    style: TextStyle(
                                      fontSize: 20.0,
                                      fontFamily: 'SourceSansPro',
                                      color: Colors.teal.shade900,
                                    ),
                                  ),
                                ),
                              ),
                              Card(
                                margin: const EdgeInsets.symmetric(
                                    vertical: 10.0, horizontal: 25.0),
                                child: ListTile(
                                  leading: const Icon(
                                    Icons.email,
                                    color: Colors.teal,
                                  ),
                                  title: Text(
                                    _data?['email'] ?? '',
                                    style: TextStyle(
                                      fontSize: 20.0,
                                      fontFamily: 'SourceSansPro',
                                      color: Colors.teal.shade900,
                                    ),
                                  ),
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Card(
                                      margin: const EdgeInsets.symmetric(
                                          vertical: 5.0, horizontal: 10),
                                      child: TextButton(
                                        onPressed: () {
                                          _createChatSession(
                                              _data!['uid'],
                                              FirebaseAuth
                                                  .instance.currentUser!.uid);
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    ChatScreen(_data['uid'],
                                                        _data['email']),
                                              ));
                                        },
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            const Icon(
                                              Icons.chat_rounded,
                                              color: Colors.teal,
                                            ),
                                            Text(
                                              'Чат',
                                              style: TextStyle(
                                                fontSize: 20.0,
                                                fontFamily: 'SourceSansPro',
                                                fontWeight: FontWeight.bold,
                                                color: Colors.teal.shade900,
                                              ),
                                            ),
                                          ],
                                        ),
                                      )),
                                  Card(
                                      margin: const EdgeInsets.symmetric(
                                          vertical: 5.0, horizontal: 10),
                                      child: TextButton(
                                        onPressed: () async {
                                          await FirebaseFirestore.instance
                                              .collection('planned_visits/' +
                                                  FirebaseAuth.instance
                                                      .currentUser!.uid +
                                                  '/' +
                                                  FirebaseAuth.instance
                                                      .currentUser!.uid)
                                              .where('doc_uid',
                                                  isEqualTo: _data?['uid'])
                                              .get()
                                              .then((alreadyExists) {
                                            if (alreadyExists.size > 0) {
                                              List existsTime = [];
                                              for (var el
                                                  in alreadyExists.docs) {
                                                if (el.data()['date'] >
                                                    DateTime.now()
                                                        .millisecondsSinceEpoch) {
                                                  existsTime
                                                      .add(el.data()['date']);
                                                }
                                              }
                                              if (existsTime.isNotEmpty) {
                                                showAlertDialog(
                                                    context,
                                                    'У вас уже есть запланированный прием к этому врачу на \n' +
                                                        DateFormat(
                                                                'yyyy-MM-dd HH:mm')
                                                            .format(DateTime.parse(
                                                                DateTime.fromMillisecondsSinceEpoch(
                                                                        alreadyExists
                                                                            .docs
                                                                            .last
                                                                            .data()['date'])
                                                                    .toString()))
                                                            .toString(),
                                                    true);
                                              } else {
                                                _showAvailableTime(
                                                    _data?['name'],
                                                    _data?['category'],
                                                    _data?['uid'],
                                                    FirebaseAuth.instance
                                                        .currentUser!.uid);
                                              }
                                            } else {
                                              _showAvailableTime(
                                                  _data?['name'],
                                                  _data?['category'],
                                                  _data?['uid'],
                                                  FirebaseAuth.instance
                                                      .currentUser!.uid);
                                            }
                                          });
                                        },
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            const Icon(
                                              Icons.calendar_month,
                                              color: Colors.teal,
                                            ),
                                            Text(
                                              'Записаться',
                                              style: TextStyle(
                                                fontSize: 20.0,
                                                fontFamily: 'SourceSansPro',
                                                fontWeight: FontWeight.bold,
                                                color: Colors.teal.shade900,
                                              ),
                                            ),
                                          ],
                                        ),
                                      )),
                                ],
                              ),
                            ],
                          ),
                        );
                      } else {
                        return Expanded(
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
