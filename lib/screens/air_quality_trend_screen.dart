import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:zygreen_air_purifier/providers/sensor_provider.dart';
import 'package:zygreen_air_purifier/providers/air_quality_provider.dart';
import 'package:zygreen_air_purifier/models/air_quality_data.dart';
import 'dart:math';

class AirQualityTrendScreen extends StatefulWidget {
  const AirQualityTrendScreen({super.key});

  @override
  State<AirQualityTrendScreen> createState() => _AirQualityTrendScreenState();
}

class _AirQualityTrendScreenState extends State<AirQualityTrendScreen> {
  String _selectedTimeRange = '24h';
  
  // 1. FILTERING
  List<AirQualityData> _getFilteredData(List<AirQualityData> allData) {
    if (allData.isEmpty) return [];
    
    final now = DateTime.now();
    DateTime startTime;
    
    switch (_selectedTimeRange) {
      case '12h': startTime = now.subtract(const Duration(hours: 12)); break;
      case '7d': startTime = now.subtract(const Duration(days: 7)); break;
      case '30d': startTime = now.subtract(const Duration(days: 30)); break;
      case '24h': default: startTime = now.subtract(const Duration(hours: 24)); break;
    }
    
    return allData.where((data) => data.timestamp.isAfter(startTime)).toList();
  }

  // 2. SAMPLING
  List<AirQualityData> _downsampleData(List<AirQualityData> data, int maxPoints) {
    if (data.length <= maxPoints) return data;
    final step = data.length / maxPoints;
    List<AirQualityData> sampled = [];
    for (double i = 0; i < data.length; i += step) {
      sampled.add(data[i.floor()]);
    }
    return sampled;
  }

  @override
  Widget build(BuildContext context) {
    final sensorProvider = Provider.of<SensorProvider>(context);
    final airQualityProvider = Provider.of<AirQualityProvider>(context);
    
    final currentAqi = sensorProvider.airQuality.toDouble(); 

    // DATA PREP
    final fullHistory = _getFilteredData(airQualityProvider.historicalData);
    
    // STATS CALCULATION
    double minAqi = currentAqi;
    double maxAqi = currentAqi;
    double avgAqi = currentAqi;

    if (fullHistory.isNotEmpty) {
      final allValues = fullHistory.map((e) => e.aqi?.toDouble() ?? 0.0).toList();
      allValues.add(currentAqi);
      
      minAqi = allValues.reduce(min);
      maxAqi = allValues.reduce(max);
      avgAqi = allValues.reduce((a, b) => a + b) / allValues.length;
    }

    // CHART DATA PREP
    final displayHistory = _downsampleData(fullHistory, 30);
    
    double chartMaxY = 100;
    if (fullHistory.isNotEmpty) {
      chartMaxY = (maxAqi * 1.2).clamp(100.0, 500.0);
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
              Colors.black.withValues(alpha:0.3), 
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
                
                // CHART SECTION
                const Text("Historical Data", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Container(
                  height: 350,
                  padding: const EdgeInsets.fromLTRB(16, 24, 24, 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08), // Glass effect
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                  ),
                  child: displayHistory.isEmpty 
                  ? Center(child: Text("Collecting history...", style: TextStyle(color: Colors.white.withValues(alpha: 0.6))))
                  : LineChart(
                      LineChartData(
                        minX: 0,
                        maxX: (displayHistory.length - 1).toDouble(),
                        minY: 0,
                        maxY: chartMaxY,
                        gridData: FlGridData(
                          show: true, 
                          drawVerticalLine: false,
                          horizontalInterval: chartMaxY / 5,
                          getDrawingHorizontalLine: (value) => FlLine(
                            color: Colors.white.withValues(alpha: 0.1),
                            strokeWidth: 1,
                            dashArray: [5, 5]
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        titlesData: FlTitlesData(
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 30,
                              interval: chartMaxY / 5,
                              getTitlesWidget: (value, meta) {
                                return Text(
                                  value.toInt().toString(),
                                  style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 10),
                                );
                              }
                            )
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              interval: (displayHistory.length / 4).ceilToDouble(),
                              getTitlesWidget: (value, meta) {
                                final index = value.toInt();
                                if (index >= 0 && index < displayHistory.length) {
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 12.0),
                                    child: Text(
                                      DateFormat('h:mm').format(displayHistory[index].timestamp),
                                      style: TextStyle(fontSize: 10, color: Colors.white.withValues(alpha: 0.6)),
                                    ),
                                  );
                                }
                                return const SizedBox();
                              },
                            ),
                          ),
                        ),
                        lineBarsData: [
                          LineChartBarData(
                            spots: displayHistory.asMap().entries.map((e) {
                              return FlSpot(e.key.toDouble(), e.value.aqi?.toDouble() ?? 0);
                            }).toList(),
                            isCurved: true,
                            curveSmoothness: 0.35,
                            color: const Color(0xFF00D9FF), // Cyan/Blue theme color
                            barWidth: 3,
                            isStrokeCapRound: true,
                            dotData: const FlDotData(show: false),
                            belowBarData: BarAreaData(
                              show: true, 
                              gradient: LinearGradient(
                                colors: [
                                  const Color(0xFF00D9FF).withValues(alpha: 0.3),
                                  const Color(0xFF00D9FF).withValues(alpha: 0.0),
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              )
                            ),
                          ),
                        ],
                        lineTouchData: LineTouchData(
                          touchTooltipData: LineTouchTooltipData(
                            tooltipBgColor: const Color(0xFF1A2840),
                            tooltipRoundedRadius: 8,
                            getTooltipItems: (touchedSpots) {
                              return touchedSpots.map((spot) {
                                return LineTooltipItem(
                                  "${spot.y.toInt()}",
                                  const TextStyle(color: Color(0xFF00D9FF), fontWeight: FontWeight.bold),
                                  children: [
                                    const TextSpan(
                                      text: " AQI",
                                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.normal, fontSize: 10)
                                    )
                                  ]
                                );
                              }).toList();
                            }
                          )
                        )
                      ),
                    ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Styled Time Selector Dropdown
  Widget _buildTimeSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedTimeRange,
          dropdownColor: const Color(0xFF1A2840), // Dark background for menu
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 18),
          style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
          onChanged: (v) => setState(() => _selectedTimeRange = v!),
          items: ['12h', '24h', '7d', '30d'].map((e) => DropdownMenuItem(
            value: e, 
            child: Text(e)
          )).toList(),
        ),
      ),
    );
  }

  // Styled Glassmorphism Stat Card
  Widget _buildStatCard(String title, String value, Color color, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.2),
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