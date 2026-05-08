import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../utils/constants.dart';

class UserProvider with ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Load user profile
  Future<void> loadUserProfile(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // TODO: Implement user profile loading from backend
      // For now, use mock data
      _user = User(
        userId: userId,
        phoneNumber: '+919876543210',
        name: 'Ramesh Kumar',
        email: 'ramesh@example.com',
        role: AppConstants.roleUser,
        wardCode: 'WARD-001',
        createdAt: DateTime.now(),
      );

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  // Update user profile
  Future<void> updateUserProfile({
    String? name,
    String? email,
    String? photoUrl,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // TODO: Implement user profile update to backend
      if (_user != null) {
        _user = _user!.copyWith(
          name: name ?? _user!.name,
          email: email ?? _user!.email,
          photoUrl: photoUrl ?? _user!.photoUrl,
        );
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Upload profile photo
  Future<String> uploadProfilePhoto(String filePath) async {
    try {
      // TODO: Implement photo upload to S3
      // For now, return a placeholder URL
      await Future.delayed(const Duration(seconds: 1));
      return 'https://via.placeholder.com/150';
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Get user statistics
  Map<String, int> getUserStatistics() {
    // TODO: Implement statistics calculation
    return {
      'total': 0,
      'pending': 0,
      'resolved': 0,
      'rejected': 0,
    };
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
