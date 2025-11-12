import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class FirebaseService {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  String? _deviceId;
  
  // Get the current device ID (synchronous)
  String? get deviceId => _deviceId;
  
  // Get the first available device ID if not set
  Future<String> getDeviceId() async {
    if (_deviceId != null) return _deviceId!;
    
    try {
      final snapshot = await _database.child('devices').get();
      if (snapshot.exists) {
        // Get the first device ID from the devices node
        final devices = Map<String, dynamic>.from(snapshot.value as Map);
        _deviceId = devices.keys.first;
        debugPrint('Found device ID: $_deviceId');
      }
    } catch (e) {
      debugPrint('Error getting device ID: $e');
    }
    
    _deviceId ??= '000000000000'; // Default to your device ID
    debugPrint('Using device ID: $_deviceId');
    return _deviceId!;
  }

  // Get a stream of the latest sensor data
  Stream<Map<String, dynamic>> getSensorData() async* {
    try {
      final deviceId = await getDeviceId();
      debugPrint('FirebaseService: Getting sensor data for device: $deviceId');
      
      yield* _database
          .child('devices')
          .child(deviceId)
          .onValue
          .asyncMap((event) {
            debugPrint('FirebaseService: Received data event: ${event.snapshot.value}');
            
            if (event.snapshot.value == null) {
              debugPrint('FirebaseService: No data found, returning default data');
              return _getDefaultData();
            }
            
            final data = event.snapshot.value;
            debugPrint('FirebaseService: Raw data from Firebase: $data');
            
            // Handle the case where data is already the sensor data
            if (data is Map) {
              return _parseSensorData(Map<String, dynamic>.from(data));
            }
            
            return _getDefaultData();
          });
    } catch (e) {
      debugPrint('FirebaseService: Error in getSensorData: $e');
      yield _getDefaultData();
    }
  }
  
  // Get historical data for charts
  Stream<List<Map<String, dynamic>>> getHistoricalData({int limit = 20}) async* {
    final deviceId = await getDeviceId();
    
    yield* _database
        .child('devices')
        .child(deviceId)
        .orderByChild('timestamp')
        .limitToLast(limit)
        .onValue
        .asyncMap((event) {
          if (event.snapshot.value == null) return <Map<String, dynamic>>[];
          
          final data = event.snapshot.value as Map<dynamic, dynamic>;
          return data.values
              .map<Map<String, dynamic>>((entry) => _parseSensorData(Map<String, dynamic>.from(entry as Map)))
              .toList();
        });
  }
  
  // Parse sensor data from Firebase
  Map<String, dynamic> _parseSensorData(Map<String, dynamic> data) {
    try {
      // Check if data is already in the expected format
      if (data.containsKey('temperature') && 
          data.containsKey('humidity') && 
          data.containsKey('airQuality') &&
          data.containsKey('pm25') &&
          data.containsKey('pm10')) {
        return {
          'temperature': data['temperature'] is double ? data['temperature'] : (data['temperature'] as num).toDouble(),
          'humidity': data['humidity'] is double ? data['humidity'] : (data['humidity'] as num).toDouble(),
          'airQuality': data['airQuality'] is int ? data['airQuality'] : (data['airQuality'] as num).toInt(),
          'pm25': data['pm25'] is double ? data['pm25'] : (data['pm25'] as num).toDouble(),
          'pm10': data['pm10'] is double ? data['pm10'] : (data['pm10'] as num).toDouble(),
          'timestamp': data['timestamp'] is int ? data['timestamp'] : 0,
        };
      }
      
      // If we have a 'latest' key, use that
      if (data.containsKey('latest') && data['latest'] is Map) {
        final latest = Map<String, dynamic>.from(data['latest'] as Map);
        return _parseSensorData(latest);
      }
      
      debugPrint('FirebaseService: Unexpected data format: $data');
      return _getDefaultData();
      
    } catch (e) {
      debugPrint('FirebaseService: Error parsing sensor data: $e');
      return _getDefaultData();
    }
  }
  
  // Default data when no sensor data is available
  Map<String, dynamic> _getDefaultData() {
    return {
      'temperature': 0.0,
      'humidity': 0.0,
      'airQuality': 0,
      'pm25': 0.0,
      'pm10': 0.0,
      'timestamp': 0,
    };
  }
  
  // Get the latest sensor data once
  Future<Map<String, dynamic>> getLatestSensorData() async {
    try {
      final deviceId = await getDeviceId();
      final snapshot = await _database.child('devices/$deviceId/latest').get();
      
      if (snapshot.exists) {
        return _parseSensorData(Map<String, dynamic>.from(snapshot.value as Map));
      }
      
      return _getDefaultData();
    } catch (e) {
      debugPrint('FirebaseService: Error in getLatestSensorData: $e');
      rethrow;
    }
  }

  // Clean up resources when the service is no longer needed
  void dispose() {
    // In the current implementation, we don't have any persistent connections
    // that need to be manually disposed. The Firebase Database client will
    // handle cleanup automatically when the app is closed.
    _deviceId = null; // Reset the device ID
    debugPrint('FirebaseService: Disposed');
  }
}
