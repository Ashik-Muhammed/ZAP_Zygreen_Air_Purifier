import 'package:flutter/foundation.dart';
import 'package:zygreen_air_purifier/services/firebase_service.dart';

class SensorProvider with ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  Map<String, dynamic> _sensorData = {
    'temperature': 0.0,
    'humidity': 0.0,
    'airQuality': 0,
    'pm25': 0.0,
    'pm10': 0.0,
    'timestamp': 0,
  };
  bool _isLoading = false;
  String? _error;

  // Getters
  double get temperature => _sensorData['temperature']?.toDouble() ?? 0.0;
  double get humidity => _sensorData['humidity']?.toDouble() ?? 0.0;
  int get airQuality => _sensorData['airQuality']?.toInt() ?? 0;
  double get pm25 => _sensorData['pm25']?.toDouble() ?? 0.0;
  double get pm10 => _sensorData['pm10']?.toDouble() ?? 0.0;
  int get timestamp => _sensorData['timestamp'] ?? 0;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Initialize the sensor data stream
  void initSensorData() {
    _isLoading = true;
    _error = null;
    notifyListeners();

    // Get initial data
    _firebaseService.getLatestSensorData().then((data) {
      _sensorData = data;
      _isLoading = false;
      notifyListeners();
    }).catchError((error) {
      _error = 'Failed to load sensor data: $error';
      _isLoading = false;
      notifyListeners();
    });

    // Subscribe to real-time updates
    _firebaseService.getSensorData().listen(
      (data) {
        _sensorData = data;
        _isLoading = false;
        _error = null;
        notifyListeners();
      },
      onError: (error) {
        _error = 'Error in sensor data stream: $error';
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  // Refresh sensor data
  Future<void> refreshSensorData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await _firebaseService.getLatestSensorData();
      _sensorData = data;
      _error = null;
    } catch (error) {
      _error = 'Failed to refresh sensor data: $error';
    }

    _isLoading = false;
    notifyListeners();
  }
}
