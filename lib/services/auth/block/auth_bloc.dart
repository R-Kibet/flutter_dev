import 'package:bloc/bloc.dart';
import 'package:trial/services/auth/auth_provider.dart';
import 'package:trial/services/auth/block/auth_events.dart';
import 'package:trial/services/auth/block/auth_state.dart';

///create logic
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(AuthProvider provider) : super(const AuthStateLoading ()) {

    ///initialize event logic

    on<AuthEventInitialize>((event, emit) async {
      await provider.initialize();
      final user = provider.currentUser;
      if (user == null) {
        emit(const AuthStateLoggedOut(null));
      } else if (!user.isEmailVerified) {
        emit(const AuthStateNeedsVerification());
      }else {
        emit(AuthStateLoggedIn(user));
      }
    });

    /// login event logic

    on <AuthEventLogin>((event, emit) async {
      final email = event.email;
      final password = event.password;
      try {
        final user = await provider.login(
          email: email,
          password: password,
        );
        emit(AuthStateLoggedIn(user));
      }on Exception catch (e) {
        emit(AuthStateLoggedOut(e));
      }
    });

    ///logout event
    on<AuthEventLoggOut>((event, emit) async {
      try{
        emit(const AuthStateLoading());
        await provider.logout();
        emit(const AuthStateLoggedOut(null));
      }on Exception catch (e) {
        emit(AuthStateLogoutFailure(e));
      }
    });
  }
}