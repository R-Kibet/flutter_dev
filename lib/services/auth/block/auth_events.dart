import 'package:flutter/cupertino.dart';

@immutable
abstract class AuthEvent {
  const AuthEvent();
}

class AuthEventInitialize extends AuthEvent {
  const AuthEventInitialize();
}

class AuthEventSendEmailVerification extends AuthEvent {
  const AuthEventSendEmailVerification();
}

class AuthEventLogin extends AuthEvent {
  final String email;
  final String password;

  const AuthEventLogin(
    this.email,
    this.password,
  );
}

class AuthEventRegister extends AuthEvent {
  final String email;
  final String password;

  const AuthEventRegister(
    this.email,
    this.password,
  );
}

class AUthEventShouldRegister extends AuthEvent{
  const AUthEventShouldRegister();
}

class AuthEventLoggOut extends AuthEvent {
  const AuthEventLoggOut();
}