import 'package:flutter/foundation.dart';
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

  ESP32Provider() {
    _init();
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
    } catch (e) {
      debugPrint('Error fetching device info: $e');
    }
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
    notifyListeners();
  }

  @override
  void dispose() {
    _esp32Service.dispose();
    super.dispose();
  }
}
