import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path/path.dart';
import 'package:trial/services/auth/auth_service.dart';
import 'package:trial/view/login_view.dart';
import 'package:trial/view/notes/create_update_notes_view.dart';
import 'package:trial/view/notes/notes_view.dart';
import 'package:trial/view/register_view.dart';
import 'package:trial/view/verify_email.dart';

import 'constant/route.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MaterialApp(
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
        verifyEmailRoute: (context) => const verifyEmail(),
        createOrUpdateNoteRoute: (context) => const CreateUpdateNoteView(),
      },
    ),
  );
}
/*
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
*/

class Homepage extends StatefulWidget {
  const Homepage({Key? key}) : super(key: key);

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
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
    return BlocProvider(
      create: (Context) => CounterBloc(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Test"),
        ),
        body: BlocConsumer<CounterBloc, CounterState>(
          listener: (contex, state) {
            _controller.clear();
          },
          builder: (context, state) {
            final invalidValue = (state is CounterStateInvalidNumber);
            return Column(
              children: [
                Text("current value => ${state.value}"),
                Visibility(
                  child: Text("invalid input $invalidValue"),
                  visible: state is CounterStateInvalidNumber,
                ),
                TextField(
                  controller: _controller,
                  decoration:
                      const InputDecoration(hintText: "Enter a number "),
                  keyboardType: TextInputType.number,
                ),
                Row(
                  children: [
                    TextButton(
                      onPressed: () {
                        context
                            .read<CounterBloc>()
                            .add(IncrementEvent(_controller.text));
                      },
                      child: const Text('+'),
                    ),
                    TextButton(
                      onPressed: (){
                        context
                            .read<CounterBloc>()
                            .add(DecrementEvent(_controller.text));
                      },
                      child: const Text('-'),
                    ),
                  ],
                )
              ],
            );
          },
        ),
      ),
    );
  }
}

@immutable
abstract class CounterState {
  final int value;
  const CounterState(this.value);
}

class CounterStateValid extends CounterState {
  const CounterStateValid(int value) : super(value);
}

class CounterStateInvalidNumber extends CounterState {
  final String invalidValue;
  const CounterStateInvalidNumber({
    required this.invalidValue,
    required int previousValue,
  }) : super(previousValue);
}

abstract class CounterEvent {
  final String value;
  const CounterEvent(this.value);
}

class IncrementEvent extends CounterEvent {
  const IncrementEvent(String value) : super(value);
}

class DecrementEvent extends CounterEvent {
  const DecrementEvent(String value) : super(value);
}

class CounterBloc extends Bloc<CounterEvent, CounterState> {
  CounterBloc() : super(const CounterStateValid(0)) {
    on<IncrementEvent>((event, emit) {
      final integer = int.tryParse(event.value);
      if (integer == null) {
        emit(
          CounterStateInvalidNumber(
            invalidValue: event.value,
            previousValue: state.value,
          ),
        );
      } else {
        emit(CounterStateValid(state.value + integer));
      }
    });
    on<DecrementEvent>((event, emit) {
      final integer = int.tryParse(event.value);
      if (integer == null) {
        emit(
          CounterStateInvalidNumber(
            invalidValue: event.value,
            previousValue: state.value,
          ),
        );
      } else {
        emit(CounterStateValid(state.value - integer));
      }
    });
  }
}
