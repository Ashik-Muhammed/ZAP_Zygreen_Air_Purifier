// ignore_for_file: empty_catches

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:zygreen_air_purifier/services/firebase_service.dart';

class SensorProvider with ChangeNotifier {
  final bool _isDisposed = false;
  StreamSubscription<Map<String, dynamic>>? _subscription;
  final FirebaseService _firebaseService = FirebaseService();
  String? _deviceId;
  Map<String, dynamic> _sensorData = {
    'temperature': 0.0,
    'humidity': 0.0,
    'airQuality': 0,
    'pm25': 0.0,
    'pm10': 0.0,
    'eco2': 0,
    'voc': 0,
    'timestamp': 0,
  };
  bool _isLoading = false;
  String? _error;

  // Getters with proper type conversion
  double get temperature {
    final value = _sensorData['temperature'];
    if (value == null) return 0.0;
    return value is int ? value.toDouble() : (value as num).toDouble();
  }
  
  double get humidity {
    final value = _sensorData['humidity'];
    if (value == null) return 0.0;
    return value is int ? value.toDouble() : (value as num).toDouble();
  }
  
  int get airQuality {
    final value = _sensorData['airQuality'];
    if (value == null) return 0;
    return value is double ? value.toInt() : (value as num).toInt();
  }
  
  double get pm25 {
    final value = _sensorData['pm25'];
    if (value == null) return 0.0;
    return value is int ? value.toDouble() : (value as num).toDouble();
  }
  
  double get pm10 {
    final value = _sensorData['pm10'];
    if (value == null) return 0.0;
    return value is int ? value.toDouble() : (value as num).toDouble();
  }
  
  int get timestamp {
    final value = _sensorData['timestamp'];
    if (value == null) return 0;
    return value is double ? value.toInt() : (value as num).toInt();
  }
  
  int get eco2 {
    final value = _sensorData['eco2'];
    if (value == null) return 0;
    return value is double ? value.toInt() : (value as num).toInt();
  }
  
  int get voc {
    final value = _sensorData['voc'];
    if (value == null) return 0;
    return value is double ? value.toInt() : (value as num).toInt();
  }
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get deviceId => _deviceId;

  // Initialize the sensor data stream
  Future<void> initSensorData() async {
    if (_isLoading) {
      return;
    }
    
      _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      // Get the device ID first
      _deviceId = await _firebaseService.getDeviceId();
      
      if (_deviceId == null || _deviceId!.isEmpty) {
        throw Exception('No device ID found');
      }
      
      // Get initial data
      try {
        final data = await _firebaseService.getLatestSensorData();
        _sensorData = data;
      } catch (e) {
        _error = 'Error loading initial data: $e';
        notifyListeners();
      }
      
      // Start listening to real-time updates
      _subscription?.cancel();
      _subscription = _firebaseService.getSensorData().listen(
        (data) {
          _sensorData = data;
          _error = null;
          _isLoading = false;
          notifyListeners();
        },
        onError: (error) {
          _error = 'Error in sensor data stream: $error';
          _isLoading = false;
          notifyListeners();
        },
        cancelOnError: false,
      );
      
    } catch (e) {
      _error = 'Failed to initialize: $e';
      _isLoading = false;
      notifyListeners();
    }
    
    _isLoading = true;
    _error = null;
    
    // Schedule the notification for the next frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isDisposed) {
        notifyListeners();
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
          if (!_isDisposed) {
            notifyListeners();
          }
        });
      }
    }).catchError((error) {
      if (_isDisposed) return;
      _error = 'Failed to load sensor data: $error';
      _isLoading = false;
      if (!_isDisposed) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!_isDisposed) {
            notifyListeners();
          }
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
            if (!_isDisposed) {
              notifyListeners();
            }
          });
        }
      },
      onError: (error) {
        if (_isDisposed) return;
        _error = 'Error in sensor data stream: $error';
        _isLoading = false;
          if (!_isDisposed) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!_isDisposed) {
              notifyListeners();
            }
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

  Future<void> clearDeviceData() async {

    // Cancel any active subscription first
    await _subscription?.cancel();
    _subscription = null;
    
    // Reset all state
    _deviceId = null;
    _sensorData = {
      'temperature': 0.0,
      'humidity': 0.0,
      'airQuality': 0,
      'pm25': 0.0,
      'pm10': 0.0,
      'timestamp': 0,
    };
    _error = null;
    _isLoading = false;
    
    // Reset the Firebase service
    try {
      _firebaseService.dispose();
    } catch (e) {
    }
    
    
    // Notify listeners if still mounted
    if (!_isDisposed) {
      notifyListeners();
    }
  }
}
