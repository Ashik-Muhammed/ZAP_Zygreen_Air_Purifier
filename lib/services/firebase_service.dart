// ignore_for_file: empty_catches

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
      }
    } catch (e) {
    }
    
    _deviceId ??= '000000000000'; // Default to your device ID
    return _deviceId!;
  }

  // Get a stream of the latest sensor data
  Stream<Map<String, dynamic>> getSensorData() async* {
    try {
      final deviceId = await getDeviceId();
      
      yield* _database
          .child('devices')
          .child(deviceId)
          .onValue
          .asyncMap((event) {
            
            if (event.snapshot.value == null) {
              return _getDefaultData();
            }
            
            final data = event.snapshot.value;
            
            // Handle the case where data is already the sensor data
            if (data is Map) {
              return _parseSensorData(Map<String, dynamic>.from(data));
            }
            
            return _getDefaultData();
          });
    } catch (e) {
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
      // Check if data is already in the expected format (flattened)
      if (data.containsKey('temperature') && 
          data.containsKey('humidity') && 
          data.containsKey('airQuality') &&
          data.containsKey('pm25') &&
          data.containsKey('pm10') &&
          data.containsKey('eco2') &&
          data.containsKey('voc') &&
          data.containsKey('timestamp')) {
            
        return {
          'temperature': data['temperature'] is double ? data['temperature'] : (data['temperature'] as num).toDouble(),
          'humidity': data['humidity'] is double ? data['humidity'] : (data['humidity'] as num).toDouble(),
          'airQuality': data['airQuality'] is int ? data['airQuality'] : (data['airQuality'] as num).toInt(),
          'pm25': data['pm25'] is double ? data['pm25'] : (data['pm25'] as num).toDouble(),
          'pm10': data['pm10'] is double ? data['pm10'] : (data['pm10'] as num).toDouble(),
          'eco2': data['eco2'] is int ? data['eco2'] : (data['eco2'] as num).toInt(),
          'voc': data['voc'] is int ? data['voc'] : (data['voc'] as num).toInt(),
          'timestamp': data['timestamp'] is int ? data['timestamp'] : 0,
        };
      }
      
      // Handle nested structure with 'latest' key
      if (data.containsKey('latest') && data['latest'] is Map) {
        final latest = Map<String, dynamic>.from(data['latest'] as Map);
        // Include connection info if available
        final connectionInfo = data.containsKey('connection') && data['connection'] is Map
            ? Map<String, dynamic>.from(data['connection'] as Map)
            : <String, dynamic>{};
        
        
        return {
          'temperature': latest['temperature'] is double 
              ? latest['temperature'] 
              : (latest['temperature'] as num?)?.toDouble() ?? 0.0,
              
          'humidity': latest['humidity'] is double 
              ? latest['humidity'] 
              : (latest['humidity'] as num?)?.toDouble() ?? 0.0,
              
          'airQuality': latest['airQuality'] is int 
              ? latest['airQuality'] 
              : (latest['airQuality'] as num?)?.toInt() ?? 0,
              
          'pm25': latest['pm25'] is double 
              ? latest['pm25'] 
              : (latest['pm25'] as num?)?.toDouble() ?? 0.0,
              
          'pm10': latest['pm10'] is double 
              ? latest['pm10'] 
              : (latest['pm10'] as num?)?.toDouble() ?? 0.0,
              
          'eco2': latest['eco2'] is int 
              ? latest['eco2'] 
              : (latest['eco2'] as num?)?.toInt() ?? 0,
              
          'voc': latest['voc'] is int 
              ? latest['voc'] 
              : (latest['voc'] as num?)?.toInt() ?? 0,
              
          'timestamp': latest['timestamp'] is int 
              ? latest['timestamp'] 
              : DateTime.now().millisecondsSinceEpoch,
              
          'connection': connectionInfo,
        };
      }
      
      return _getDefaultData();
      
    } catch (e) {
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
      'eco2': 0,
      'voc': 0,
      'timestamp': 0,
      'connection': {
        'connected': false,
        'ip': '0.0.0.0',
        'rssi': 0,
        'ssid': 'Not Connected'
      },
    };
  }
  
  // Get the latest sensor data once
  Future<Map<String, dynamic>> getLatestSensorData() async {
    try {
      final deviceId = await getDeviceId();
      // Get the entire device data which includes both latest readings and connection info
      final snapshot = await _database.child('devices/$deviceId').get();
      
      if (snapshot.exists) {
        return _parseSensorData(Map<String, dynamic>.from(snapshot.value as Map));
      }
      
      return _getDefaultData();
    } catch (e) {
      rethrow;
    }
  }

  // Clean up resources when the service is no longer needed
  void dispose() {
    // In the current implementation, we don't have any persistent connections
    // that need to be manually disposed. The Firebase Database client will
    // handle cleanup automatically when the app is closed.
    _deviceId = null; // Reset the device ID
  }
}
