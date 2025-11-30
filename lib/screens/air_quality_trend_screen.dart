import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zygreen_air_purifier/providers/sensor_provider.dart';
import 'package:zygreen_air_purifier/providers/air_quality_provider.dart';
import 'package:zygreen_air_purifier/models/air_quality_data.dart';
import 'package:zygreen_air_purifier/widgets/air_quality_chart.dart';
import 'dart:math';

class AirQualityTrendScreen extends StatefulWidget {
  const AirQualityTrendScreen({super.key});

  @override
  State<AirQualityTrendScreen> createState() => _AirQualityTrendScreenState();
}

class _AirQualityTrendScreenState extends State<AirQualityTrendScreen> {
  // 1. FILTERING - Get only real sensor data points for the last 24 hours
  List<AirQualityData> _getFilteredData(List<AirQualityData> allData) {
    if (allData.isEmpty) return [];
    
    // Filter out any predicted/forecasted data
    final sensorData = allData.where((data) => !data.isPrediction).toList();
    if (sensorData.isEmpty) return [];
    
    // Sort by timestamp
    sensorData.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    
    // Get data from the last 24 hours
    final now = DateTime.now();
    final twentyFourHoursAgo = now.subtract(const Duration(hours: 24));
    
    // Filter to only include recent data with valid sensor readings
    final recentData = sensorData.where((data) => 
      data.timestamp.isAfter(twentyFourHoursAgo) &&
      (data.pm25 != null || data.pm10 != null || data.co2 != null || data.voc != null)
    ).toList();
    
    return recentData.isEmpty ? [sensorData.last] : recentData;
  }

  @override
  Widget build(BuildContext context) {
    final sensorProvider = Provider.of<SensorProvider>(context);
    final airQualityProvider = Provider.of<AirQualityProvider>(context);
    
    final currentAqi = sensorProvider.airQuality.toDouble(); 

    // DATA PREP
    final fullHistory = _getFilteredData(airQualityProvider.historicalData);
    
    // STATS CALCULATION - Using only real sensor data
    double minAqi = currentAqi;
    double maxAqi = currentAqi;
    double avgAqi = currentAqi;

    if (fullHistory.isNotEmpty) {
      // Calculate AQI for each historical data point using sensor values
      final aqiValues = fullHistory.map((data) {
        // Simple AQI calculation based on PM2.5 (you can adjust the formula)
        final pm25 = data.pm25 ?? 0;
        final pm10 = data.pm10 ?? 0;
        return (pm25 * 0.7) + (pm10 * 0.3); // Adjust weights as needed
      }).toList();
      
      // Add current AQI to the values
      aqiValues.add(currentAqi);
      
      // Calculate statistics
      if (aqiValues.isNotEmpty) {
        minAqi = aqiValues.reduce(min);
        maxAqi = aqiValues.reduce(max);
        avgAqi = aqiValues.reduce((a, b) => a + b) / aqiValues.length;
      }
    }

    // MAIN UI STRUCTURE
    return Scaffold(
      extendBodyBehindAppBar: true, // Allows background to go behind AppBar
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Air Quality Trend', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          _buildTimeSelector(),
          const SizedBox(width: 16),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: const AssetImage('assets/images/app_background.jpg'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withAlpha((0.3 * 255).toInt()), 
              BlendMode.darken,
            ),
            onError: (_, __) {}, // Safety fallbacks handled by gradient below
          ),
          gradient: const LinearGradient(
            colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // STATISTICS SECTION
                const Text("Overview", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildStatCard('Current', currentAqi.toStringAsFixed(0), _getAqiColor(currentAqi), Icons.speed),
                    const SizedBox(width: 12),
                    _buildStatCard('Average', avgAqi.toStringAsFixed(0), _getAqiColor(avgAqi), Icons.functions),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildStatCard('Min Recorded', minAqi.toStringAsFixed(0), _getAqiColor(minAqi), Icons.arrow_downward),
                    const SizedBox(width: 12),
                    _buildStatCard('Max Recorded', maxAqi.toStringAsFixed(0), _getAqiColor(maxAqi), Icons.arrow_upward),
                  ],
                ),
                
                const SizedBox(height: 32),
                
               
                // AQI Trend Chart
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha((0.08 * 255).toInt()),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white.withAlpha((0.1 * 255).toInt())),
                  ),
                  child: AirQualityChart(
                    airQuality: currentAqi,
                    isLoading: fullHistory.isEmpty,
                  ),
                ),
                const SizedBox(height: 24),
                // Current AQI Display
                
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Current AQI display only - no time range selection needed
  Widget _buildTimeSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha((0.1 * 255).toInt()),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withAlpha((0.2 * 255).toInt())),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.timeline, size: 16, color: Colors.white70),
          SizedBox(width: 4),
          Text('24h Trend', style: TextStyle(color: Colors.white, fontSize: 13)),
        ],
      ),
    );
  }

  // Styled Glassmorphism Stat Card
  Widget _buildStatCard(String title, String value, Color color, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha((0.08 * 255).toInt()),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withAlpha((0.1 * 255).toInt())),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: color.withAlpha((0.2 * 255).toInt()),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 16),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title, 
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value, 
              style: const TextStyle(
                color: Colors.white, 
                fontSize: 28, 
                fontWeight: FontWeight.bold,
                height: 1.0,
              )
            ),
            const SizedBox(height: 4),
            Text(
              _getAqiStatus(double.tryParse(value) ?? 0),
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w600
              ),
            )
          ],
        ),
      ),
    );
  }

  // Helper for Colors
  Color _getAqiColor(double value) {
    if (value <= 50) return const Color(0xFF00E676);
    if (value <= 100) return const Color(0xFFFFC107);
    if (value <= 150) return const Color(0xFFFF9800);
    if (value <= 200) return const Color(0xFFF44336);
    if (value <= 300) return const Color(0xFF9C27B0);
    return const Color(0xFF7B1FA2);
  }

  // Helper for Status Text
  String _getAqiStatus(double value) {
    if (value <= 50) return 'Good';
    if (value <= 100) return 'Moderate';
    if (value <= 150) return 'Sensitive';
    if (value <= 200) return 'Unhealthy';
    return 'Hazardous';
  }
}