import 'package:flutter/material.dart';
import 'package:trial/constant/route.dart';
import 'package:trial/services/auth/auth_exceptions.dart';
import 'package:trial/services/auth/auth_service.dart';
import 'dart:developer' show log;
import '../utilities/dialogs/error_dialog.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({Key? key}) : super(key: key);

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
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
        title: const Text("Register"),
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
                // always put await as its a future function
                await AuthService.firebase().createUser(
                  email: email,
                  password: password,
                );
                final user = AuthService.firebase().currentUser;
                AuthService.firebase().sendEmailVerification();
                Navigator.of(context).pushNamed(verifyEmailRoute);
              }on WeakPasswordAuthException{
                log("weak-password");
                await showErrorDialog(
                  context,
                  "weak password",
                );
              } on  EmailAlreadyinUseAuthException{
                await showErrorDialog(
                  context,
                  "Email already in use",
                );
              } on InvalidEmailException {
                await showErrorDialog(
                  context,
                  "Invalid Email",
                );
              }on GenericAuthException{
                await showErrorDialog(
                  context,
                  "Registration Error",
                );
              }
            },
            child: const Text('Register'),
          ),
          TextButton(
              onPressed: () {
                Navigator.of(context)
                    .pushNamedAndRemoveUntil(loginRoute, (route) => false);
              },
              child: const Text("Login"))
        ],
      ),
    );
  }
}
