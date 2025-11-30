import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zygreen_air_purifier/providers/air_quality_provider.dart';
import 'package:zygreen_air_purifier/models/air_quality_data.dart';
import 'package:intl/intl.dart';

class AirQualityHistoryScreen extends StatelessWidget {
  const AirQualityHistoryScreen({super.key});

  // Get the raw AQI value from the data model
  int _getAqiValue(AirQualityData data) {
    // Use the raw AQI value from the model, defaulting to 0 if null
    return data.aqi ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    final airQualityProvider = Provider.of<AirQualityProvider>(context);
    // Sort history by timestamp (newest first)
    final history = List<AirQualityData>.from(airQualityProvider.historicalData)
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Air Quality History', 
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: const AssetImage('assets/images/app_background.jpg'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withValues(alpha:0.5),
              BlendMode.darken,
            ),
          ),
        ),
        child: SafeArea(
          child: history.isEmpty
              ? Center(
                  child: Text(
                    'No history data available',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha:0.8),
                      fontSize: 16,
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: history.length,
                  itemBuilder: (context, index) {
                    final data = history[index];
                    return Card(
                      color: Colors.white.withValues(alpha:0.1),
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: Colors.white.withValues(alpha:0.2),
                          width: 1,
                        ),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: _getAqiColor(_getAqiValue(data)).withValues(alpha:0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _getAqiIcon(_getAqiValue(data)),
                            color: _getAqiColor(_getAqiValue(data)),
                          ),
                        ),
                        title: Text(
                          'AQI: ${_getAqiValue(data).toStringAsFixed(0)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Text(
                          DateFormat('MMM d, yyyy - hh:mm a')
                              .format(data.timestamp),
                          style: TextStyle(
                            color: Colors.white.withValues(alpha:0.7),
                            fontSize: 12,
                          ),
                        ),
                        trailing: Text(
                          _getAqiStatus(_getAqiValue(data)),
                          style: TextStyle(
                            color: _getAqiColor(_getAqiValue(data)),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }

  Color _getAqiColor(int aqi) {
    if (aqi <= 50) return Colors.green;
    if (aqi <= 100) return Colors.lightGreen;
    if (aqi <= 150) return Colors.yellow;
    if (aqi <= 200) return Colors.orange;
    if (aqi <= 300) return Colors.red;
    return Colors.purple;
  }

  String _getAqiStatus(int aqi) {
    if (aqi <= 50) return 'Good';
    if (aqi <= 100) return 'Moderate';
    if (aqi <= 150) return 'Unhealthy for Sensitive';
    if (aqi <= 200) return 'Unhealthy';
    if (aqi <= 300) return 'Very Unhealthy';
    return 'Hazardous';
  }

  IconData _getAqiIcon(int aqi) {
    if (aqi <= 50) return Icons.thumb_up;
    if (aqi <= 100) return Icons.thumb_up_outlined;
    if (aqi <= 150) return Icons.warning_amber_rounded;
    if (aqi <= 200) return Icons.health_and_safety_outlined;
    if (aqi <= 300) return Icons.health_and_safety;
    return Icons.dangerous;
  }
}
