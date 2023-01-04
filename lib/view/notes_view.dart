import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:trial/services/auth/auth_service.dart';
import 'package:trial/services/crud/notes_service.dart';
import '../constant/route.dart';
import '../enums/menu_action.dart';

class NotesView extends StatefulWidget {
  const NotesView({Key? key}) : super(key: key);

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  //get/grab user email  so we can put in auth user
  String get userEmail => AuthService.firebase().currentUser!.email!;

  late final NotesService _notesService;

  /// require database to be open so as to read
  /// we need note service
  @override
  void initState() {
    _notesService = NotesService();
    super.initState();
  }

  ///remember to close the db
  @override
  void dispose() {
    _notesService.close();
    super.dispose();
  }

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
      body: FutureBuilder(
        future: _notesService.getOrCreateUser(email: userEmail),
        builder: (context, snapshot){
         switch (snapshot.connectionState){
           case ConnectionState.done:
             return StreamBuilder(
               stream: _notesService.allNotes,
               builder: (context, snapshot){
                 switch (snapshot.connectionState){
                   case ConnectionState.waiting:
                     return const Text("waiting for all notes...");
                   default:
                     return const CircularProgressIndicator();
                 }
               },
             );
           default:
             return const CircularProgressIndicator();

         }

        },
      ),
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