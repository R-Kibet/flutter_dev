import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'dart:developer' show log;
import '../firebase_options.dart';

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
    return  Scaffold(
      appBar: AppBar(title: const Text("Register"),),
      body: Column(
        children: [
          TextField(
            controller: _email,
            enableSuggestions: false,
            autocorrect: false,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              hintText: "Enter your Email" ,
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
                final usercred = await FirebaseAuth.instance
                    .createUserWithEmailAndPassword(
                    email: email,
                    password: password
                );
                log(usercred.toString());
              }on FirebaseAuthException
              catch (e) {
                if (e.code == "weak-password") {
                  log("weak-password");
                }else if (e.code == 'email-already-in-use'){
                  log("email i i use");
                }
                else if (e.code == 'invalid-email'){
                  log("invalid email");
                }
                else {
                  log(e.toString());
                }
              }
            },
            child: const Text('Register'),
          ),
          TextButton(
              onPressed: (){
                Navigator.of(context).pushNamedAndRemoveUntil(
                "/login",
                        (route) => false);
              },
              child: const Text("Login"))
        ],
      ),
    );
  }
}
