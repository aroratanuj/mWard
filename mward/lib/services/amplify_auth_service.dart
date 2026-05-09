import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import '../models/user.dart';
import '../utils/constants.dart';
import 'auth_service.dart';

class AmplifyAuthService implements AuthService {
  @override
  Future<void> sendOTP(String phoneNumber) async {
    final result = await Amplify.Auth.signIn(
      username: phoneNumber,
    );

    if (result.isSignedIn) {
      // User already exists, signed in automatically
    }
  }

  @override
  Future<User> verifyOTP(String phoneNumber, String otp) async {
    final result = await Amplify.Auth.confirmSignIn(
      confirmationValue: otp,
    );

    if (!result.isSignedIn) {
      throw Exception('Failed to verify OTP');
    }

    // Fetch user attributes after successful sign in
    final attributes = await Amplify.Auth.fetchUserAttributes();
    return _parseUserAttributes(attributes);
  }

  @override
  Future<bool> checkAuthStatus() async {
    try {
      final session = await Amplify.Auth.fetchAuthSession();
      return session.isSignedIn;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<User?> getCurrentUser() async {
    try {
      final attributes = await Amplify.Auth.fetchUserAttributes();
      return _parseUserAttributes(attributes);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> logout() async {
    await Amplify.Auth.signOut();
  }

  @override
  Future<User> updateUserProfile({
    String? name,
    String? email,
    String? photoUrl,
  }) async {
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

    // Return updated user
    final currentUser = await getCurrentUser();
    if (currentUser == null) {
      throw Exception('User not found');
    }
    return currentUser.copyWith(
      name: name ?? currentUser.name,
      email: email ?? currentUser.email,
      photoUrl: photoUrl ?? currentUser.photoUrl,
    );
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
}
