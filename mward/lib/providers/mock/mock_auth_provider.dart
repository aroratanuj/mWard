import 'package:flutter/foundation.dart';
import '../../models/user.dart';
import '../../services/mock/mock_auth_service.dart';
import '../../config/mock_config.dart';

class MockAuthProvider with ChangeNotifier {
  final MockAuthService _authService = MockAuthService();

  User? _currentUser;
  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _error;

  User? get currentUser => _currentUser;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Initialize and check auth status
  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    try {
      final isAuth = await _authService.checkAuthStatus();
      if (isAuth) {
        _currentUser = await _authService.getCurrentUser();
        _isAuthenticated = true;
      } else {
        _currentUser = null;
        _isAuthenticated = false;
      }
    } catch (e) {
      _error = e.toString();
      _isAuthenticated = false;
      _currentUser = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Send OTP
  Future<void> sendOTP(String phoneNumber) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authService.sendOTP(phoneNumber);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Verify OTP
  Future<void> verifyOTP(String phoneNumber, String otp) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentUser = await _authService.verifyOTP(phoneNumber, otp);
      _isAuthenticated = true;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Logout
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.logout();
      _currentUser = null;
      _isAuthenticated = false;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Update user profile
  Future<void> updateProfile({
    String? name,
    String? email,
    String? photoUrl,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (_currentUser == null) {
        throw Exception('User not logged in');
      }

      _currentUser = await _authService.updateUserProfile(
        userId: _currentUser!.userId,
        name: name,
        email: email,
        photoUrl: photoUrl,
      );

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Update user photo
  Future<void> updatePhoto(String photoUrl) async {
    await updateProfile(photoUrl: photoUrl);
  }

  // Check auth status
  Future<void> checkAuthStatus() async {
    _isLoading = true;
    notifyListeners();

    try {
      final isAuth = await _authService.checkAuthStatus();
      if (isAuth) {
        _currentUser = await _authService.getCurrentUser();
        _isAuthenticated = true;
      } else {
        _currentUser = null;
        _isAuthenticated = false;
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get current user
  Future<User?> getCurrentUser() async {
    return await _authService.getCurrentUser();
  }

  // Reset password
  Future<void> resetPassword(String phoneNumber) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.resetPassword(phoneNumber);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Change password
  Future<void> changePassword(String oldPassword, String newPassword) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.changePassword(oldPassword, newPassword);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Delete account
  Future<void> deleteAccount() async {
    _isLoading = true;
    notifyListeners();

    try {
      if (_currentUser == null) {
        throw Exception('User not logged in');
      }

      await _authService.deleteAccount(_currentUser!.userId);
      _currentUser = null;
      _isAuthenticated = false;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
