import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:amplify_flutter/amplify_flutter.dart' as amplify;
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart' hide AuthProvider;
import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';
import 'package:amplify_analytics_pinpoint/amplify_analytics_pinpoint.dart';
import 'package:provider/provider.dart';

import 'config/theme_config.dart';
import 'config/mock_config.dart';
import 'screens/auth/splash_screen.dart';
import 'providers/auth_provider.dart';
import 'providers/complaint_provider.dart';
import 'providers/notification_provider.dart';
import 'providers/user_provider.dart';
import 'services/auth_service.dart';
import 'services/amplify_auth_service.dart';
import 'services/mock/mock_auth_service.dart';
import 'services/complaint_service.dart';
import 'services/amplify_complaint_service.dart';
import 'services/mock/mock_complaint_service.dart';
import 'services/notification_service.dart' as impl;
import 'services/notification_service_interface.dart';
import 'services/mock/mock_notification_service.dart';
import 'services/hive_service.dart';
import 'widgets/mock_mode_banner.dart';
import 'widgets/developer_tools.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize Hive for mock mode
  if (MockConfig.isMockMode) {
    try {
      await HiveService.init();
      debugPrint('Mock Mode: Initialized Hive for local storage');
    } catch (e) {
      debugPrint('Mock Mode: Failed to initialize Hive: $e');
      debugPrint('Mock Mode: Continuing without persistent storage');
    }
  } else {
    await _configureAmplify();
  }

  runApp(const MyApp());
}

Future<void> _configureAmplify() async {
  try {
    await amplify.Amplify.configure(amplifyconfig);
    debugPrint('Amplify configured successfully');
  } catch (e) {
    debugPrint('Error configuring Amplify: $e');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: _getProviders(),
      child: MockModeBanner(
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'mWard',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.system,
          home: const SplashScreen(),
        ),
      ),
    );
  }

  List<ChangeNotifierProvider> _getProviders() {
    final AuthService authService;
    final ComplaintService complaintService;
    final NotificationService notificationService;

    if (MockConfig.isMockMode) {
      debugPrint('Mock Mode: Using mock services');
      authService = MockAuthService();
      complaintService = MockComplaintService();
      notificationService = MockNotificationService();
    } else {
      debugPrint('Production Mode: Using Amplify services');
      authService = AmplifyAuthService();
      complaintService = AmplifyComplaintService();
      notificationService = impl.AmplifyNotificationService();
    }

    if (MockConfig.isMockMode) {
      authService.checkAuthStatus().then((_) {
        debugPrint('Mock Mode: Auth service initialized');
      }).catchError((e) {
        debugPrint('Mock Mode: Error initializing auth service: $e');
      });
    }

    return [
      ChangeNotifierProvider(create: (_) => AuthProvider(authService)),
      ChangeNotifierProvider(create: (_) => ComplaintProvider(complaintService)),
      ChangeNotifierProvider(create: (_) => NotificationProvider(notificationService)),
      ChangeNotifierProvider(create: (_) => UserProvider()),
    ];
  }
}

const amplifyconfig = '''
{
  "UserAgent": "aws-amplify-cli/2.0",
  "Version": "1.0",
  "api": {
    "plugins": {
      "awsAPIPlugin": {
        "mward": {
          "endpointType": "GraphQL",
          "endpoint": "https://your-api-gateway-url.amazonaws.com/graphql",
          "region": "ap-south-1",
          "authorizationType": "AMAZON_COGNITO_USER_POOLS",
          "authenticationType": "AMAZON_COGNITO_USER_POOLS"
        }
      }
    }
  },
  "auth": {
    "plugins": {
      "awsCognitoAuthPlugin": {
        "UserAgent": "aws-amplify-cli/0.1.0",
        "Version": "0.1.0",
        "IdentityPoolId": "ap-south-1:xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
        "Region": "ap-south-1",
        "LoginWith": {
          "OAuth": {
            "Domain": "xxxxxxxxxxxxxxxxxxxxxx.auth.ap-south-1.amazoncognito.com",
            "Scopes": [
              "phone",
              "email",
              "openid",
              "profile",
              "aws.cognito.signin.user.admin"
            ],
            "RedirectSignInURIs": [
              "mward://"
            ],
            "RedirectSignOutURIs": [
              "mward://"
            ],
            "ResponseType": "CODE"
          }
        },
        "MFA": {
          "Optional": true,
          "SMS": {
            "SmsVerificationMessage": "Your verification code is {####}"
          }
        },
        "usernameAttributes": "PHONE_NUMBER",
        "passwordProtectionSettings": {
          "passwordPolicyMinLength": 8,
          "passwordPolicyCharacters": [
            "REQUIRES_LOWERCASE",
            "REQUIRES_NUMBERS",
            "REQUIRES_SYMBOLS",
            "REQUIRES_UPPERCASE"
          ]
        }
      }
    }
  },
  "storage": {
    "plugins": {
      "awsS3StoragePlugin": {
        "bucket": "mward-storage",
        "region": "ap-south-1",
        "accessLevel": "public"
      }
    }
  },
  "analytics": {
    "plugins": {
      "awsPinpointAnalyticsPlugin": {
        "pinpointAnalyticsClientId": "mward-analytics",
        "region": "ap-south-1",
        "appId": "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
      }
    }
  }
}''';
