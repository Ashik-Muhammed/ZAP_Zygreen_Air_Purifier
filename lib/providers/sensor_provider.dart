import 'dart:async';
import 'package:flutter/material.dart';
import 'package:zygreen_air_purifier/services/firebase_service.dart';

class SensorProvider with ChangeNotifier {
  final bool _isDisposed = false;
  StreamSubscription<Map<String, dynamic>>? _subscription;
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
    if (_isLoading) return;
    
    _isLoading = true;
    _error = null;
    
    // Schedule the notification for the next frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isDisposed) {
        notifyListeners();
      }
    });

    // Get initial data
    _firebaseService.getLatestSensorData().then((data) {
      if (_isDisposed) return;
      _sensorData = data;
      _isLoading = false;
      if (!_isDisposed) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!_isDisposed) notifyListeners();
        });
      }
    }).catchError((error) {
      if (_isDisposed) return;
      _error = 'Failed to load sensor data: $error';
      _isLoading = false;
      if (!_isDisposed) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!_isDisposed) notifyListeners();
        });
      }
    });

    // Cancel any existing subscription
    _subscription?.cancel();
    
    // Subscribe to real-time updates
    _subscription = _firebaseService.getSensorData().listen(
      (data) {
        if (_isDisposed) return;
        _sensorData = data;
        _isLoading = false;
        _error = null;
        if (!_isDisposed) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!_isDisposed) notifyListeners();
          });
        }
      },
      onError: (error) {
        if (_isDisposed) return;
        _error = 'Error in sensor data stream: $error';
        _isLoading = false;
        if (!_isDisposed) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!_isDisposed) notifyListeners();
          });
        }
      },
      cancelOnError: false,
    );
  }

  // Refresh sensor data
  Future<void> refreshSensorData() async {
    if (_isLoading) return;
    
    _isLoading = true;
    
    // Schedule the notification for the next frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isDisposed) {
        notifyListeners();
      }
    });

    try {
      final data = await _firebaseService.getLatestSensorData();
      if (_isDisposed) return;
      
      _sensorData = data;
      _error = null;
    } catch (error) {
      if (_isDisposed) return;
      _error = 'Failed to refresh sensor data: $error';
    }

    _isLoading = false;
    if (!_isDisposed) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_isDisposed) notifyListeners();
      });
    }
  }
}
