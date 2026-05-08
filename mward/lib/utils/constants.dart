class AppConstants {
  // App Info
  static const String appName = 'mWard';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Ward issue reporting for Himachal Pradesh';

  // API Configuration
  static const String apiBaseUrl = 'https://your-api-gateway-url.amazonaws.com';
  static const String apiVersion = 'v1';
  static const int apiTimeout = 30000; // 30 seconds

  // AWS Configuration
  static const String awsRegion = 'ap-south-1';
  static const String cognitoUserPoolId = 'ap-south-1_XXXXXXXXX';
  static const String cognitoClientId = 'your-client-id';
  static const String s3BucketName = 'mward-images';
  static const String pinpointAppId = 'your-pinpoint-app-id';

  // Storage
  static const int maxImageSize = 5 * 1024 * 1024; // 5MB
  static const int maxImageWidth = 1024;
  static const int maxImageHeight = 1024;
  static const int imageQuality = 80;

  // Media
  static const int maxVideoSize = 100 * 1024 * 1024; // 100MB
  static const int maxVideoDuration = 120; // 2 minutes in seconds
  static const int maxAudioSize = 10 * 1024 * 1024; // 10MB
  static const int maxAudioDuration = 60; // 1 minute in seconds
  static const int audioSampleRate = 44100;
  static const int audioBitRate = 128000;
  static const int maxMediaFiles = 5; // Maximum photos/videos per complaint

  // Location
  static const double defaultLocationAccuracy = 100.0; // meters
  static const int locationTimeout = 10000; // 10 seconds

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // Cache
  static const int cacheMaxAge = 3600; // 1 hour in seconds

  // Notification
  static const String fcmServerKey = 'your-fcm-server-key';
  static const int notificationMaxRetries = 3;

  // Complaint Categories
  static const List<String> complaintCategories = [
    'Water Supply',
    'Roads',
    'Drainage',
    'Street Lights',
    'Garbage Collection',
    'Public Health',
    'Electricity',
    'Building',
    'Park & Recreation',
    'Traffic',
    'Noise Pollution',
    'Other',
  ];

  // Complaint Categories (Hindi)
  static const List<String> complaintCategoriesHindi = [
    'पानी की आपूर्ति',
    'सड़कें',
    'जल निकासी',
    'स्ट्रीट लाइट',
    'कूड़ा संग्रह',
    'सार्वजनिक स्वास्थ्य',
    'बिजली',
    'भवन',
    'पार्क और मनोरंजन',
    'यातायात',
    'ध्वनि प्रदूषण',
    'अन्य',
  ];

  // Priorities
  static const List<String> priorities = ['low', 'medium', 'high'];
  static const List<String> prioritiesHindi = ['कम', 'मध्यम', 'उच्च'];

  // Status
  static const List<String> statuses = ['pending', 'in-progress', 'resolved', 'rejected'];
  static const List<String> statusesHindi = ['लंबित', 'प्रगति में', 'हल', 'अस्वीकृत'];

  // Notification Types
  static const List<String> notificationTypes = ['news', 'alert', 'update', 'broadcast'];
  static const List<String> notificationTypesHindi = ['समाचार', 'चेतावनी', 'अपडेट', 'प्रसारण'];

  // Default Wards (Himachal Pradesh - Shimla)
  static const List<Map<String, String>> defaultWards = [
    {
      'code': 'WARD-001',
      'name': 'Sanjauli',
      'nameHindi': 'संजौली',
      'city': 'Shimla',
      'district': 'Shimla',
    },
    {
      'code': 'WARD-002',
      'name': 'Summer Hill',
      'nameHindi': 'समर हिल',
      'city': 'Shimla',
      'district': 'Shimla',
    },
    {
      'code': 'WARD-003',
      'name': 'Chotta Shimla',
      'nameHindi': 'छोटा शिमला',
      'city': 'Shimla',
      'district': 'Shimla',
    },
    {
      'code': 'WARD-004',
      'name': 'Boileauganj',
      'nameHindi': 'बॉयलगंज',
      'city': 'Shimla',
      'district': 'Shimla',
    },
    {
      'code': 'WARD-005',
      'name': 'Lakkar Bazar',
      'nameHindi': 'लक्कड़ बाज़ार',
      'city': 'Shimla',
      'district': 'Shimla',
    },
  ];

  // User Roles
  static const String roleAdmin = 'admin';
  static const String roleUser = 'user';

  // Phone Number Validation
  static const String indianPhoneRegex = r'^[+]?[0-9]{10,15}$';
  static const int phoneMinLength = 10;
  static const int phoneMaxLength = 15;

  // Date/Time Formats
  static const String dateFormat = 'dd/MM/yyyy';
  static const String timeFormat = 'HH:mm';
  static const String dateTimeFormat = 'dd/MM/yyyy HH:mm';

  // Image Placeholder
  static const String defaultAvatarUrl = 'https://via.placeholder.com/150';
  static const String defaultComplaintImage = 'https://via.placeholder.com/400x300';

  // Error Messages
  static const String errorMessageGeneric = 'Something went wrong. Please try again.';
  static const String errorMessageNetwork = 'No internet connection. Please check your network.';
  static const String errorMessageTimeout = 'Request timed out. Please try again.';
  static const String errorMessageUnauthorized = 'Session expired. Please login again.';
  static const String errorMessageNotFound = 'Requested resource not found.';
  static const String errorMessageServer = 'Server error. Please try again later.';

  // Error Messages (Hindi)
  static const String errorMessageGenericHindi = 'कुछ गलत हो गया। कृपया पुनः प्रयास करें।';
  static const String errorMessageNetworkHindi = 'इंटरनेट कनेक्शन नहीं है। कृपया अपना नेटवर्क जांचें।';
  static const String errorMessageTimeoutHindi = 'अनुरोध समय समाप्त। कृपया पुनः प्रयास करें।';
  static const String errorMessageUnauthorizedHindi = 'सत्र समाप्त हो गया। कृपया पुनः लॉगिन करें।';

  // Success Messages
  static const String successMessageComplaintFiled = 'Complaint filed successfully!';
  static const String successMessageComplaintUpdated = 'Complaint updated successfully!';
  static const String successMessageProfileUpdated = 'Profile updated successfully!';
  static const String successMessageNotificationSent = 'Notification sent successfully!';
  static const String successMessageLoggedOut = 'Logged out successfully!';

  // Success Messages (Hindi)
  static const String successMessageComplaintFiledHindi = 'शिकायत सफलतापूर्वक दर्ज की गई!';
  static const String successMessageComplaintUpdatedHindi = 'शिकायत सफलतापूर्वक अपडेट की गई!';
  static const String successMessageProfileUpdatedHindi = 'प्रोफाइल सफलतापूर्वक अपडेट की गई!';
  static const String successMessageNotificationSentHindi = 'अधिसूचना सफलतापूर्वक भेजी गई!';
  static const String successMessageLoggedOutHindi = 'सफलतापूर्वक लॉग आउट!';

  // Validation Messages
  static const String validationRequired = 'This field is required';
  static const String validationInvalidPhone = 'Please enter a valid phone number';
  static const String validationInvalidEmail = 'Please enter a valid email address';
  static const String validationInvalidOTP = 'Please enter a valid OTP';
  static const String validationMinLength = 'Minimum length is';
  static const String validationMaxLength = 'Maximum length is';

  // Validation Messages (Hindi)
  static const String validationRequiredHindi = 'यह फ़ील्ड आवश्यक है';
  static const String validationInvalidPhoneHindi = 'कृपया एक मान्य फ़ोन नंबर दर्ज करें';
  static const String validationInvalidEmailHindi = 'कृपया एक मान्य ईमेल पता दर्ज करें';
  static const String validationInvalidOTPHindi = 'कृपया एक मान्य OTP दर्ज करें';

  // Navigation
  static const int navigationAnimationDuration = 300; // milliseconds

  // Mock Mode
  static const String mockModeBannerText = '⚠️ MOCK MODE - Data is not real';
  static const String mockModeTestPhoneAdmin = '+919876543210';
  static const String mockModeTestPhoneUser = '+919812345678';
  static const String mockModeTestOTP = '123456';
}
