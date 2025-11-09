import 'package:firebase_database/firebase_database.dart';

class FirebaseService {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  String? _deviceId;
  
  // Get the first available device ID if not set
  Future<String> _getDeviceId() async {
    if (_deviceId != null) return _deviceId!;
    
    try {
      final snapshot = await _database.child('devices').limitToFirst(1).get();
      if (snapshot.exists) {
        _deviceId = snapshot.children.first.key;
      }
    } catch (e) {
//handle silently
    }
    
    _deviceId ??= 'unknown_device';
    return _deviceId!;
  }

  // Get a stream of the latest sensor data
  Stream<Map<String, dynamic>> getSensorData() async* {
    final deviceId = await _getDeviceId();
    
    yield* _database
        .child('devices')
        .child(deviceId)
        .orderByChild('timestamp')
        .limitToLast(1)
        .onValue
        .asyncMap((event) {
          if (event.snapshot.value == null) return _getDefaultData();
          
          // Get the most recent entry
          final data = event.snapshot.value as Map<dynamic, dynamic>;
          final latestEntry = data.values.last as Map<dynamic, dynamic>;
          
          return _parseSensorData(latestEntry);
        });
  }
  
  // Get historical data for charts
  Stream<List<Map<String, dynamic>>> getHistoricalData({int limit = 20}) async* {
    final deviceId = await _getDeviceId();
    
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
              .map<Map<String, dynamic>>((entry) => _parseSensorData(entry as Map<dynamic, dynamic>))
              .toList();
        });
  }
  
  // Parse sensor data from Firebase
  Map<String, dynamic> _parseSensorData(Map<dynamic, dynamic> data) {
    return {
      'temperature': data['temperature']?.toDouble() ?? 0.0,
      'humidity': data['humidity']?.toDouble() ?? 0.0,
      'airQuality': data['airQuality']?.toInt() ?? 0,
      'pm25': data['pm2_5']?.toDouble() ?? 0.0, // Note: Using pm2_5 to match ESP32 code
      'pm10': data['pm10']?.toDouble() ?? 0.0,
      'timestamp': data['timestamp'] ?? 0,
    };
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
    final deviceId = await _getDeviceId();
    final snapshot = await _database
        .child('devices')
        .child(deviceId)
        .orderByChild('timestamp')
        .limitToLast(1)
        .get();
        
    if (snapshot.exists) {
      final data = snapshot.value as Map<dynamic, dynamic>;
      final latestEntry = data.values.last as Map<dynamic, dynamic>;
      return _parseSensorData(latestEntry);
    }
    
    return _getDefaultData();
  }
}
