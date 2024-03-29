import 'package:firebase_core/firebase_core.dart';
import 'package:trial/services/auth/auth_user.dart';
import 'package:trial/services/auth/auth_provider.dart';
import 'package:trial/services/auth/auth_exceptions.dart';

import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth, FirebaseAuthException;

import '../../firebase_options.dart';

class FirebaseAuthProvider implements AuthProvider {

  @override
  Future<void> initialize() async {
    await  Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }


  @override
  Future<AuthUser> createUser({
    required String email,
    required String password,
  })
  async {
    try{
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: password,
      );
      final user = currentUser;
      if (user != null){
        return user;
      }
      else {
        throw UserNotLoggedInAuthexception();
      }
    } on FirebaseAuthException catch(e) {
      if (e.code == "weak-password") {
        throw WeakPasswordAuthException();
      }else if (e.code == 'email-already-in-use'){
        throw EmailAlreadyinUseAuthException();
      }else if (e.code == 'invalid-email'){
        throw InvalidEmailException();
      } else {
        throw GenericAuthException();
      }
    }catch (_){
      throw GenericAuthException();
    }
  }

  @override
  AuthUser? get currentUser {
    final user =  FirebaseAuth.instance.currentUser;
    if (user != null){
      return AuthUser.fromFirebase(user);
    }
    else{
      return null;
    }
  }

  @override
  Future<AuthUser> login({
    required String email,
    required String password,
  }) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
      );
      final user = currentUser;
      if (user != null){
        return user;
      }
      else{
        throw UserNotLoggedInAuthexception();
      }
    }on FirebaseAuthException catch (e){
      if (e.code == "user-not-found") {
        throw UserNotFoundAuthException();
      } else if (e.code == "wrong-password") {
        throw WrongPassAuthException();
      } else {
        throw GenericAuthException();
      }
    } catch (e){
      throw GenericAuthException();
    }
  }

  @override
  Future<void> logout() async {
    final user =  FirebaseAuth.instance.currentUser;
    if (user != null){
      await FirebaseAuth.instance.signOut();
    }else{
      throw UserNotLoggedInAuthexception();
    }
  }

  @override
  Future<void> sendEmailVerification() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null){
      await user.sendEmailVerification();
    }
    else {
      throw UserNotLoggedInAuthexception();
    }
  }



  @override
  Future<void> sendPasswordReset({required String toEmail}) async{
   try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: toEmail);
   }on FirebaseAuthException catch(e){
     switch(e.code){
       case "firebase_auth/invalid-email":
         throw InvalidEmailException();
       case "firebase-auth/user-not-found":
         throw UserNotFoundAuthException();
       default:
         throw GenericAuthException();
     }
   }catch (_){
     throw GenericAuthException();
   }
  }
}