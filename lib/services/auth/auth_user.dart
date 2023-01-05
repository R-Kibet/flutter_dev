import "package:firebase_auth/firebase_auth.dart" show User;
import 'package:flutter/foundation.dart';

@immutable //this class can't be changed upon being initialized
class AuthUser {
  final String? email;
  final bool isEmailVerified;
  const AuthUser({
    required this.email,
    required this.isEmailVerified,
  });

  factory AuthUser.fromFirebase(User user) => AuthUser(
        email: user.email,
        isEmailVerified: user.emailVerified,
      );
}
