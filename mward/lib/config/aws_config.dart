class AWSConfig {
  // AWS Region
  static const String region = 'ap-south-1';

  // Cognito Configuration
  static const String cognitoUserPoolId = 'ap-south-1_XXXXXXXXX';
  static const String cognitoClientId = 'your-client-id';
  static const String cognitoIdentityPoolId = 'ap-south-1:XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX';

  // API Gateway
  static const String apiEndpoint = 'https://your-api-gateway-url.amazonaws.com/graphql';
  static const String apiKey = 'your-api-key';

  // S3 Configuration
  static const String s3BucketName = 'mward-images';
  static const String s3BucketRegion = 'ap-south-1';
  static const String s3BucketArn = 'arn:aws:s3:::mward-images';

  // Pinpoint Configuration
  static const String pinpointAppId = 'your-pinpoint-app-id';
  static const String pinpointRegion = 'ap-south-1';

  // AppSync Configuration
  static const String appsyncApiUrl = 'https://your-appsync-url.amazonaws.com/graphql';
  static const String appsyncRegion = 'ap-south-1';
  static const String appsyncApiKey = 'your-appsync-api-key';

  // Lambda Configuration
  static const String lambdaRegion = 'ap-south-1';
  static const String createComplaintFunction = 'mward-create-complaint';
  static const String updateComplaintFunction = 'mward-update-complaint';
  static const String getComplaintsFunction = 'mward-get-complaints';
  static const String createNotificationFunction = 'mward-create-notification';

  // SNS Configuration
  static const String snsTopicArn = 'arn:aws:sns:ap-south-1:123456789012:mward-notifications';
  static const String smsTopicArn = 'arn:aws:sns:ap-south-1:123456789012:mward-sms';

  // CloudFront Configuration
  static const String cloudFrontDomain = 'd1234567890.cloudfront.net';
  static const String cloudFrontDistributionId = 'E1234567890123';

  // DynamoDB Configuration
  static const String usersTable = 'mward-users';
  static const String complaintsTable = 'mward-complaints';
  static const String notificationsTable = 'mward-notifications';
  static const String wardsTable = 'mward-wards';

  // Configuration Flags
  static const bool enableAnalytics = true;
  static const bool enablePushNotifications = true;
  static const bool enableOfflineSync = true;
  static const bool enableCrashReporting = true;

  // Timeouts
  static const int apiTimeout = 30000; // 30 seconds
  static const int uploadTimeout = 60000; // 60 seconds
  static const int downloadTimeout = 30000; // 30 seconds

  // Retry Configuration
  static const int maxRetries = 3;
  static const int retryDelay = 1000; // 1 second

  // Log Configuration
  static const bool enableLogging = true;
  static const String logLevel = 'INFO'; // DEBUG, INFO, WARNING, ERROR

  // Feature Flags
  static const bool enableImageCompression = true;
  static const bool enableLocationServices = true;
  static const bool enablePushNotificationsAdmin = true;
  static const bool enableBroadcastNotifications = true;
}
