import 'package:firebase_database/firebase_database.dart';

class FirebaseService {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  final String _deviceId = 'device_01'; // Match the device ID in your ESP32 code

  // Get a stream of sensor data
  Stream<Map<String, dynamic>> getSensorData() {
    return _database
        .child('devices')
        .child(_deviceId)
        .onValue
        .map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      return {
        'temperature': data?['temperature']?.toDouble() ?? 0.0,
        'humidity': data?['humidity']?.toDouble() ?? 0.0,
        'airQuality': data?['airQuality']?.toInt() ?? 0,
        'pm25': data?['pm25']?.toDouble() ?? 0.0,
        'pm10': data?['pm10']?.toDouble() ?? 0.0,
        'timestamp': data?['timestamp'] ?? 0,
      };
    });
  }

  // Get the latest sensor data once
  Future<Map<String, dynamic>> getLatestSensorData() async {
    final snapshot = await _database.child('devices').child(_deviceId).get();
    if (snapshot.exists) {
      final data = snapshot.value as Map<dynamic, dynamic>;
      return {
        'temperature': data['temperature']?.toDouble() ?? 0.0,
        'humidity': data['humidity']?.toDouble() ?? 0.0,
        'airQuality': data['airQuality']?.toInt() ?? 0,
        'pm25': data['pm25']?.toDouble() ?? 0.0,
        'pm10': data['pm10']?.toDouble() ?? 0.0,
        'timestamp': data['timestamp'] ?? 0,
      };
    }
    return {
      'temperature': 0.0,
      'humidity': 0.0,
      'airQuality': 0,
      'pm25': 0.0,
      'pm10': 0.0,
      'timestamp': 0,
    };
  }
}
