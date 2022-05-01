import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doc_app/api/get_data.dart';
import 'package:doc_app/auth/auth_service.dart';
import 'package:doc_app/auth/signin_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class TopBar extends StatelessWidget {
  const TopBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                    if (snapshot.hasData) {
                      // var _data = snapshot.data.docs[0];
                      nameController.text = snapshot.data.docs[0]['name'].toString();
                      phoneController.text = snapshot.data.docs[0]['phone'].toString();
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          TextField(
                            controller: nameController,
                            decoration: InputDecoration(
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
                              // FilteringTextInputFormatter.digitsOnly,
                              FilteringTextInputFormatter.allow(RegExp('[0-9+]'))
                            ],
                            maxLength: 13,
                            controller: phoneController,
                            decoration: InputDecoration(
                                hintText: phoneController.text.trim().isEmpty
                                    ? 'Номер не указан'
                                    : null),
                          ),
                        ],
                      );
                    } else {
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          TextField(
                            controller: nameController,
                            // decoration: const InputDecoration(hintText: "Нет данных"),
                          ),
                          TextField(
                            keyboardType: TextInputType.phone,
                            controller: phoneController,
                            // decoration: const InputDecoration(hintText: "Нет данных"),
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
                                'phone': phoneController.text.trim()
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
