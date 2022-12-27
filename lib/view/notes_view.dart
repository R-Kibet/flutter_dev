import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:trial/services/auth/auth_service.dart';
import '../constant/route.dart';
import '../enums/menu_action.dart';

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
                    await AuthService.firebase().logout();
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