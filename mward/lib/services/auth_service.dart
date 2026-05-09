import '../models/user.dart';

abstract class AuthService {
  Future<void> sendOTP(String phoneNumber);
  Future<User> verifyOTP(String phoneNumber, String otp);
  Future<bool> checkAuthStatus();
  Future<User?> getCurrentUser();
  Future<void> logout();
  Future<User> updateUserProfile({
    String? name,
    String? email,
    String? photoUrl,
  });
}
