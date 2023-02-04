import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path/path.dart';
import 'package:trial/services/auth/auth_service.dart';
import 'package:trial/services/auth/block/auth_bloc.dart';
import 'package:trial/services/auth/block/auth_events.dart';
import 'package:trial/services/auth/block/auth_state.dart';
import 'package:trial/services/auth/firebase_auth_provider.dart';
import 'package:trial/view/login_view.dart';
import 'package:trial/view/notes/create_update_notes_view.dart';
import 'package:trial/view/notes/notes_view.dart';
import 'package:trial/view/register_view.dart';
import 'package:trial/view/verify_email.dart';

import 'constant/route.dart';
import 'firebase_options.dart';

void main()  {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: BlocProvider<AuthBloc>(
          create: (context) => AuthBloc(FirebaseAuthProvider()),
          child: const Homepage(),
      ),
      //ROUTES
      routes: {
        loginRoute: (context) => const LoginView(),
        registerRoute: (context) => const RegisterView(),
        notesRoute: (context) => const NotesView(),
        verifyEmailRoute: (context) => const verifyEmail(),
        createOrUpdateNoteRoute: (context) => const CreateUpdateNoteView(),
      },
    ),
  );
}

class Homepage extends StatelessWidget {
  const Homepage({Key? key}) : super(key: key);

  get z => null;

  @override
  Widget build(BuildContext context) {
    context.read<AuthBloc>().add(const AuthEventInitialize());
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state){
        if (state is AuthStateLoggedIn) {
          return const NotesView();
        }else if (state is AuthStateNeedsVerification){
          return const verifyEmail();
        }else if (state is AuthStateLoggedOut) {
          return const LoginView();
        }else {
          return const Scaffold(
            body: CircularProgressIndicator(),
          );
        }
    }, );


  }
}


