import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/user.dart';
import '../../mock_data/mock_users.dart';
import '../../config/mock_config.dart';
import '../../utils/constants.dart';

class MockAuthService {
  static const String _lastLoggedInPhoneKey = 'mock_last_logged_in_phone';

  // Simulate network delay
  Future<void> _simulateDelay() async {
    await Future.delayed(const Duration(milliseconds: MockConfig.mockApiDelay));
  }

  // Send OTP (Mock)
  Future<void> sendOTP(String phoneNumber) async {
    await _simulateDelay();

    // Validate phone number
    if (!RegExp(r'^[+]?[0-9]{10,15}$').hasMatch(phoneNumber)) {
      throw Exception('Invalid phone number');
    }

    // Check if user exists
    final user = MockUsers.getUserByPhone(phoneNumber);
    if (user != null) {
      debugPrint('Mock: User exists. Sending OTP to $phoneNumber');
    } else {
      debugPrint('Mock: New user. Sending OTP to $phoneNumber');
    }

    debugPrint('Mock: OTP sent successfully. Use ${MockConfig.testOTP} for verification');
  }

  // Verify OTP (Mock)
  Future<User> verifyOTP(String phoneNumber, String otp) async {
    await _simulateDelay();

    // Validate OTP (in mock mode, any 6-digit OTP works)
    if (otp.length != 6) {
      throw Exception('Invalid OTP');
    }

    // Get or create user
    User? user = MockUsers.getUserByPhone(phoneNumber);
    
    if (user == null) {
      // Create new user
      user = User(
        userId: DateTime.now().millisecondsSinceEpoch.toString(),
        phoneNumber: phoneNumber,
        role: AppConstants.roleUser,
        wardCode: MockConfig.mockWardCode,
        createdAt: DateTime.now(),
        lastActive: DateTime.now(),
      );
    } else {
      // Update last active
      user = User(
        userId: user.userId,
        phoneNumber: user.phoneNumber,
        name: user.name,
        email: user.email,
        photoUrl: user.photoUrl,
        role: user.role,
        wardCode: user.wardCode,
        createdAt: user.createdAt,
        lastActive: DateTime.now(),
      );
    }

    // Save as last logged in user
    await _saveLastLoggedInPhone(phoneNumber);

    debugPrint('Mock: User verified: ${user.phoneNumber}');
    return user;
  }

  // Get current user (Mock)
  Future<User?> getCurrentUser() async {
    await _simulateDelay();

    // Return admin or user based on saved preference
    final lastPhone = await _getLastLoggedInPhone();
    if (lastPhone != null) {
      return MockUsers.getUserByPhone(lastPhone);
    }
    return null;
  }

  // Logout (Mock)
  Future<void> logout() async {
    await _simulateDelay();
    await _clearLastLoggedInPhone();
    debugPrint('Mock: User logged out');
  }

  // Update user profile (Mock)
  Future<User> updateUserProfile({
    required String userId,
    String? name,
    String? email,
    String? photoUrl,
  }) async {
    await _simulateDelay();

    final user = MockUsers.getUserById(userId);
    if (user == null) {
      throw Exception('User not found');
    }

    final updatedUser = user.copyWith(
      name: name,
      email: email,
      photoUrl: photoUrl,
    );

    debugPrint('Mock: User profile updated: $userId');
    return updatedUser;
  }

  // Check if user is authenticated (Mock)
  Future<bool> checkAuthStatus() async {
    await _simulateDelay();
    
    final lastPhone = await _getLastLoggedInPhone();
    return lastPhone != null;
  }

  // Save last logged in phone (for persistence)
  Future<void> _saveLastLoggedInPhone(String phoneNumber) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_lastLoggedInPhoneKey, phoneNumber);
      debugPrint('Mock: Saved last logged in phone: $phoneNumber');
    } catch (e) {
      debugPrint('Mock: Failed to save phone number: $e');
    }
  }

  // Get last logged in phone
  Future<String?> _getLastLoggedInPhone() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastPhone = prefs.getString(_lastLoggedInPhoneKey);
      debugPrint('Mock: Retrieved last logged in phone: $lastPhone');
      return lastPhone;
    } catch (e) {
      debugPrint('Mock: Failed to retrieve phone number: $e');
      return null;
    }
  }

  // Clear last logged in phone
  Future<void> _clearLastLoggedInPhone() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_lastLoggedInPhoneKey);
      debugPrint('Mock: Cleared last logged in phone');
    } catch (e) {
      debugPrint('Mock: Failed to clear phone number: $e');
    }
  }

  // Reset password (Mock)
  Future<void> resetPassword(String phoneNumber) async {
    await _simulateDelay();
    debugPrint('Mock: Password reset initiated for $phoneNumber');
  }

  // Change password (Mock)
  Future<void> changePassword(String oldPassword, String newPassword) async {
    await _simulateDelay();
    
    if (oldPassword == newPassword) {
      throw Exception('New password must be different from old password');
    }
    
    debugPrint('Mock: Password changed successfully');
  }

  // Delete account (Mock)
  Future<void> deleteAccount(String userId) async {
    await _simulateDelay();
    debugPrint('Mock: Account deleted: $userId');
  }
}
