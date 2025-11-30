import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zygreen_air_purifier/providers/esp32_provider.dart';
import 'package:zygreen_air_purifier/providers/sensor_provider.dart';

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
    // dismiss keyboard
    FocusScope.of(context).unfocus();

    setState(() => _isConnecting = true);

    try {
      final esp32Provider = Provider.of<ESP32Provider>(context, listen: false);
      final sensorProvider = Provider.of<SensorProvider>(context, listen: false);

      // Simulate a minimum delay for the animation to feel smooth
      final startTime = DateTime.now();
      
      final success = await esp32Provider.connectToDevice(
        _deviceIdController.text.trim()
      );

      // Ensure animation plays for at least 1.5 seconds
      final elapsedTime = DateTime.now().difference(startTime);
      if (elapsedTime.inMilliseconds < 1500) {
        await Future.delayed(Duration(milliseconds: 1500 - elapsedTime.inMilliseconds));
      }

      if (!mounted) return;

      if (success) {
        await sensorProvider.clearDeviceData();
        await sensorProvider.initSensorData();

        if (mounted) {
          Navigator.of(context).pop(true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Device connected successfully'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } else {
        _showErrorSnackBar('Failed to connect. Check Device ID.');
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Connection error: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() => _isConnecting = false);
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Using the same gradient background as dashboard for consistency
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Connect Device', 
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: const AssetImage('assets/images/app_background.jpg'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withValues(alpha: 0.4), 
              BlendMode.darken,
            ),
            onError: (_, __) {}, 
          ),
          gradient: const LinearGradient(
            colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                // Animated Header Icon
                _buildHeaderIcon(),
                const SizedBox(height: 40),
                
                // Glassmorphism Form Card
                _buildGlassForm(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderIcon() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF00D9FF).withValues(alpha: 0.1),
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFF00D9FF).withValues(alpha: 0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00D9FF).withValues(alpha: 0.2),
            blurRadius: 20,
            spreadRadius: 5,
          )
        ]
      ),
      child: const Icon(
        Icons.wifi_tethering, 
        size: 64, 
        color: Color(0xFF00D9FF)
      ),
    );
  }

  Widget _buildGlassForm() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Link your Air Purifier",
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Enter the unique ID found on the back of your device.",
              style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 14),
            ),
            const SizedBox(height: 32),
            
            // Modern Text Field
            TextFormField(
              controller: _deviceIdController,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              cursorColor: const Color(0xFF00D9FF),
              decoration: InputDecoration(
                labelText: 'Device ID',
                labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
                hintText: 'e.g. 000000000000',
                hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
                prefixIcon: const Icon(Icons.qr_code, color: Color(0xFF00D9FF)),
                filled: true,
                fillColor: Colors.black.withValues(alpha: 0.2),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Color(0xFF00D9FF)),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Colors.redAccent),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Device ID is required';
                }
                if (value.trim().length < 3) {
                  return 'ID seems too short';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 24),
            
            // Info Card
            
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF00D9FF).withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF00D9FF).withValues(alpha: 0.1)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Color(0xFF00D9FF), size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Tip: The ID usually is 12 digits long. If you can't find it, contact the manufacturer.",
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Connect Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isConnecting ? null : _connectDevice,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00D9FF),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: const Color(0xFF00D9FF).withValues(alpha: 0.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 8,   
                  shadowColor: const Color(0xFF00D9FF).withValues(alpha: 0.4),
                ),
                child: _isConnecting
                    ? const SizedBox(
                        height: 24, 
                        width: 24, 
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5)
                      )
                    : const Text(
                        'Connect Device',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}