import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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
        const Text("verify your Email"),
        TextButton(onPressed: ()  async {

          // get current user
          final user = FirebaseAuth.instance.currentUser;

          //await for user to reply
          //TODO ; ALWAYS REMEMBER TO MARK ASYNC -AWAIT
          await user?.sendEmailVerification();

        },
          child: const Text("send email verification"),
        )
      ],
      ),
    );
  }
}
