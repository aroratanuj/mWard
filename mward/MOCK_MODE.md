# Mock Mode Documentation

## Overview

Mock Mode allows you to test the mWard app without connecting to AWS services. All data is simulated locally, making it perfect for UI testing and development.

## Features

- ✅ No AWS setup required
- ✅ Local data storage using Hive
- ✅ Simulated API delays for realistic feel
- ✅ Demo accounts for quick testing
- ✅ Full UI functionality
- ✅ Developer tools for quick actions
- ✅ Data persistence between app restarts (optional)

## Enabling Mock Mode

Mock Mode is enabled by default. To enable or disable it, modify the file:

**File:** `lib/config/mock_config.dart`

```dart
class MockConfig {
  static bool isMockMode = true;  // Set to false for production
  static bool showMockBanner = true;  // Show yellow warning banner
}
```

## Demo Accounts

### User Demo
- **Phone:** 9876543210 (or tap "User Demo" button)
- **Role:** User
- **OTP:** Any 6-digit number (e.g., 123456)
- **Can:** File complaints, view history, track status

### Admin Demo
- **Phone:** 9876543211 (or tap "Admin Demo" button)
- **Role:** Admin
- **OTP:** Any 6-digit number (e.g., 123456)
- **Can:** All user features + manage complaints, create notifications

## Quick Start

### 1. Run the App

```bash
cd mward
flutter pub get
flutter run
```

### 2. Login

You have three options:

**Option A: Demo Buttons (Recommended)**
1. On the login screen, tap "User Demo" or "Admin Demo"
2. Enter any 6-digit OTP (e.g., 123456)
3. You're logged in!

**Option B: Manual Login**
1. Enter phone number: `9876543210` (user) or `9876543211` (admin)
2. Tap "Send OTP"
3. Enter any 6-digit OTP
4. Tap "Verify"

**Option C: Developer Tools**
1. Go to Profile tab
2. Tap "Developer Tools" (only visible in mock mode)
3. Tap "Login as User" or "Login as Admin"

### 3. Test Features

#### File a Complaint
1. Tap the **+** button on Home screen
2. Location will auto-detect (Shimla, HP)
3. Fill in the form:
   - Category: Select from dropdown
   - Priority: Low, Medium, or High
   - Title: Brief description
   - Description: Detailed issue
   - Photos: Tap to add from camera or gallery
   - Address: Optional (auto-filled)
4. Tap "Submit"

#### View Complaints
- **Home Tab:** Shows all your complaints
- **History Tab:** Filter by status (All, Pending, In Progress, Resolved, Rejected)
- Tap any complaint to see details

#### Notifications
1. Tap the bell icon in the app bar
2. View all notifications (news, alerts, updates, broadcasts)
3. Notifications show priority, type, and timestamp

#### Developer Tools (Mock Mode Only)
1. Go to Profile tab
2. Tap "Developer Tools"
3. Quick actions:
   - Login as User
   - Login as Admin
   - File Complaint
   - Create Notification
4. Data Management:
   - Clear All Data
   - Reset Defaults
5. Settings:
   - Persist Data (save between restarts)
   - Show Mock Banner (warning at top)

## Sample Data

Mock Mode comes with pre-loaded sample data:

### Users (6 sample users)
- Ramesh Kumar (Admin)
- Sita Devi (User)
- Rajesh Singh (User)
- Anita Thakur (User)
- Sunil Verma (User)
- Priya Sharma (User)

### Complaints (7 sample complaints)
1. Water Supply Issue - Pending
2. Road Damage - In Progress
3. Garbage Collection - Resolved
4. Street Light Not Working - Pending
5. Drainage Blockage - In Progress
6. Electricity Wire Hanging - Resolved
7. Park Needs Maintenance - Pending

### Notifications (7 sample notifications)
1. Ward Meeting Announcement (News)
2. Heavy Rain Alert (Alert)
3. Road Repair Work Completed (Update)
4. COVID-19 Vaccination Drive (Broadcast)
5. Garbage Collection Schedule Change (Update)
6. Water Supply Maintenance (Alert)
7. Independence Day Celebration (News)

### Wards (5 sample wards)
1. Sanjauli
2. Summer Hill
3. Chotta Shimla
4. Boileauganj
5. Lakkar Bazar

## Mock Mode Settings

### Configuration Options

**File:** `lib/config/mock_config.dart`

```dart
class MockConfig {
  // Enable/disable mock mode
  static bool isMockMode = true;

  // Show yellow warning banner
  static bool showMockBanner = true;

  // Persist data between app restarts
  static bool persistData = true;

  // Auto-load sample data on first run
  static bool autoLoadSampleData = true;

  // Simulated API delay (milliseconds)
  static const int mockApiDelay = 500;

  // Mock location (Shimla coordinates)
  static const double mockLatitude = 31.1048;
  static const double mockLongitude = 77.1734;
  static const String mockAddress = 'Mall Road, Shimla, Himachal Pradesh';

  // Test accounts
  static const String testPhoneAdmin = '+919876543210';
  static const String testPhoneUser = '+919812345678';
  static const String testOTP = '123456';
}
```

## Data Persistence

Mock Mode uses Hive for local data storage:

- **Complaints Box:** Stores all complaints
- **Notifications Box:** Stores all notifications
- **Users Box:** Stores user data
- **Settings Box:** Stores app settings

### Enable/Disable Persistence

```dart
MockConfig.persistData = true;  // Save data between restarts
MockConfig.persistData = false;  // Reset on every launch
```

### Clear All Data

Use Developer Tools → Clear All Data, or programmatically:

```dart
await HiveService.clearAll();
```

## Switching to Production Mode

To switch from Mock Mode to Production Mode (real AWS):

1. **Disable Mock Mode:**
   ```dart
   // lib/config/mock_config.dart
   static bool isMockMode = false;
   ```

2. **Configure AWS:**
   - Set up AWS resources (Cognito, DynamoDB, S3, Lambda, etc.)
   - Update `lib/config/aws_config.dart` with your credentials
   - Update `lib/main.dart` amplifyconfig with your AWS config

3. **Build for Production:**
   ```bash
   flutter build apk --release
   flutter build appbundle --release
   ```

## Limitations

### What Works (Mock Mode)
- ✅ All UI screens and navigation
- ✅ Phone OTP authentication (simulated)
- ✅ File complaints with photos
- ✅ Auto location detection (fixed to Shimla)
- ✅ View and track complaints
- ✅ Notifications with broadcasts
- ✅ User profile
- ✅ Admin features
- ✅ Data persistence (optional)

### What Doesn't Work (Needs Real AWS)
- ❌ Real OTP verification
- ❌ Actual data persistence to cloud
- ❌ Image upload to S3 (simulated locally)
- ❌ Real push notifications
- ❌ Real geocoding (coordinates to address)
- ❌ Real-time sync between devices
- ❌ Analytics and crash reporting

## Troubleshooting

### Issue: App crashes on startup
**Solution:** Make sure Hive is initialized
```dart
// In main.dart
if (MockConfig.isMockMode) {
  await HiveService.init();
}
```

### Issue: Data not persisting
**Solution:** Enable persistence in config
```dart
MockConfig.persistData = true;
```

### Issue: Mock banner not showing
**Solution:** Enable banner in config
```dart
MockConfig.showMockBanner = true;
```

### Issue: Location not working
**Solution:** Check location permissions on device
- Android: Settings → Apps → mWard → Location
- iOS: Settings → mWard → Location

### Issue: Camera not working
**Solution:** Check camera permissions on device
- Android: Settings → Apps → mWard → Camera
- iOS: Settings → mWard → Camera

## Tips for Testing

1. **Use Demo Buttons:** Fastest way to test different user roles
2. **Developer Tools:** Access quick actions without navigating
3. **Clear Data:** Start fresh between test scenarios
4. **Test All Flows:**
   - User login → File complaint → View history → Track status
   - Admin login → View all complaints → Update status → Create notification
   - Broadcast notifications → Check notification bell
5. **Test Offline Mode:** Turn off internet to see offline behavior
6. **Test Different Devices:** Run on emulator and physical device
7. **Test Edge Cases:**
   - Empty fields
   - Invalid phone numbers
   - Large images
   - Long descriptions

## Architecture

### How Mock Mode Works

1. **Configuration:** `MockConfig.isMockMode` flag controls behavior
2. **Provider Selection:** `main.dart` selects mock or real providers
3. **Local Storage:** Hive stores data instead of AWS
4. **Simulated APIs:** Mock services return sample data with delays
5. **UI Integration:** Same UI works with both mock and real providers

### File Structure (Mock Mode)

```
lib/
├── config/
│   └── mock_config.dart          # Mock mode configuration
├── mock_data/                    # Sample data
│   ├── mock_users.dart
│   ├── mock_complaints.dart
│   ├── mock_notifications.dart
│   └── mock_wards.dart
├── services/
│   ├── hive_service.dart         # Local storage
│   └── mock/                     # Mock services
│       ├── mock_auth_service.dart
│       ├── mock_complaint_service.dart
│       ├── mock_notification_service.dart
│       ├── mock_storage_service.dart
│       └── mock_location_service.dart
├── providers/mock/               # Mock providers
│   ├── mock_auth_provider.dart
│   ├── mock_complaint_provider.dart
│   └── mock_notification_provider.dart
└── widgets/
    ├── mock_mode_banner.dart     # Warning banner
    └── developer_tools.dart      # Developer tools
```

## Support

For issues or questions:
1. Check this documentation
2. Review `QUICK_START.md`
3. Check `PHASE_1_COMPLETE.md`
4. Report issues in the repository

---

**Happy Testing! 🚀**

Mock Mode makes development and testing fast and easy without needing AWS setup.
