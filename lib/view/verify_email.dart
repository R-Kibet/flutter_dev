import 'package:flutter/material.dart';
import 'package:trial/constant/route.dart';
import 'package:trial/services/auth/auth_service.dart';

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
        TextButton(onPressed: ()  async {

          // get current user
          final user = AuthService.firebase().currentUser;

          //await for user to reply
          await AuthService.firebase().sendEmailVerification();

        },
          child: const Text("send email verification"),
        ),
        TextButton(
            onPressed: (){
              AuthService.firebase().logout();
              Navigator.of(context).pushNamedAndRemoveUntil(
                registerRoute,
                    (route) => false,
              );
            },
            child: const Text("Restart"),
        )
      ],
      ),
    );
  }
}
