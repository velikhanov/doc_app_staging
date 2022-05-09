import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doc_app/api/get_data.dart';
import 'package:doc_app/auth/auth_service.dart';
import 'package:doc_app/auth/signin_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class TopBar extends StatefulWidget {
  const TopBar({Key? key}) : super(key: key);

  @override
  State<TopBar> createState() => _TopBarState();
}

class _TopBarState extends State<TopBar> {
  bool isDoc = false;
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

  DateTime selectedDate = DateTime.now();
  @override
  Widget build(BuildContext context) {
      Future<void> _selectDate(BuildContext expContext) async {
        return await showDatePicker(
          context: expContext,
          initialDate: selectedDate,
          firstDate: DateTime(1922, 1),
          lastDate: DateTime(2122)).then((value){
            if (value != null && value != selectedDate){
              setState(() {
                selectedDate = value;
              });
            }
          });
      }
    Future<void> _editUserData(BuildContext context) async {
      var _userData = getUserPersonalData();
      TextEditingController nameController = TextEditingController();
      TextEditingController phoneController = TextEditingController();
      return showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text(
                'Персональные данные',
                textAlign: TextAlign.center,
              ),
              content: FutureBuilder(
                  future: _userData,
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    if (snapshot.hasError) {
                      nameController.text = 'Что то пошло не так..';
                      phoneController.text = 'Что то пошло не так..';
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          TextField(
                            controller: nameController,
                            readOnly: true,
                            decoration: const InputDecoration(
                              prefixIcon: Text('Имя: ', style: TextStyle(fontWeight: FontWeight.bold)),
                              prefixIconConstraints: BoxConstraints(minWidth: 0, minHeight: 0),
                            ),
                          ),
                          TextField(
                            keyboardType: TextInputType.phone,
                            controller: phoneController,
                            readOnly: true,
                            maxLength: 30,
                            decoration: const InputDecoration(
                              prefixIcon: Text('Тел.: ', style: TextStyle(fontWeight: FontWeight.bold)),
                              prefixIconConstraints: BoxConstraints(minWidth: 0, minHeight: 0),
                            ),
                          ),
                          Visibility(
                            visible: isDoc,
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Row(
                                children: const <Widget>[
                                  Text('Опыт работы с:', style: TextStyle(color: Colors.black, fontSize: 15)),
                                  TextButton(
                                    onPressed: null,
                                    child: Text('Что то пошло не так..', style: TextStyle(color: Colors.blue, fontSize: 15, decoration: TextDecoration.underline)),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    }
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      nameController.text = 'Загрузка данных..';
                      phoneController.text = 'Загрузка данных..';
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          TextField(
                            controller: nameController,
                            readOnly: true,
                            decoration: const InputDecoration(
                              prefixIcon: Text('Имя: ', style: TextStyle(fontWeight: FontWeight.bold)),
                              prefixIconConstraints: BoxConstraints(minWidth: 0, minHeight: 0),
                            ),
                          ),
                          TextField(
                            keyboardType: TextInputType.phone,
                            controller: phoneController,
                            readOnly: true,
                            maxLength: 30,
                            decoration: const InputDecoration(
                              prefixIcon: Text('Тел.: ', style: TextStyle(fontWeight: FontWeight.bold)),
                              prefixIconConstraints: BoxConstraints(minWidth: 0, minHeight: 0),
                            ),
                          ),
                          Visibility(
                            visible: isDoc,
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Row(
                                children: const <Widget>[
                                  Text('Опыт работы с:', style: TextStyle(color: Colors.black, fontSize: 15)),
                                  TextButton(
                                    onPressed: null,
                                    child: Text('Загрузка данных..', style: TextStyle(color: Colors.blue, fontSize: 15, decoration: TextDecoration.underline)),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    }
                    if (snapshot.hasData) {
                      nameController.text = snapshot.data.docs[0]['name'].toString();
                      phoneController.text = snapshot.data.docs[0]['phone'].toString();
                      int expDate = snapshot.data.docs[0]['experience'];
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          TextField(
                          controller: nameController,
                          decoration: InputDecoration(
                              prefixIcon: const Text('Имя: ', style: TextStyle(fontWeight: FontWeight.bold)),
                              prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                              hintText: nameController.text.trim().isEmpty
                                  ? 'Имя не указано'
                                  : null),
                          ),
                          TextField(
                            onTap: (){
                              if(phoneController.text.trim().isEmpty){
                                phoneController.text = '+994';
                              }
                            },
                            keyboardType: TextInputType.phone,
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter.allow(RegExp('[0-9+]'))
                            ],
                            maxLength: 13,
                            controller: phoneController,
                            decoration: InputDecoration(
                              prefixIcon: const Text('Тел.: ', style: TextStyle(fontWeight: FontWeight.bold)),
                              prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                                hintText: phoneController.text.trim().isEmpty
                                    ? 'Введите номер телефона'
                                    : null,
                            ),
                          ),
                          Visibility(
                            visible: isDoc,
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Row(
                                children: <Widget>[
                                  const Text('Опыт работы с:', style: TextStyle(color: Colors.black, fontSize: 15)),
                                  StatefulBuilder(builder:
                                    (BuildContext context, StateSetter setState) {
                                      return TextButton(
                                        onPressed: () => _selectDate(context).then((value) => setState((){})),
                                        child: Text(expDate > 0 ? DateFormat('dd/MM/yyyy').format(DateTime.fromMillisecondsSinceEpoch(expDate)).toString() : DateFormat('dd/MM/yyyy').format(selectedDate).toString(), style: const TextStyle(color: Colors.blue, fontSize: 15, decoration: TextDecoration.underline)),
                                      );
                                    }),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    } else {
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          TextField(
                            controller: nameController,
                            readOnly: true,
                            // inputFormatters: <TextInputFormatter>[
                            //   FilteringTextInputFormatter.allow(RegExp('[0-9+]'))
                            // ],
                            decoration: const InputDecoration(
                              prefixIcon: Text('Имя: ', style: TextStyle(fontWeight: FontWeight.bold)),
                              prefixIconConstraints: BoxConstraints(minWidth: 0, minHeight: 0),
                              hintText: 'Имя не указано',
                            ),
                          ),
                          TextField(
                            keyboardType: TextInputType.phone,
                            controller: phoneController,
                            readOnly: true,
                            maxLength: 30,
                            decoration: const InputDecoration(
                              prefixIcon: Text('Тел.: ', style: TextStyle(fontWeight: FontWeight.bold)),
                              prefixIconConstraints: BoxConstraints(minWidth: 0, minHeight: 0),
                              hintText: 'Введите номер телефона'
                            ),
                          ),
                          Visibility(
                            visible: isDoc,
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Row(
                                children: const <Widget>[
                                  Text('Опыт работы с:', style: TextStyle(color: Colors.black, fontSize: 15)),
                                  TextButton(
                                    onPressed: null,
                                    child: Text('информация не указана', style: TextStyle(color: Colors.blue, fontSize: 15, decoration: TextDecoration.underline)),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    }
                  }),
              actions: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    TextButton(
                        onPressed: (() => Navigator.pop(context)),
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
                          'Отменить',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 19,
                              fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        )),
                    TextButton(
                        onPressed: () async {
                          await _userData.then((e) {
                            if (e.docs[0].data()['id_doctor'] != null) {
                              FirebaseFirestore.instance
                                  .collection('doctors/' +
                                      e.docs[0]
                                          .data()['id_category']
                                          .toString() +
                                      '/' +
                                      e.docs[0]
                                          .data()['id_category']
                                          .toString())
                                  .doc(e.docs[0].data()['id_doctor'].toString())
                                  .update({
                                'name': nameController.text.trim(),
                                'phone': phoneController.text.trim(),
                                'experience': selectedDate.millisecondsSinceEpoch
                              });
                            } else if (e.docs[0].data()['id_user'] != null) {
                              FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(e.docs[0].data()['id_user'].toString())
                                  .update({
                                'name': nameController.text.trim(),
                                'phone': phoneController.text.trim()
                              });
                            }
                          });
                          Navigator.pop(context);
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
                          'Сохранить',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 19,
                              fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        )),
                  ],
                ),
              ],
            );
          });
    }

    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * 0.325,
      padding: const EdgeInsets.all(15.0),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.blue,
            Colors.white,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          // mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                CircleAvatar(
                  backgroundColor: const Color.fromRGBO(0, 0, 255, 0),
                  child: IconButton(
                    onPressed: () {
                      _editUserData(context);
                    },
                    color: Colors.white,
                    icon: const Icon(Icons.edit),
                  ),
                ),
                CircleAvatar(
                  backgroundColor: const Color.fromRGBO(0, 0, 255, 0),
                  child: IconButton(
                    onPressed: () {
                      context.read<AuthenticationService>().signOut();
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SignInPage(),
                          ));
                    },
                    color: Colors.white,
                    icon: const Icon(Icons.logout),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Column(
                  children: <Widget>[
                    Image.asset(
                      'assets/images/user.png',
                      width: 75,
                    ),
                    Text(
                      FirebaseAuth.instance.currentUser!.email.toString(),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
