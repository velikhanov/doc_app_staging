import 'package:doc_app/auth/auth_service.dart';
import 'package:doc_app/auth/signin_page.dart';
import 'package:doc_app/pages/home_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthenticationService>(
          create: (_) => AuthenticationService(FirebaseAuth.instance),
        ),
        StreamProvider(
          create: (context) => context.read<AuthenticationService>().authStateChanges, initialData: null,
        )
      ],
      child: MaterialApp(
        theme: ThemeData(
          primaryColor: Colors.blue[300],
          colorScheme: ColorScheme.fromSwatch().copyWith(secondary: Colors.blueAccent),
      ),
      title: 'Hello',
      home: const AuthenticationWrapper(),
      // home: const HomePage(),
    ),
    );
  }
}
class AuthenticationWrapper extends StatelessWidget {
  const AuthenticationWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final firebaseUser = context.watch<User?>();

    if (firebaseUser != null) {
      return const HomePage(false, '');
    }
    return const SignInPage();
  }
}