import "package:firebase_auth/firebase_auth.dart" show User;
import 'package:flutter/foundation.dart';

@immutable //this class can't be changed upon being initialized
class AuthUser {
  final bool isEmailVerified;
  const AuthUser(this.isEmailVerified);
  
  factory AuthUser.fromFirebase(User user) => AuthUser(user.emailVerified);
}