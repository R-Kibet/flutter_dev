import 'package:bloc/bloc.dart';
import 'package:trial/services/auth/auth_provider.dart';
import 'package:trial/services/auth/block/auth_events.dart';
import 'package:trial/services/auth/block/auth_state.dart';

///create logic
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(AuthProvider provider) : super(const AuthStateUninitialized ()) {

    ///send email verification
    on<AuthEventSendEmailVerification>((event, emit) async {
      await provider.sendEmailVerification();
      emit(state);
    });

    ///event register
    on<AuthEventRegister>((event, emit) async {
      final email = event.email;
      final password = event.password;

      try{
        await provider.createUser(
          email: email,
          password: password,
        );
        await provider.sendEmailVerification();
        emit(const AuthStateNeedsVerification());
      }on Exception catch (e) {
        emit(AuthStateRegistering(e));
      }
    });

    ///initialize event logic
    on<AuthEventInitialize>((event, emit) async {
      await provider.initialize();
      final user = provider.currentUser;
      if (user == null) {
        emit(
            const AuthStateLoggedOut(
                exception: null,
                isLoading: false,
            ));
      } else if (!user.isEmailVerified) {
        emit(const AuthStateNeedsVerification());
      }else {
        emit(AuthStateLoggedIn(user));
      }
    });

    /// login event logic

    on <AuthEventLogin>((event, emit) async {
      emit(
        const AuthStateLoggedOut(
            exception: null,
            isLoading: true,
        )
      );
      final email = event.email;
      final password = event.password;
      try {
        final user = await provider.login(
          email: email,
          password: password,
        );

        if (!user.isEmailVerified) {
          emit(
              const AuthStateLoggedOut(
                exception: null,
                isLoading: false,
              ));
          emit(const AuthStateNeedsVerification());
        }else {
          emit(
              const AuthStateLoggedOut(
                exception: null,
                isLoading: false,
              ));
          emit(AuthStateLoggedIn(user));
        }

      }on Exception catch (e) {
        emit(
            AuthStateLoggedOut(
              exception: e,
              isLoading: false,
            ));
      }
    });

    ///logout event
    on<AuthEventLoggOut>((event, emit) async {
      try{
        await provider.logout();
        emit (
            const AuthStateLoggedOut(
              exception: null,
              isLoading: false,
            ));
      }on Exception catch (e) {
       emit (
           AuthStateLoggedOut(
               exception: e,
               isLoading: false,
           ));
      }
    });
  }
}
