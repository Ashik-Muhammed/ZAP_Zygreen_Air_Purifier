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
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get deviceId => _deviceId;

  // Initialize the sensor data stream
  Future<void> initSensorData() async {
    if (_isLoading) {
      debugPrint('SensorProvider: Already loading, skipping init');
      return;
    }
    
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      // Get the device ID first
      _deviceId = await _firebaseService.getDeviceId();
      debugPrint('SensorProvider: Using device ID: $_deviceId');
      
      if (_deviceId == null || _deviceId!.isEmpty) {
        throw Exception('No device ID found');
      }
      
      // Get initial data
      try {
        final data = await _firebaseService.getLatestSensorData();
        _sensorData = data;
        debugPrint('Initial sensor data: $_sensorData');
      } catch (e) {
        debugPrint('Error getting initial data: $e');
        _error = 'Error loading initial data: $e';
        notifyListeners();
      }
      
      // Start listening to real-time updates
      _subscription?.cancel();
      _subscription = _firebaseService.getSensorData().listen(
        (data) {
          debugPrint('Received sensor data update: $data');
          _sensorData = data;
          _error = null;
          _isLoading = false;
          notifyListeners();
        },
        onError: (error) {
          debugPrint('Error in sensor data stream: $error');
          _error = 'Error in sensor data stream: $error';
          _isLoading = false;
          notifyListeners();
        },
        cancelOnError: false,
      );
      
    } catch (e) {
      debugPrint('Error initializing sensor data: $e');
      _error = 'Failed to initialize: $e';
      _isLoading = false;
      notifyListeners();
    }
    
    _isLoading = true;
    _error = null;
    debugPrint('SensorProvider: Initializing sensor data...');
    
    // Schedule the notification for the next frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isDisposed) {
        debugPrint('SensorProvider: Notifying listeners (initial loading state)');
        notifyListeners();
      }
    });

    // Get initial data
    debugPrint('SensorProvider: Fetching latest sensor data...');
    _firebaseService.getLatestSensorData().then((data) {
      if (_isDisposed) return;
      debugPrint('SensorProvider: Received initial data: $data');
      _sensorData = data;
      _isLoading = false;
      if (!_isDisposed) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!_isDisposed) {
            debugPrint('SensorProvider: Notifying listeners after initial data load');
            notifyListeners();
          }
        });
      }
    }).catchError((error) {
      if (_isDisposed) return;
      _error = 'Failed to load sensor data: $error';
      _isLoading = false;
      debugPrint('SensorProvider: Error loading initial data: $error');
      if (!_isDisposed) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!_isDisposed) {
            debugPrint('SensorProvider: Notifying listeners after error');
            notifyListeners();
          }
        });
      }
    });

    // Cancel any existing subscription
    _subscription?.cancel();
    
    // Subscribe to real-time updates
    debugPrint('SensorProvider: Subscribing to real-time updates');
    _subscription = _firebaseService.getSensorData().listen(
      (data) {
        if (_isDisposed) return;
        debugPrint('SensorProvider: Received real-time update: $data');
        _sensorData = data;
        _isLoading = false;
        _error = null;
        if (!_isDisposed) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!_isDisposed) {
              debugPrint('SensorProvider: Notifying listeners after real-time update');
              notifyListeners();
            }
          });
        }
      },
      onError: (error) {
        if (_isDisposed) return;
        _error = 'Error in sensor data stream: $error';
        _isLoading = false;
        debugPrint('SensorProvider: Error in real-time stream: $error');
        if (!_isDisposed) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!_isDisposed) {
              debugPrint('SensorProvider: Notifying listeners after stream error');
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
    debugPrint('SensorProvider: Clearing device data and resetting state');
    
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
      debugPrint('Error resetting Firebase service: $e');
    }
    
    debugPrint('SensorProvider: Device data cleared and state reset');
    
    // Notify listeners if still mounted
    if (!_isDisposed) {
      notifyListeners();
    }
  }
}
