import 'package:doc_app/auth/auth_service.dart';
import 'package:doc_app/auth/signup_page.dart';
import 'package:doc_app/main.dart';
// import 'package:doc_app/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SignInPage();
}

class _SignInPage extends State<SignInPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color.fromRGBO(40, 38, 56, 1),
      body: const SignInPageContent(),
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

class SignInPageContent extends StatefulWidget {
  const SignInPageContent({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SignInPageContent();
}

class _SignInPageContent extends State<SignInPageContent> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _isVisible = false;
  bool _isObscure1 = true;
  String returnVisibilityString = "";

  @override
  Widget build(BuildContext context) {
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

          // SignIn Text
          Center(
            child: Container(
              height: 200,
              width: 400,
              alignment: Alignment.center,
              child: const Text(
                "Авторизация",
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

          // SignIn Info
          Container(
            height: 137.5,
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
              ],
            ),
          ),

          // SignIn Submit button
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
                FocusManager.instance.primaryFocus?.unfocus();
                context.read<AuthenticationService>().signIn(
                  emailController.text.trim(),
                  passwordController.text.trim(),
                );
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MyApp(),
                ));
            },
              child: const Text("Войти",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                  )),
            ),
          ),

          // Not registered yet
          SizedBox(
            width: 570,
            height: 40,
            // padding: const EdgeInsets.only(top: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Text('Еще не зарегистрированы?', style: TextStyle(color: Colors.white, fontSize: 15,)),
                TextButton(
                  onPressed: (() => 
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const SignUpPage(),
                  ))), 
                  child: const Text('Регистрация', style: TextStyle(color: Colors.white, fontSize: 17.5, decoration: TextDecoration.underline,))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
