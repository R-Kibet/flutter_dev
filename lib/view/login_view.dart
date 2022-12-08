import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:developer' show log;

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
    return  Scaffold(
      appBar: AppBar(title: const Text("Login"),),
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
                // we are login in so use sign in
                // always put await as its a future function
                await FirebaseAuth.instance
                    .signInWithEmailAndPassword(
                    email: email,
                    password: password
                );
                Navigator.of(context).pushNamedAndRemoveUntil(
                    "/notes/",
                        (route) => false,
                );
              }on FirebaseAuthException
              catch (e){
                if (e.code == "user-not-found") {
                  log('user not found');
                }
                else if (e.code == "wrong-password") {
                  log("wrong password");
                }
                log(e.runtimeType.toString()); // give which class of exception this is
              }
            },
            child: const Text('Login'),
          ),
          TextButton(
              onPressed: () {
                //removes everything till new widget
                Navigator.of(context).pushNamedAndRemoveUntil(
                    "/register",
                        (route) => false);
              },
              child: const Text("Not yet registered"))
        ],
      ),
    );
  }

 
}