import 'dart:developer' show log;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:trial/view/login_view.dart';
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
            final user = FirebaseAuth.instance.currentUser;
            if (user != null){
              if (user.emailVerified){
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

enum MenuAction { logout }


class NotesView extends StatefulWidget {
  const NotesView({Key? key}) : super(key: key);

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("main ui"),
        
        actions: [
          PopupMenuButton<MenuAction>(
            onSelected: (value) async{
              switch (value){

                case MenuAction.logout:
                  final shouldlogout = await showLogoutDialog(context);
                  if (shouldlogout) {
                     await FirebaseAuth.instance.signOut();
                     Navigator.of(context).pushNamedAndRemoveUntil(
                         loginRoute,
                             (route) => false,
                     );
                  }
                  log(shouldlogout.toString());
                  break;
              }
              log(value.toString());
            },
            itemBuilder: (context) {
              return const [
                 PopupMenuItem<MenuAction> (
                  value: MenuAction.logout,
                  child: Text ("Log out"),
              )
              ];
            },
          )
        ],
      ),
      body: const Text("hello world"),
    );
  }
}

Future<bool> showLogoutDialog(BuildContext context) {
  return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("sign out"),
          content: const Text("are yo sure you want to sign out"),
          actions: [
            TextButton(
                onPressed: (){
                  Navigator.of(context).pop(false);
                },
                child: const Text("Cancel"),),

            TextButton(
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
                child: const Text("Log out"),)
          ],
        );
  },
  ).then((value) => value ?? false);
  
}






