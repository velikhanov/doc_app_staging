import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doc_app/api/get_data.dart';
import 'package:doc_app/auth/auth_service.dart';
import 'package:doc_app/auth/signin_page.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SignUpPage();
}

class _SignUpPage extends State<SignUpPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color.fromRGBO(40, 38, 56, 1),
      body: const SignUpPageContent(),
      bottomNavigationBar: BottomAppBar(
          color: Colors.transparent,
          elevation: 0,
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Text(
              "DocAppNet, Inc - " +
                  DateFormat.y()
                      .format(DateTime.parse(DateTime.now().toString()))
                      .toString() +
                  '\nAll right reserved',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 17.5,
              ),
              textAlign: TextAlign.center,
            ),
          )),
    );
  }
}

class SignUpPageContent extends StatefulWidget {
  const SignUpPageContent({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SignUpPageContent();
}

class _SignUpPageContent extends State<SignUpPageContent> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController passwordControllerConf = TextEditingController();
  bool isdoc = false;
  final Future<QuerySnapshot> _items =
      getCategoriesSignUp('categories/1/doctors');
  int userId = 1;
  int doctorId = 1;
  int roleId = 1;
  var _docCount = getDoctorData('users', lastId: true);
  final _roleCount = getUserRole('roles');
  bool firstOpen = true;
  String dropdownvalue = 'Терапевт';
  int categoryId = 1;
  bool _isVisible = false;
  bool _isObscure1 = true;
  bool _isObscure2 = true;
  String returnVisibilityString = "";

  @override
  Widget build(BuildContext context) {
    if (firstOpen == true) {
      _roleCount.then((value) {
        roleId = value.size + 1;
      });
    }
    if (firstOpen == true && isdoc == true) {
      _docCount.then((val) {
        doctorId = val.size + 1;
      });
    }

    if (isdoc == false) {
      _docCount.then((val) {
        userId = val.size + 1;
      });
    }
    return SingleChildScrollView(
      reverse: true,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          // Sized Box
          const SizedBox(
            height: 37.5,
            width: 400,
          ),

          // Signup Text
          Center(
            child: Container(
              height: 175,
              width: 400,
              alignment: Alignment.center,
              child: const Text(
                "Регистрация",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // Wrong password text
          Visibility(
            visible: _isVisible,
            maintainSize: true,
            maintainAnimation: true,
            maintainState: true,
            child: Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.all(10),
              child: Text(
                returnVisibilityString,
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 10,
                ),
              ),
            ),
          ),

          // Signup Info
          Container(
            height: 215,
            width: 530,
            decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(20)),
                color: Colors.white),
            child: Column(
              children: <Widget>[
                TextFormField(
                  onTap: () {
                    setState(() {
                      _isVisible = false;
                    });
                  },
                  controller: nameController, // Controller for Username
                  decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: "Введите ваше имя",
                      contentPadding: EdgeInsets.all(20)),
                  onEditingComplete: () => FocusScope.of(context).nextFocus(),
                ),
                const Divider(
                  thickness: 7.5,
                  color: Color.fromRGBO(40, 38, 56, 1),
                ),
                TextFormField(
                  onTap: () {
                    setState(() {
                      _isVisible = false;
                    });
                  },
                  controller: emailController, // Controller for Username
                  decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: "Введите E-mail адресс",
                      contentPadding: EdgeInsets.all(20)),
                  onEditingComplete: () => FocusScope.of(context).nextFocus(),
                ),
                const Divider(
                  thickness: 7.5,
                  color: Color.fromRGBO(40, 38, 56, 1),
                ),
                TextFormField(
                  onTap: () {
                    setState(() {
                      _isVisible = false;
                    });
                  },

                  controller: passwordController, // Controller for Password
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: "Пароль",
                      contentPadding: const EdgeInsets.all(20),
                      // Adding the visibility icon to toggle visibility of the password field
                      suffixIcon: IconButton(
                        icon: Icon(_isObscure1
                            ? Icons.visibility_off
                            : Icons.visibility),
                        onPressed: () {
                          setState(() {
                            _isObscure1 = !_isObscure1;
                          });
                        },
                      )),
                  obscureText: _isObscure1,
                ),
                const Divider(
                  thickness: 7.5,
                  color: Color.fromRGBO(40, 38, 56, 1),
                ),
                TextFormField(
                  onTap: () {
                    setState(() {
                      _isVisible = false;
                    });
                  },
                  controller: passwordControllerConf, // Controller for Password
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: "Повторите пароль",
                      contentPadding: const EdgeInsets.all(20),
                      // Adding the visibility icon to toggle visibility of the password field
                      suffixIcon: IconButton(
                        icon: Icon(_isObscure2
                            ? Icons.visibility_off
                            : Icons.visibility),
                        onPressed: () {
                          setState(() {
                            _isObscure2 = !_isObscure2;
                          });
                        },
                      )),
                  obscureText: _isObscure2,
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              isdoc == true
                  ? const Text('Я врач',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17.5,
                      ))
                  : const Text('Я пациент',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17.5,
                      )),
              Switch(
                value: isdoc,
                onChanged: (value) {
                  setState(() {
                    isdoc = value;
                    if (firstOpen == true && isdoc == true) {
                      _docCount = getDoctorData('doctors/1/1', lastId: true);
                    } else if (firstOpen == false && isdoc == false) {
                      _docCount = getDoctorData('users', lastId: true);
                    } else {
                      _docCount = getDoctorData('users', lastId: true);
                    }
                  });
                },
                activeTrackColor: Colors.lightGreenAccent,
                activeColor: Colors.green,
              ),
            ],
          ),
          isdoc == true
              ? FutureBuilder<QuerySnapshot>(
                  future: _items,
                  builder: (_, snapshot) {
                    if (snapshot.hasError) {
                      return const Text(
                        'Ошибка во время загрузки категорий..',
                        style: TextStyle(color: Colors.red, fontSize: 17.5),
                        textAlign: TextAlign.center,
                      );
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Text(
                        'Загрузка категорий..',
                        style: TextStyle(
                          color: Color.fromARGB(255, 88, 171, 238),
                          fontSize: 17.5,
                        ),
                        textAlign: TextAlign.center,
                      );
                    }

                    if (snapshot.hasData) {
                      List<QueryDocumentSnapshot<Object?>> _data =
                          snapshot.data!.docs;
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Категория',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 17.5,
                              )),
                          const SizedBox(
                            width: 15,
                          ),
                          DropdownButton(
                            value: dropdownvalue,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 17.5,
                            ),
                            alignment: AlignmentDirectional.center,
                            dropdownColor: Colors.black,
                            icon: const Icon(Icons.keyboard_arrow_down),
                            items: _data.map((items) {
                              return DropdownMenuItem(
                                value: items['category'],
                                child: Text(items['category']),
                                onTap: () => setState(() {
                                  firstOpen = false;
                                  categoryId = items['id_category'] as int;
                                  _docCount = getDoctorData(
                                      'doctors/' +
                                          items['id_category'].toString() +
                                          '/' +
                                          items['id_category'].toString(),
                                      lastId: true);
                                  _docCount.then((val) {
                                    doctorId = val.size + 1;
                                  });
                                }),
                              );
                            }).toList(),
                            onChanged: (newValue) {
                              setState(() {
                                dropdownvalue = newValue.toString();
                              });
                            },
                          ),
                        ],
                      );
                    } else {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text('Категория',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 17.5,
                              )),
                          SizedBox(
                            width: 15,
                          ),
                          Text('Нет доступных категорий',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 17.5,
                                decoration: TextDecoration.underline,
                              )),
                        ],
                      );
                    }
                  })
              : const SizedBox(
                  height: 0,
                  width: 0,
                ),
          // Signup Submit button
          Container(
            width: 570,
            height: 70,
            padding: const EdgeInsets.only(top: 20),
            child: ElevatedButton(
              style: ButtonStyle(
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                ),
              ),
              onPressed: () {
                if (nameController.text.trim().isEmpty &&
                    emailController.text.trim().isEmpty &&
                    passwordController.text.trim().isEmpty &&
                    passwordController.text.trim() !=
                        passwordControllerConf.text.trim()) {
                  return;
                } else {
                  FocusManager.instance.primaryFocus?.unfocus();
                  if (isdoc == true) {
                    context.read<AuthenticationService>().signUp(
                        nameController.text.trim(),
                        emailController.text.trim(),
                        passwordController.text.trim(),
                        isdoc: isdoc,
                        categoryId: categoryId,
                        doctorId: doctorId,
                        categoryName: dropdownvalue,
                        lastRole: roleId);
                  } else {
                    context.read<AuthenticationService>().signUp(
                        nameController.text.trim(),
                        emailController.text.trim(),
                        passwordController.text.trim(),
                        userId: userId,
                        lastRole: roleId);
                  }
                }
              },
              child: const Text("Зарегистрироваться",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                  )),
            ),
          ),

          // Registered yet
          SizedBox(
            width: 570,
            height: 40,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Text('Есть аккаунт?',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                    )),
                TextButton(
                    onPressed: (() => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SignInPage(),
                        ))),
                    child: const Text('Войти',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17.5,
                          decoration: TextDecoration.underline,
                        ))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
