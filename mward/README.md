# mWard - Ward Issue Reporting App

A Flutter mobile application for reporting and tracking ward-level issues in Himachal Pradesh, India.

## Features

- **User Authentication**: Phone OTP-based login system
- **File Complaints**: Submit complaints with photos and auto-location detection
- **Track Status**: Monitor complaint status in real-time
- **Notifications**: Receive updates on complaint status
- **Admin Dashboard**: Manage and resolve complaints (for admins)
- **Offline Support**: Works offline with data sync when online
- **Mock Mode**: Test without AWS setup! 🎉

## Quick Start (Mock Mode - No AWS Needed)

### Run the App in 30 Seconds:

```bash
cd mward
flutter pub get
flutter run
```

### Login:
1. Tap **"User Demo"** or **"Admin Demo"** button
2. Enter any 6-digit OTP (e.g., 123456)
3. Start testing all features!

**✅ Features available in Mock Mode:**
- All UI screens and navigation
- Phone OTP authentication (simulated)
- File complaints with photos
- Auto GPS location
- View and track complaints
- Notifications with broadcasts
- User profile and statistics
- Developer tools for quick testing

**For detailed instructions, see:**
- `QUICK_START.md` - Quick start guide
- `MOCK_MODE.md` - Mock mode documentation
- `OPTION_A_COMPLETE.md` - Mock mode implementation details

## Tech Stack

- **Frontend**: Flutter (Dart)
- **Backend**: AWS Services
  - Cognito (Authentication)
  - DynamoDB (Database)
  - S3 (Storage)
  - Lambda (API)
  - SNS (Notifications)
- **State Management**: Provider
- **Local Storage**: Hive

## Project Structure

```
lib/
├── main.dart                          # App entry point
├── config/                            # Configuration files
│   ├── aws_config.dart               # AWS configuration
│   ├── theme_config.dart             # App theme
│   └── mock_config.dart              # Mock mode config
├── models/                            # Data models
│   ├── user.dart                     # User model
│   ├── complaint.dart                # Complaint model
│   ├── notification.dart             # Notification model
│   └── ward.dart                     # Ward model
├── screens/                           # UI screens
│   ├── auth/                         # Authentication screens
│   │   ├── splash_screen.dart
│   │   ├── login_screen.dart
│   │   └── otp_screen.dart
│   ├── home/                         # Home screens
│   │   └── tabs/
│   │       ├── complaints_tab.dart
│   │       ├── history_tab.dart
│   │       └── profile_tab.dart
│   ├── complaint/                    # Complaint screens
│   │   ├── file_complaint_screen.dart
│   │   └── complaint_details_screen.dart
│   ├── admin/                        # Admin screens
│   │   └── admin_dashboard_screen.dart
│   └── notification_list_screen.dart
├── widgets/                           # Reusable widgets
│   ├── notification_card.dart
│   ├── notification_bell.dart
│   ├── status_badge.dart
│   └── custom_button.dart
├── services/                          # Business logic
│   ├── auth_service.dart
│   ├── complaint_service.dart
│   ├── notification_service.dart
│   ├── storage_service.dart
│   └── location_service.dart
├── providers/                         # State management
│   ├── auth_provider.dart
│   ├── complaint_provider.dart
│   ├── notification_provider.dart
│   └── user_provider.dart
└── utils/                             # Utilities
    ├── constants.dart                # App constants
    ├── validators.dart               # Input validators
    └── helpers.dart                  # Helper functions
```

## Getting Started

### Prerequisites

- Flutter SDK (>= 3.0.0)
- Dart SDK (>= 3.0.0)
- Android Studio / VS Code
- Android SDK (for Android development)

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd mward
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run
```

### Build APK

```bash
flutter build apk --release
```

### Build App Bundle (for Play Store)

```bash
flutter build appbundle --release
```

## Configuration

### AWS Setup

1. Create an AWS account
2. Set up the following services:
   - Cognito User Pool
   - DynamoDB tables (users, complaints, notifications, wards)
   - S3 bucket (mward-images)
   - Lambda functions
   - API Gateway
   - SNS topics
3. Update `lib/config/aws_config.dart` with your AWS credentials

### Android Permissions

The following permissions are required (defined in `AndroidManifest.xml`):
- INTERNET
- CAMERA
- READ_EXTERNAL_STORAGE
- WRITE_EXTERNAL_STORAGE
- ACCESS_FINE_LOCATION
- ACCESS_COARSE_LOCATION
- RECEIVE_SMS
- READ_SMS

## Development

### Code Generation

This project uses code generation for JSON serialization:

```bash
flutter pub run build_runner build
```

### Running Tests

```bash
# Unit tests
flutter test

# Widget tests
flutter test test/widget_tests/

# Integration tests
flutter test integration_test/
```

## Features Implemented

### Phase 1: Project Setup ✅
- [x] Project structure created
- [x] Dependencies installed
- [x] Theme configuration
- [x] Constants and utilities
- [x] Models defined
- [x] Providers created
- [x] Services created
- [x] Authentication screens (Splash, Login, OTP)
- [x] Home screen with tabs
- [x] File complaint screen
- [x] Notification system
- [x] Android manifest with permissions

### Phase 2: Authentication ✅
- [x] Phone OTP login
- [x] Session management
- [x] User profile

### Phase 3: Core Features ✅
- [x] File complaint with photos
- [x] Auto location detection
- [x] View complaint list
- [x] Complaint details
- [x] Status tracking

### Phase 4: Notifications ✅
- [x] Create notifications (admin)
- [x] View notifications (user)
- [x] Broadcast notifications
- [x] Notification bell with unread count

## TODO

- [ ] Complete AWS integration
- [ ] Implement image upload to S3
- [ ] Complete admin dashboard
- [ ] Add analytics
- [ ] Implement offline sync
- [ ] Add push notifications
- [ ] Write unit tests
- [ ] Write widget tests
- [ ] Write integration tests
- [ ] Deploy to Play Store

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License.

## Support

For support, email support@mward.app or create an issue in the repository.
