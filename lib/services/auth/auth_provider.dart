//gets current user
import 'package:trial/services/auth/auth_user.dart';

//create abstract class
//abstract class doestn contain logic

abstract class AuthProvider{
  Future<void> initialize();
  AuthUser? get currentUser;
  Future<AuthUser> login({
    required String email,
    required String password,
  });
  Future<AuthUser> createUser({
    required String email,
    required String password,
});
  Future<void> sendEmailVerification();
  Future<void> logout();
  Future<void> sendPasswordReset({required String toEmail});
}