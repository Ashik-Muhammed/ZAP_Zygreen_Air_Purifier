import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/esp32_provider.dart';
import '../providers/sensor_provider.dart';

class ConnectDeviceScreen extends StatefulWidget {
  const ConnectDeviceScreen({super.key});

  @override
  State<ConnectDeviceScreen> createState() => _ConnectDeviceScreenState();
}

class _ConnectDeviceScreenState extends State<ConnectDeviceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _deviceIdController = TextEditingController();
  bool _isConnecting = false;

  @override
  void dispose() {
    _deviceIdController.dispose();
    super.dispose();
  }

  Future<void> _connectDevice() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isConnecting = true);
    
    try {
      final esp32Provider = Provider.of<ESP32Provider>(context, listen: false);
      final sensorProvider = Provider.of<SensorProvider>(context, listen: false);
      
      final success = await esp32Provider.connectToDevice(
        _deviceIdController.text.trim()
      );

      if (mounted) {
        if (success) {
          // Clear any existing data and reinitialize sensor data
          await sensorProvider.clearDeviceData();
          await sensorProvider.initSensorData();
          
          if (mounted) {
            Navigator.of(context).pop(true);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Device connected successfully')),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to connect to device')),
          );
        }
      }
    } catch (e) {
      debugPrint('Error connecting to device: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isConnecting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Connect Device'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              const Text(
                'Connect your Device',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _deviceIdController,
                decoration: const InputDecoration(
                  labelText: 'Device ID',
                  hintText: 'Enter your device ID',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a device ID';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              const Text(
                'How to find your Device ID:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                '1. Check behind the device\n'
                '2. Look for a message containing "Device ID:"\n'
                '3. Enter the ID exactly as shown',
                style: TextStyle(color: Colors.grey),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: _isConnecting ? null : _connectDevice,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isConnecting
                    ? const CircularProgressIndicator()
                    : const Text('Connect Device'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
