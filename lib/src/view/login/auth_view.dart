import "package:firebase_auth/firebase_auth.dart";
import 'package:flutter/material.dart';
import 'package:trabalho_final/src/components/navigation_bar.dart';
import 'package:trabalho_final/src/view/login/login_ou_registrar.dart';

class AuthView extends StatefulWidget {
  const AuthView({super.key});
  @override
  State<AuthView> createState() {
    return AuthViewState();
  }
}

class AuthViewState extends State<AuthView> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: _auth.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return BottomNavigationBarApp(indexPage: 0);
          } else {
            return LoginOuRegistrar();
          }
        },
      ),
    );
  }
}
