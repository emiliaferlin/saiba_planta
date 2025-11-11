import 'package:flutter/material.dart';
import 'package:trabalho_final/src/view/login/login_view.dart';
import 'package:trabalho_final/src/view/login/registrar_email_view.dart';

class LoginOuRegistrar extends StatefulWidget {
  const LoginOuRegistrar({super.key});

  @override
  State<LoginOuRegistrar> createState() => _LoginOuRegistrarState();
}

class _LoginOuRegistrarState extends State<LoginOuRegistrar> {
  bool estaNoLogin = true;

  void togglePages() {
    setState(() {
      estaNoLogin = !estaNoLogin;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (estaNoLogin) {
      return LoginView(onTap: togglePages);
    } else {
      return RegistrarEmailView(onTap: togglePages);
    }
  }
}
