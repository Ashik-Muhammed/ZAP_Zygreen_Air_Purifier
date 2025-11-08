import 'dart:async';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter/foundation.dart';

class ESP32Service {
  static const String _esp32Ip = '192.168.1.100'; // Replace with your ESP32's IP
  static const int _port = 81; // Default WebSocket port for ESP32
  
  WebSocketChannel? _channel;
  final StreamController<Map<String, dynamic>> _dataController = 
      StreamController<Map<String, dynamic>>.broadcast();
  
  bool _isConnected = false;
  
  // Getter for connection status
  bool get isConnected => _isConnected;
  
  // Getter for data stream
  Stream<Map<String, dynamic>> get sensorDataStream => _dataController.stream;
  
  // Initialize WebSocket connection
  Future<void> connect() async {
    try {
      final wsUrl = Uri.parse('ws://$_esp32Ip:$_port');
      _channel = WebSocketChannel.connect(wsUrl);
      
      _channel!.stream.listen(
        (data) {
          try {
            final jsonData = Map<String, dynamic>.from(data as Map);
            _dataController.add(jsonData);
          } catch (e) {
            debugPrint('Error parsing sensor data: $e');
          }
        },
        onError: (error) {
          _isConnected = false;
          debugPrint('WebSocket error: $error');
          _reconnect();
        },
        onDone: () {
          _isConnected = false;
          debugPrint('WebSocket connection closed');
          _reconnect();
        },
        cancelOnError: true,
      );
      
      _isConnected = true;
      debugPrint('Connected to ESP32 WebSocket');
      
    } catch (e) {
      _isConnected = false;
      debugPrint('Failed to connect to ESP32: $e');
      _reconnect();
    }
  }
  
  // Reconnect with exponential backoff
  void _reconnect() {
    const maxReconnectAttempts = 5;
    int attempts = 0;
    
    Future.delayed(Duration(seconds: 1 << attempts), () {
      if (attempts < maxReconnectAttempts) {
        attempts++;
        debugPrint('Attempting to reconnect (attempt $attempts)...');
        connect();
      } else {
        debugPrint('Max reconnection attempts reached');
      }
    });
  }
  
  // Close the WebSocket connection
  Future<void> disconnect() async {
    await _channel?.sink.close();
    _isConnected = false;
    await _dataController.close();
  }
  
  // Send data to ESP32 if needed
  void sendData(dynamic data) {
    if (_isConnected && _channel != null) {
      _channel!.sink.add(data);
    }
  }
  
  // Cleanup
  void dispose() {
    disconnect();
  }
}
