import 'package:flutter/foundation.dart';
import 'package:zygreen_air_purifier/services/esp32_service.dart';

class ESP32Provider with ChangeNotifier {
  final ESP32Service _esp32Service = ESP32Service();
  bool _isConnected = false;
  Map<String, dynamic> _sensorData = {};
  
  bool get isConnected => _isConnected;
  Map<String, dynamic> get sensorData => _sensorData;
  
  ESP32Provider() {
    _init();
  }
  
  Future<void> _init() async {
    // Listen to connection status changes
    _esp32Service.sensorDataStream.listen((data) {
      _sensorData = data;
      _isConnected = true;
      notifyListeners();
    }, onError: (error) {
      _isConnected = false;
      notifyListeners();    
    });
    
    // Initial connection
    await connect();
  }
  
  Future<void> connect() async {
    await _esp32Service.connect();
  }
  
  Future<void> disconnect() async {
    await _esp32Service.disconnect();
    _isConnected = false;
    notifyListeners();
  }
  
  void sendData(dynamic data) {
    _esp32Service.sendData(data);
  }
  
  @override
  void dispose() {
    _esp32Service.dispose();
    super.dispose();
  }
}
