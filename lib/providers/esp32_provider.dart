// ignore_for_file: empty_catches

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zygreen_air_purifier/services/esp32_service.dart';

class ESP32Provider with ChangeNotifier {
  final ESP32Service _esp32Service = ESP32Service();
  bool _isConnected = false;
  bool _isConnecting = false;
  String? _error;
  Map<String, dynamic> _sensorData = {};
  String? _connectedDeviceId;
  String? _firmwareVersion;
  String? _deviceIp;
  
  // Stream for real-time sensor data updates
  Stream<Map<String, dynamic>> get sensorDataStream => _esp32Service.sensorDataStream;
  
  // Get the current device ID
  String? get currentDeviceId => _connectedDeviceId;

  bool get isConnected => _isConnected;
  bool get isConnecting => _isConnecting;
  String? get error => _error;
  Map<String, dynamic> get sensorData => _sensorData;
  String? get connectedDeviceId => _connectedDeviceId;
  String? get firmwareVersion => _firmwareVersion;
  String? get deviceIp => _deviceIp;

  static const String _prefsKey = 'esp32_connection_state';
  
  ESP32Provider() {
    _init();
    _loadConnectionState();
  }

  void _init() {
    // Listen to sensor data stream
    _esp32Service.sensorDataStream.listen(
      (data) {
        _sensorData = data;
        _isConnected = true;
        _isConnecting = false;
        _error = null;
        notifyListeners();
      },
      onError: (error) {
        _isConnected = false;
        _isConnecting = false;
        _error = error.toString();
        _connectedDeviceId = null;
        _firmwareVersion = null;
        _deviceIp = null;
        notifyListeners();
      },
    );
  }

  // Save connection state to shared preferences
  Future<void> _saveConnectionState() async {
    final prefs = await SharedPreferences.getInstance();
    final state = {
      'isConnected': _isConnected,
      'deviceId': _connectedDeviceId,
      'firmwareVersion': _firmwareVersion,
      'deviceIp': _deviceIp,
    };
    await prefs.setString(_prefsKey, jsonEncode(state));
  }

  // Load connection state from shared preferences
  Future<void> _loadConnectionState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final stateJson = prefs.getString(_prefsKey);
      if (stateJson != null) {
        final state = jsonDecode(stateJson) as Map<String, dynamic>;
        if (state['isConnected'] == true && state['deviceId'] != null) {
          // Don't auto-connect here, just restore the state
          _isConnected = state['isConnected'];
          _connectedDeviceId = state['deviceId'];
          _firmwareVersion = state['firmwareVersion'];
          _deviceIp = state['deviceIp'];
          notifyListeners();
        }
      }
    } catch (e) {
    }
  }

  // Connect to a specific ESP32 device
  Future<bool> connectToDevice(String deviceId, {String? userId}) async {
    try {
      _isConnecting = true;
      _error = null;
      _connectedDeviceId = deviceId;
      notifyListeners();

      // Clear any existing connection first
      if (_isConnected) {
        await _esp32Service.disconnect();
      }

      final success = await _esp32Service.connectToDevice(deviceId, userId: userId);
      
      if (success) {
        _connectedDeviceId = deviceId;
        _isConnected = true;
        _isConnecting = false;
        
        // Get device info
        await _fetchDeviceInfo(deviceId);
        
        // Save connection state
        await _saveConnectionState();
        
        // Notify listeners after all updates are complete
        notifyListeners();
        return true;
      } else {
        _error = 'Failed to connect to device';
        _isConnected = false;
        _connectedDeviceId = null;
        _isConnecting = false;
        notifyListeners();
        return false;
      }
      
    } catch (e) {
      _isConnected = false;
      _isConnecting = false;
      _error = e.toString();
      _connectedDeviceId = null;
      _firmwareVersion = null;
      _deviceIp = null;
      notifyListeners();
      rethrow;
    }
  }

  // Fetch device information
  Future<void> _fetchDeviceInfo(String deviceId) async {
    try {
      final database = _esp32Service.database;
      final snapshot = await database.child('devices/$deviceId').once();
      
      if (snapshot.snapshot.value != null) {
        final data = Map<String, dynamic>.from(snapshot.snapshot.value as Map);
        _firmwareVersion = data['firmware'];
        _deviceIp = data['ip'];
        notifyListeners();
      }
    } catch (e) {}
    
  }

  // Send command to the connected device
  Future<void> sendCommand(String command, dynamic value) async {
    try {
      await _esp32Service.sendCommand(command, value);
    } catch (e) {
      _error = 'Failed to send command: ${e.toString()}';
      notifyListeners();
      rethrow;
    }
  }

  // Disconnect from the current device
  Future<void> disconnect() async {
    await _esp32Service.disconnect();
    _isConnected = false;
    _isConnecting = false;
    _connectedDeviceId = null;
    _firmwareVersion = null;
    _deviceIp = null;
    _sensorData = {};
    
    // Clear saved connection state
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefsKey);
    
    notifyListeners();
  }

  @override
  void dispose() {
    _esp32Service.dispose();
    super.dispose();
  }
}
