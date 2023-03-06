import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trial/services/auth/block/auth_events.dart';

import '../services/auth/block/auth_bloc.dart';

//verify Email
class verifyEmail extends StatefulWidget {
  const verifyEmail({Key? key}) : super(key: key);

  @override
  State<verifyEmail> createState() => _verifyEmailState();
}

class _verifyEmailState extends State<verifyEmail> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Verify email"),),
      body: Column(children: [
        const Text("we have sent you an email verification please open to verify your account. "),
        const Text("if you haven't received a email , pres the button below"),
        TextButton(onPressed: () {
          context.read<AuthBloc>().add(
            const AuthEventSendEmailVerification()
          );
        },
          child: const Text("send email verification"),
        ),
        TextButton(
            onPressed: (){
              context.read<AuthBloc>().add(
                  const AuthEventLoggOut()
              );
            },
            child: const Text("Restart"),
        )
      ],
      ),
    );
  }
}
