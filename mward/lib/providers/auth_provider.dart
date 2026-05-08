import 'package:flutter/foundation.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import '../models/user.dart';
import '../utils/constants.dart';

class AuthProvider with ChangeNotifier {
  User? _currentUser;
  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _error;

  User? get currentUser => _currentUser;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> checkAuthStatus() async {
    try {
      _isLoading = true;
      notifyListeners();

      final session = await Amplify.Auth.fetchAuthSession();
      final isSignedIn = session.isSignedIn;

      if (isSignedIn) {
        final attributes = await Amplify.Auth.fetchUserAttributes();
        final user = _parseUserAttributes(attributes);
        _currentUser = user;
        _isAuthenticated = true;
      } else {
        _currentUser = null;
        _isAuthenticated = false;
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> sendOTP(String phoneNumber) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final result = await Amplify.Auth.signIn(
        username: phoneNumber,
      );

      if (result.isSignedIn) {
        // User already exists, sign them in
        await checkAuthStatus();
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

  Future<void> verifyOTP(String phoneNumber, String otp) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final result = await Amplify.Auth.confirmSignIn(
        confirmationValue: otp,
      );

      if (result.isSignedIn) {
        await checkAuthStatus();
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

  Future<void> logout() async {
    try {
      _isLoading = true;
      notifyListeners();

      await Amplify.Auth.signOut();

      _currentUser = null;
      _isAuthenticated = false;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateUserProfile({
    String? name,
    String? email,
    String? photoUrl,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Update user attributes in Cognito
      final attributes = <AuthUserAttribute>[];

      if (name != null) {
        attributes.add(
          AuthUserAttribute(
            userAttributeKey: CognitoUserAttributeKey.name,
            value: name,
          ),
        );
      }

      if (email != null) {
        attributes.add(
          AuthUserAttribute(
            userAttributeKey: CognitoUserAttributeKey.email,
            value: email,
          ),
        );
      }

      if (attributes.isNotEmpty) {
        await Amplify.Auth.updateUserAttributes(attributes: attributes);
      }

      // Update local user object
      if (_currentUser != null) {
        _currentUser = _currentUser!.copyWith(
          name: name ?? _currentUser!.name,
          email: email ?? _currentUser!.email,
          photoUrl: photoUrl ?? _currentUser!.photoUrl,
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

  User _parseUserAttributes(List<AuthUserAttribute> attributes) {
    String userId = '';
    String phoneNumber = '';
    String? name;
    String? email;
    String role = AppConstants.roleUser;
    String? wardCode;

    for (final attr in attributes) {
      switch (attr.userAttributeKey.key) {
        case CognitoUserAttributeKey.sub:
          userId = attr.value;
          break;
        case CognitoUserAttributeKey.phoneNumber:
          phoneNumber = attr.value;
          break;
        case CognitoUserAttributeKey.name:
          name = attr.value;
          break;
        case CognitoUserAttributeKey.email:
          email = attr.value;
          break;
        case 'custom:role':
          role = attr.value;
          break;
        case 'custom:wardCode':
          wardCode = attr.value;
          break;
      }
    }

    return User(
      userId: userId,
      phoneNumber: phoneNumber,
      name: name,
      email: email,
      role: role,
      wardCode: wardCode,
      createdAt: DateTime.now(),
    );
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
