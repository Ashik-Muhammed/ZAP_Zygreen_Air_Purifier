// lib/services/esp32_service.dart
import 'dart:async';
import 'dart:developer' as developer;
import 'package:firebase_database/firebase_database.dart';

class ESP32Service {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  final StreamController<Map<String, dynamic>> _dataController = 
      StreamController<Map<String, dynamic>>.broadcast();
      
  StreamSubscription<DatabaseEvent>? _dataSubscription;
  String? _currentDeviceId;
  bool _isConnected = false;

  bool get isConnected => _isConnected;
  String? get currentDeviceId => _currentDeviceId;
  Stream<Map<String, dynamic>> get sensorDataStream => _dataController.stream;
  DatabaseReference get database => _database;

  Future<bool> connectToDevice(String deviceId, {String? userId}) async {
    try {
      await disconnect();
      _currentDeviceId = deviceId;
      
      // Check if device exists
      final deviceRef = _database.child('devices/$deviceId');
      final snapshot = await deviceRef.once();
      
      if (!snapshot.snapshot.exists) {
        developer.log('Device $deviceId not found in database', name: 'ESP32Service');
        return false;
      }

      // Listen to device data
      _dataSubscription = _database
          .child('devices/$deviceId/latest')
          .onValue
          .listen((event) {
        developer.log('Firebase data received: ${event.snapshot.value}', name: 'ESP32Service');
        
        if (event.snapshot.value != null) {
          try {
            final data = Map<String, dynamic>.from(event.snapshot.value as Map);
            data['timestamp'] = data['timestamp'] ?? DateTime.now().millisecondsSinceEpoch;
            
            // Also get connection info
            _database.child('devices/$deviceId/connection').once().then((connSnapshot) {
              if (connSnapshot.snapshot.value != null) {
                final connData = Map<String, dynamic>.from(connSnapshot.snapshot.value as Map);
                data.addAll({
                  'ip': connData['ip'],
                  'rssi': connData['rssi'],
                  'ssid': connData['ssid']
                });
              }
              
              _isConnected = true;
              _dataController.add(data);
            });
          } catch (e) {
            developer.log('Error parsing data: $e', name: 'ESP32Service', error: e);
            _dataController.addError(e);
          }
        } else {
          developer.log('Received null data from Firebase', name: 'ESP32Service');
        }
      }, onError: (error) {
        developer.log('Firebase stream error: $error', name: 'ESP32Service', error: error);
        _isConnected = false;
        _dataController.addError(error);
      });

      return true;
    } catch (e) {
      _isConnected = false;
      _dataController.addError(e);
      rethrow;
    }
  }

  Future<void> sendCommand(String command, dynamic value) async {
    if (_currentDeviceId == null) {
      throw Exception('No device connected');
    }
    
    await _database
        .child('devices/$_currentDeviceId/commands/$command')
        .set(value);
  }

  Future<void> disconnect() async {
    await _dataSubscription?.cancel();
    _dataSubscription = null;
    _currentDeviceId = null;
    _isConnected = false;
  }

  void dispose() {
    disconnect();
    _dataController.close();
  }
}