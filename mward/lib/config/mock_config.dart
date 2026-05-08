import 'package:flutter/material.dart';

class MockConfig {
  // Mock Mode Settings
  static bool isMockMode = true;
  static bool showMockBanner = true;

  // Mock Mode Indicator
  static const String mockModeBannerText = '⚠️ MOCK MODE - Data is not real';
  static const Color mockModeBannerColor = Color(0xFFFFA000);

  // Test Accounts
  static const String testPhoneAdmin = '+919876543210';
  static const String testPhoneUser = '+919812345678';
  static const String testOTP = '123456';

  // Mock Data Settings
  static bool persistData = true; // Persist mock data between app restarts
  static bool autoLoadSampleData = true;

  // Performance Settings
  static const int mockApiDelay = 500; // milliseconds (simulate network delay)
  static const int mockImageUploadDelay = 1000; // milliseconds

  // Feature Flags
  static const bool enableMockNotifications = true;
  static const bool enableMockLocation = true;
  static const bool enableMockImageUpload = true;

  // Mock Location (Shimla, Himachal Pradesh)
  static const double mockLatitude = 31.1048;
  static const double mockLongitude = 77.1734;
  static const String mockAddress = 'Mall Road, Shimla, Himachal Pradesh';
  static const double defaultLocationAccuracy = 10.0; // meters

  // Mock Ward Code
  static const String mockWardCode = 'WARD-001';

  // Mock User
  static const String mockAdminId = 'admin-001';
  static const String mockUserId = 'user-001';

  static void enableMockMode() {
    isMockMode = true;
    showMockBanner = true;
  }

  static void disableMockMode() {
    isMockMode = false;
    showMockBanner = false;
  }

  static void toggleMockMode() {
    isMockMode = !isMockMode;
  }
}
