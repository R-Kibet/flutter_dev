import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trial/services/auth/block/auth_bloc.dart';
import 'package:trial/services/auth/block/auth_events.dart';
import 'package:trial/services/auth/block/auth_state.dart';
import 'package:trial/utilities/dialogs/loading_dialog.dart';

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
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async{
        // TODO: handle 3 auth exceptions
        /// user not found
        /// wrong password
        /// generic auth exception
        if (state is AuthStateLoggedOut) {
          if (state.exception is UserNotFoundAuthException) {
            await showErrorDialog(context, "User not found");
          } else if (state.exception is WrongPassAuthException) {
            await showErrorDialog(context, "Wrong credential");
          } else if (state.exception is GenericAuthException) {
            await showErrorDialog(context, "Authentication Error");
          }
        }
      },
      child: Scaffold(
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
                  context.read<AuthBloc>().add(
                    AuthEventLogin(
                      email,
                      password,
                    ),
                  );
                },
                child: const Text('Login'),
              ),
            TextButton(
                onPressed: () {
                  context.read<AuthBloc>().add(
                      const AUthEventShouldRegister(),
                  );
                },
                child: const Text("Not yet registered"))
          ],
        ),
      ),
    );
  }
}
