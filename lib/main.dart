

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:trial/view/login_view.dart';
import 'package:trial/view/register_view.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(MaterialApp(
    title: 'Flutter Demo',
    theme: ThemeData(

      primarySwatch: Colors.blue,
    ),
    home: const Homepage(),
    //ROUTES
    routes: {
       "/login": (context) => const LoginView(),
       "/register": (context) => const RegisterView(),

    },
  ),
  );
}
class Homepage extends StatelessWidget {
  const Homepage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(

      future: Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      ),
      builder: (context, snapshot) {

        switch (snapshot.connectionState){

          case ConnectionState.done:
          //TODO ; Email verification
          //   final user = FirebaseAuth.instance.currentUser;
          //   if (user?.emailVerified ?? false){
          //     return const Text("Done");
          //   }else{
          //     return const verifyEmail();
          //   }
            return const LoginView();
          default :
            return const CircularProgressIndicator();
        }

      },
    );
  }
}





