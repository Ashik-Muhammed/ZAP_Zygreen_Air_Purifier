class AppConstants {
  // App
  static const String appName = 'Zygreen Air Purifier';
  
  // Firebase Collections
  static const String usersCollection = 'users';
  static const String devicesCollection = 'devices';
  static const String readingsCollection = 'readings';
  static const String predictionsCollection = 'predictions';
  
  // Shared Preferences Keys
  static const String isFirstLaunch = 'is_first_launch';
  static const String currentDeviceId = 'current_device_id';
  static const String userEmail = 'user_email';
  
  // Default values
  static const double defaultCO2 = 400.0;
  static const double defaultPM25 = 0.0;
  static const double defaultTemp = 25.0;
  static const double defaultHumidity = 50.0;
  
  // Thresholds
  static const double goodAQIThreshold = 50.0;
  static const double moderateAQIThreshold = 100.0;
  static const double unhealthyForSensitiveGroupsAQIThreshold = 150.0;
  static const double unhealthyAQIThreshold = 200.0;
  static const double veryUnhealthyAQIThreshold = 300.0;
  static const double hazardousAQIThreshold = 500.0;
  
  // Update intervals (in milliseconds)
  static const int sensorUpdateInterval = 5000; // 5 seconds
  static const int dashboardRefreshInterval = 30000; // 30 seconds
  
  // AI Prediction
  static const int predictionWindowHours = 24;
}
