import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trial/services/auth/block/auth_bloc.dart';
import 'package:trial/services/auth/block/auth_events.dart';
import 'package:trial/services/auth/block/auth_state.dart';
import 'package:trial/utilities/dialogs/error_dialog.dart';
import 'package:trial/utilities/dialogs/password_reset_email_sent_dialog.dart';

class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {

  ///editing controller
  late final TextEditingController _controller;

  @override
  void initState() {
    _controller = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc,AuthState>(
      listener: (context, state) async{
      if (state is AuthStateForgotPassword) {
        if (state.hasSentEmail){
          _controller.clear();
          await showPasswordResetSentDialog(context);
        }
        if (state.exception != null) {
          await showErrorDialog (context,
              'We could not process your request');
        }
      }
    }, child: Scaffold(
      appBar: AppBar(
        title: const Text("Forgot password"),
      ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const Text("We could not process your request"),
              TextField(
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                autofocus: true,
                controller: _controller,
                decoration: const InputDecoration(
                  hintText: "your email address...",
                ),
              ),
              TextButton(onPressed: () {
                final email = _controller.text;
                context
                    .read<AuthBloc>()
                    .add(AuthEventForgotPassword(email: email));
              },
                  child: const Text("Send me pass reset link")),
              TextButton(onPressed: () {
                context.read<AuthBloc>().add(
                  const AuthEventLoggOut()
                );
              },
                  child: const Text("back to login page"))
            ],
          ),
        )
    ),
    );
  }
}
