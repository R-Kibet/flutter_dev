import 'package:flutter/material.dart';
import 'package:trial/services/auth/auth_service.dart';
import 'package:trial/view/login_view.dart';
import 'package:trial/view/notes_view.dart';
import 'package:trial/view/register_view.dart';
import 'package:trial/view/verify_email.dart';

import 'constant/route.dart';
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
       loginRoute: (context) => const LoginView(),
       registerRoute: (context) => const RegisterView(),
       notesRoute: (context) => const NotesView(),
      verifyEmailRoute: (context) => const verifyEmail()
    },
  ),
  );
}
class Homepage extends StatelessWidget {
  const Homepage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(

      future: AuthService.firebase().initialize(),
      builder: (context, snapshot) {

        switch (snapshot.connectionState){

          case ConnectionState.done:
          //TODO ; Email verification
            final user = AuthService.firebase().currentUser;
            if (user != null){
              if (user.isEmailVerified){
                // the application page
                return const NotesView();
              }
              else {
                return const verifyEmail();
              }
            }
             else {
              return const LoginView();
            }
            return const Text("DOne");
          default :
            return const CircularProgressIndicator();
        }

      },
    );
  }
}











