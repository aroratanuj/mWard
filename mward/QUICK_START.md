# Quick Start Guide - mWard App

## Prerequisites

1. **Install Flutter SDK**
   ```bash
   # Download from: https://flutter.dev/docs/get-started/install
   # Or using Homebrew (macOS):
   brew install --cask flutter
   ```

2. **Verify Installation**
   ```bash
   flutter doctor
   ```
   Fix any issues reported by `flutter doctor`

3. **Install an IDE**
   - Android Studio (recommended) OR
   - VS Code with Flutter extension

## Mock Mode (No AWS Required) 🎉

The app comes with **Mock Mode** enabled by default, allowing you to test all features without AWS setup!

### What is Mock Mode?
- ✅ No AWS account needed
- ✅ All features work locally
- ✅ Demo accounts for quick testing
- ✅ Sample data included
- ✅ Developer tools for testing

### Quick Test in Mock Mode
1. Run the app: `flutter run`
2. Tap **"User Demo"** or **"Admin Demo"** button
3. Enter any 6-digit OTP (e.g., 123456)
4. Start testing all features!

### Switching to Production (AWS)
When ready to use real AWS:
1. Set up AWS resources (Cognito, DynamoDB, S3, Lambda)
2. Update `lib/config/aws_config.dart`
3. Set `MockConfig.isMockMode = false` in `lib/config/mock_config.dart`
4. Run the app

**For detailed mock mode documentation, see `MOCK_MODE.md`**

## Getting the App Running

### Step 1: Navigate to Project
```bash
cd mward
```

### Step 2: Install Dependencies
```bash
flutter pub get
```

### Step 3: (Optional) Generate Code
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### Step 4: Run the App

**Option A: Run on Connected Device**
```bash
flutter devices
flutter run -d <device-id>
```

**Option B: Run on Emulator**
```bash
# Start Android Emulator first, then:
flutter run
```

**Option C: Run on Chrome (Web)**
```bash
flutter run -d chrome
```

## Demo Accounts

The app includes demo login buttons for quick testing:

### User Demo
- Phone: `9876543210`
- Role: User
- Can: File complaints, view history, track status

### Admin Demo
- Phone: `9876543211`
- Role: Admin
- Can: All user features + manage complaints, create notifications

### OTP Testing
- Enter any 6-digit OTP to verify (demo mode)

## Key Features to Test

### 1. Authentication Flow
1. Launch app → Splash screen
2. Enter phone number (or use demo buttons)
3. Enter OTP (any 6 digits)
4. Logged in → Home screen

### 2. File a Complaint
1. Tap the **+** button on Home screen
2. Location will auto-detect
3. Fill in:
   - Category (dropdown)
   - Priority (low/medium/high)
   - Title
   - Description
   - Photos (tap to add)
   - Address (optional)
4. Tap **Submit**

### 3. View Complaints
1. **Home Tab**: Shows all your complaints
2. **History Tab**: Filter by status (All, Pending, In Progress, Resolved, Rejected)
3. Tap any complaint to see details

### 4. Notifications
1. Tap the bell icon in app bar
2. View all notifications
3. Notifications show:
   - News, alerts, updates, broadcasts
   - Priority badges
   - Timestamps
   - Creator info

### 5. Profile
1. Go to **Profile** tab
2. View your statistics:
   - Total complaints
   - Pending complaints
   - Resolved complaints
3. Access settings and other options

### 6. Admin Features (Admin Demo Account)
1. Create notifications with:
   - Type (news, alert, update, broadcast)
   - Title and message
   - Priority (1-5)
   - Target audience (all or specific ward)
   - Image upload
   - Expiry date

## Known Limitations

### Currently Not Working (Needs AWS Setup):
1. ✗ Real OTP verification (uses demo mode)
2. ✗ Actual data persistence to AWS
3. ✗ Image upload to S3
4. ✗ Real push notifications
5. ✗ Real geocoding (coordinates to address)
6. ✗ Admin dashboard features
7. ✗ Complaint status updates by admin

### Working (Local/Mock):
1. ✅ UI and navigation
2. ✅ Form validation
3. ✅ Local state management
4. ✅ Image selection (camera/gallery)
5. ✅ GPS location detection
6. ✅ Demo authentication
7. ✅ Notification UI
8. ✅ Profile statistics (mock data)

## Troubleshooting

### Issue: "flutter command not found"
**Solution**: Add Flutter to your PATH
```bash
# macOS/Linux
export PATH="$PATH:/path/to/flutter/bin"

# Windows
set PATH=%PATH%;C:\path\to\flutter\bin
```

### Issue: "No devices found"
**Solution**:
- Enable USB debugging on Android device
- Or start Android Emulator from Android Studio
- Or run on web: `flutter run -d chrome`

### Issue: "Gradle build failed"
**Solution**:
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
flutter run
```

### Issue: "Location permission denied"
**Solution**:
- Go to device Settings → Apps → mWard
- Enable Location permission
- Restart the app

### Issue: "Camera permission denied"
**Solution**:
- Go to device Settings → Apps → mWard
- Enable Camera permission
- Restart the app

## Project Structure Quick Reference

```
mward/
├── lib/                    # Source code
│   ├── main.dart          # App entry point
│   ├── config/            # Configuration
│   ├── models/            # Data models
│   ├── screens/           # UI screens
│   ├── widgets/           # Reusable widgets
│   ├── services/          # Business logic
│   ├── providers/         # State management
│   └── utils/             # Utilities
├── android/               # Android-specific code
├── ios/                   # iOS-specific code
├── assets/                # Images, fonts, icons
├── pubspec.yaml           # Dependencies
└── README.md             # Project documentation
```

## Next Steps

### For UI Testing (No AWS Needed):
1. Implement mock mode (see MOCK_MODE plan)
2. Add sample data
3. Test all user flows
4. Gather feedback

### For Production (With AWS):
1. Set up AWS account
2. Create all AWS resources (Cognito, DynamoDB, S3, Lambda, etc.)
3. Update `lib/config/aws_config.dart` with your credentials
4. Test with real backend
5. Deploy to Play Store

## Getting Help

- **Documentation**: See `README.md`
- **Phase 1 Status**: See `PHASE_1_COMPLETE.md`
- **Issues**: Report bugs in the repository

## Tips for Development

1. **Hot Reload**: Press `r` in terminal to hot reload changes
2. **Hot Restart**: Press `R` to hot restart the app
3. **Debug Mode**: Use `flutter run --debug` for debugging
4. **Profile Mode**: Use `flutter run --profile` for performance testing
5. **Release Build**: Use `flutter run --release` for production-like testing

---

**Happy Coding! 🚀**
