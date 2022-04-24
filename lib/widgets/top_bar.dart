import 'package:doc_app/auth/auth_service.dart';
import 'package:doc_app/auth/signin_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TopBar extends StatelessWidget {
  const TopBar({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
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
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                CircleAvatar(
                  backgroundColor: const Color.fromRGBO(0, 0, 255, 0),
                  child: IconButton(
                    onPressed: () {
                      context.read<AuthenticationService>().signOut();
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SignInPage(),
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
                    Text(FirebaseAuth.instance.currentUser!.email.toString(), textAlign: TextAlign.center,),
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
