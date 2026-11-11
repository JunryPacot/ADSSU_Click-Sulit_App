import '../models/user_model.dart';

abstract class AuthRepository {
  Stream<UserModel?> get authStateChanges;
  UserModel? get currentUser;
  bool get isAuthenticated;

  Future<UserModel> signIn({
    required String email,
    required String password,
  });

  Future<UserModel> signInWithGoogle();

  Future<Map<String, String>> getGoogleAccountForRegistration();

  Future<UserModel> signUp({
    required String email,
    required String password,
    required String name,
    required String studentId,
    required String college,
  });

  Future<void> sendVerificationOtp(String email);

  Future<bool> verifyEmailOtp({
    required String email,
    required String code,
  });

  Future<void> signOut();

  Future<void> updateProfile({
    String? name,
    String? college,
    String? bio,
    String? profilePhoto,
  });
}

