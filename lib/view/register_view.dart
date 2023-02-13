import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trial/constant/route.dart';
import 'package:trial/services/auth/auth_exceptions.dart';
import 'package:trial/services/auth/auth_service.dart';
import 'package:trial/services/auth/block/auth_events.dart';
import 'dart:developer' show log;
import '../services/auth/block/auth_bloc.dart';
import '../services/auth/block/auth_state.dart';
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
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async{
        /// implement exceptions
        if (state is AuthStateRegistering) {
          if (state.exception is WeakPasswordAuthException){
            await showErrorDialog(context, "Weak Password");
          }else if (state.exception is EmailAlreadyinUseAuthException){
            await showErrorDialog(context, "Email already in use" );
          }else if (state.exception is InvalidEmailException) {
            await showErrorDialog(context, "Invalid Email");
          } else if (state.exception is GenericAuthException){
            await showErrorDialog(context, "Failed to Register");
          }
        }
      },
      child: Scaffold(
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
              context.read()<AuthBloc>().add(
                AuthEventRegister(
                  email,
                  password,
                ),
              );
              },
              child: const Text('Register'),
            ),
            TextButton(
                onPressed: () {
                context.read<AuthBloc>().add(
                  const AuthEventLoggOut(),
                );
                },
                child: const Text("Login"))
          ],
        ),
      ),
    );
  }
}
