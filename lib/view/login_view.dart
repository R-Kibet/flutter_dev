import 'package:flutter/material.dart';
import 'dart:developer' show log;

import 'package:trial/constant/route.dart';
import 'package:trial/services/auth/auth_service.dart';

import '../utilities/dialogs/error_dialog.dart';
import 'package:trial/services/auth/auth_exceptions.dart';

class LoginView extends StatefulWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final TextEditingController _email;
  late final TextEditingController _password;

  @override
  void initState() {
    // TODO: implement initState
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  //never forget to dispose
  @override
  void dispose() {
    // TODO: implement dispose
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login"),
      ),
      body: Column(
        children: [
          TextField(
            controller: _email,
            enableSuggestions: false,
            autocorrect: false,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              hintText: "Enter your Email",
            ),
          ),
          TextField(
            controller: _password,
            obscureText: true,
            enableSuggestions: false,
            autocorrect: false,
            decoration: const InputDecoration(
              hintText: "Enter your Password",
            ),
          ),
          TextButton(
            onPressed: () async {
              final email = _email.text;
              final password = _password.text;

              try {
                // we are login in so use sign in
                // always put await as its a future function
                await AuthService.firebase().login(
                  email: email,
                  password: password,
                );
                final user = AuthService
                    .firebase()
                    .currentUser;
                if (user?.isEmailVerified ?? false) {
                  //user verified
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    notesRoute,
                        (route) => false,
                  );
                } else {
                  //user not verified
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    verifyEmailRoute,
                        (route) => false,
                  );
                }
              } on UserNotFoundAuthException {
                await showErrorDialog(
                  context,
                  "user not found",
                );
              } on WrongPassAuthException {
                log("wrong password");
                await showErrorDialog(
                  context,
                  "Wrong Credentials",
                );
              } on GenericAuthException {
                await showErrorDialog(
                  context,
                  "Authentication Error",
                );
              }
            },
            child: const Text('Login'),
          ),
          TextButton(
              onPressed: () {
                //removes everything till new widget
                Navigator.of(context)
                    .pushNamedAndRemoveUntil(registerRoute, (route) => false);
              },
              child: const Text("Not yet registered"))
        ],
      ),
    );
  }
}
