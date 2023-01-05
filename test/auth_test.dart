import 'package:test/test.dart';
import 'package:trial/services/auth/auth_exceptions.dart';
import 'package:trial/services/auth/auth_provider.dart';
import 'package:trial/services/auth/auth_user.dart';

void main() {
  group("Mock Authentication", () {
    final provider = MockAuthProvider();
    test("Should not be initialized to begin with", () {
      expect(provider.isInitialized, false);
    });

    test("Cann't logout if not initialized", () {
      expect(
        provider.logout(),
        throwsA(const TypeMatcher<NotInitializedExceptions>()),
      );
    });

    test("Should be able to be initialized", () async {
      await provider.initialize();
      expect(provider.isInitialized, true);
    });

    test("user should be null after initialization", () {
      expect(provider.currentUser, null);
    });

    test(
      "should be able to initialize in less than 3 sec",
      () async {
        await provider.initialize();
        expect(provider.isInitialized, true);
      },
      timeout: const Timeout(Duration(seconds: 3)),
    );

    test("Create user should delegate to login function", () async {
      final badEmailUser = provider.createUser(
        email: "richkibz@gmail.com",
        password: "anypassword",
      );

      expect(badEmailUser,
          throwsA(const TypeMatcher<UserNotFoundAuthException>()));

      final badPasswordUser = provider.createUser(
        email: "someone@gmail.com",
        password: "123456",
      );
      expect(badPasswordUser,
          throwsA(const TypeMatcher<WrongPassAuthException>()));

      final user = await provider.createUser(
        email: "foo",
        password: "bar",
      );
      expect(provider.currentUser, user);
      expect(user.isEmailVerified, false);
    });
    test("Logged in user should be able to getverified", () {
      provider.sendEmailVerification();
      final user = provider.currentUser;
      expect(user, isNotNull);
      expect(user!.isEmailVerified, true);
    });

    test("should be able to logg out and log in ", () async {
      await provider.logout();
      await provider.login(
        email: "email",
        password: "password",
      );
      final user = provider.currentUser;
      expect(user, isNotNull);
    });
  });
}

class NotInitializedExceptions implements Exception {}

class MockAuthProvider implements AuthProvider {
  AuthUser? _user;
  var _isInitialized = false;

  bool get isInitialized => _isInitialized;
  @override
  Future<AuthUser> createUser({
    required String email,
    required String password,
  }) async {
    if (!isInitialized) throw NotInitializedExceptions();
    await Future.delayed(const Duration(seconds: 2));
    return login(
      email: email,
      password: password,
    );
  }

  @override
  AuthUser? get currentUser => _user;

  @override
  Future<void> initialize() async {
    await Future.delayed(const Duration(seconds: 2));
    _isInitialized = true;
  }

  @override
  Future<AuthUser> login({
    required String email,
    required String password,
  }) {
    if (!isInitialized) throw NotInitializedExceptions();
    if (email == "richkibz@gmail.com") throw UserNotFoundAuthException();
    if (password == "123456") throw WrongPassAuthException();
    const user = AuthUser(isEmailVerified: false, email: 'hb@gmail.com');
    _user = user;
    return Future.value(user);
  }

  @override
  Future<void> logout() async {
    if (!isInitialized) throw NotInitializedExceptions();
    if (_user == null) throw UserNotFoundAuthException();
    await Future.delayed(const Duration(seconds: 2));
    _user = null;
  }

  @override
  Future<void> sendEmailVerification() async {
    if (!isInitialized) throw NotInitializedExceptions();
    final user = _user;
    if (user == null) throw UserNotFoundAuthException();
    const newUser = AuthUser(isEmailVerified: true, email: 'hb@gmail.com');
    _user = newUser;
  }
}
