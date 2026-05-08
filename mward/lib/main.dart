import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';
import 'package:amplify_analytics_pinpoint/amplify_analytics_pinpoint.dart';
import 'package:amplify_datastore/amplify_datastore.dart';
import 'package:provider/provider.dart';

import 'config/theme_config.dart';
import 'config/mock_config.dart';
import 'screens/auth/splash_screen.dart';
import 'providers/auth_provider.dart' as local;
import 'providers/complaint_provider.dart';
import 'providers/user_provider.dart';
import 'providers/notification_provider.dart';
import 'providers/mock/mock_auth_provider.dart';
import 'providers/mock/mock_complaint_provider.dart';
import 'providers/mock/mock_notification_provider.dart';
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
    final auth = AmplifyAuthCognito();
    final api = AmplifyAPI();
    final storage = AmplifyStorageS3();
    final analytics = AmplifyAnalyticsPinpoint();
    // Note: AmplifyDataStore requires ModelProvider configuration
    // Disabled for now as it requires model setup
    // final datastore = AmplifyDataStore();

    await Amplify.addPlugins([
      auth,
      api,
      storage,
      analytics,
      // datastore,
    ]);

    await Amplify.configure(amplifyconfig);
  } catch (e) {
    debugPrint('Error configuring Amplify: $e');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final app = MultiProvider(
      providers: _getProviders(),
      child: MaterialApp(
        title: 'mWard',
        debugShowCheckedModeBanner: !MockConfig.isMockMode,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.light,
        home: const SplashScreen(),
      ),
    );

    // Wrap with MockModeBanner if in mock mode
    if (MockConfig.isMockMode) {
      return MockModeBanner(child: app);
    }

    return app;
  }

  List<ChangeNotifierProvider> _getProviders() {
    if (MockConfig.isMockMode) {
      debugPrint('Mock Mode: Using mock providers');
      return [
        ChangeNotifierProvider(create: (_) => MockAuthProvider()),
        ChangeNotifierProvider(create: (_) => MockComplaintProvider()),
        ChangeNotifierProvider(create: (_) => MockNotificationProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ];
    } else {
      debugPrint('Production Mode: Using real providers');
      return [
        ChangeNotifierProvider(create: (_) => local.AuthProvider()),
        ChangeNotifierProvider(create: (_) => ComplaintProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ];
    }
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
        "UserAgent": "aws-amplify-cli/2.0",
        "Version": "1.0",
        "IdentityManager": {
          "Default": {}
        },
        "CognitoUserPool": {
          "Default": {
            "PoolId": "ap-south-1_XXXXXXXXX",
            "AppClientId": "your-client-id",
            "Region": "ap-south-1"
          }
        },
        "Auth": {
          "Default": {
            "authenticationFlowType": "USER_SRP_AUTH"
          }
        }
      }
    }
  },
  "storage": {
    "plugins": {
      "awsS3StoragePlugin": {
        "bucket": "mward-images",
        "region": "ap-south-1",
        "defaultAccessLevel": "guest"
      }
    }
  },
  "analytics": {
    "plugins": {
      "awsPinpointAnalyticsPlugin": {
        "Pinpoint": {
          "appId": "your-pinpoint-app-id",
          "region": "ap-south-1"
        }
      }
    }
  }
}
''';
