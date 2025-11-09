import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:zygreen_air_purifier/theme/app_theme.dart';
import 'package:zygreen_air_purifier/providers/sensor_provider.dart';

class AirQualityTrendScreen extends StatefulWidget {
  const AirQualityTrendScreen({super.key});

  @override
  State<AirQualityTrendScreen> createState() => _AirQualityTrendScreenState();
}

class _AirQualityTrendScreenState extends State<AirQualityTrendScreen> {
  bool _showPrediction = true;
  
  // Generate time-based data points
  List<Map<String, dynamic>> get _aqiData {
    final now = DateTime.now();
    final data = <Map<String, dynamic>>[];
    
    // Generate 12 data points (2 hours apart)
    for (int i = 0; i < 12; i++) {
      final time = now.subtract(Duration(hours: (11 - i) * 2));
      final hour = time.hour;
      final period = hour >= 12 ? 'PM' : 'AM';
      final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
      
      // Use actual data or generate sample data
      final value = i < 7 
          ? 40 + i * 5 // Sample past data
          : 75 + (i - 7) * 2; // Sample predicted data
          
      data.add({
        'time': '$displayHour $period',
        'value': value,
        'predicted': i >= 7,
      });
    }
    
    return data;
  }

  Color _getAqiColor(double value) {
    if (value <= 50) return AppTheme.success;
    if (value <= 100) return Colors.yellow[700]!;
    if (value <= 150) return Colors.orange;
    if (value <= 200) return Colors.red;
    if (value <= 300) return Colors.purple;
    return Colors.deepPurple[900]!;
  }

  String _getAqiStatus(double value) {
    if (value <= 50) return 'Good';
    if (value <= 100) return 'Moderate';
    if (value <= 150) return 'Unhealthy (Sensitive)';
    if (value <= 200) return 'Unhealthy';
    if (value <= 300) return 'Very Unhealthy';
    return 'Hazardous';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sensorProvider = Provider.of<SensorProvider>(context);
    final currentAirQuality = sensorProvider.airQuality.toDouble();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Air Quality Trend'),
        actions: [
          IconButton(
            icon: Icon(_showPrediction ? Icons.visibility : Icons.visibility_off),
            onPressed: () {
              setState(() {
                _showPrediction = !_showPrediction;
              });
            },
            tooltip: _showPrediction ? 'Hide Prediction' : 'Show Prediction',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Current AQI Status
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _getAqiColor(sensorProvider.airQuality.toDouble()).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _getAqiColor(sensorProvider.airQuality.toDouble()).withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Current AQI',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        currentAirQuality.toStringAsFixed(1),
                        style: theme.textTheme.headlineMedium?.copyWith(
                          color: _getAqiColor(currentAirQuality),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getAqiColor(currentAirQuality).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          _getAqiStatus(currentAirQuality),
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: _getAqiColor(currentAirQuality),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Trend Chart
            Text(
              '24-Hour AQI Trend',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 25,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: Colors.grey[200],
                      strokeWidth: 1,
                      dashArray: [4, 4],
                    ),
                  ),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 2,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index >= 0 && index < _aqiData.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                _aqiData[index]['time'],
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 50,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey[600],
                            ),
                          );
                        },
                      ),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    // Actual AQI Line
                    LineChartBarData(
                      spots: _aqiData
                          .where((point) => !point['predicted'])
                          .toList()
                          .asMap()
                          .entries
                          .map((entry) => FlSpot(
                                entry.key.toDouble(),
                                entry.value['value'].toDouble(),
                              ))
                          .toList(),
                      isCurved: true,
                      color: _getAqiColor(currentAirQuality),
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: _getAqiColor(currentAirQuality).withValues(alpha: 0.1),
                      ),
                    ),
                    // Predicted AQI Line (dashed)
                    if (_showPrediction)
                      LineChartBarData(
                        spots: _aqiData
                            .where((point) => point['predicted'] || !_showPrediction)
                            .toList()
                            .asMap()
                            .entries
                            .map((entry) => FlSpot(
                                  entry.key.toDouble(),
                                  entry.value['value'].toDouble(),
                                ))
                            .toList(),
                        isCurved: true,
                        color: _getAqiColor(currentAirQuality).withValues(alpha: 0.7),
                        barWidth: 2,
                        isStrokeCapRound: true,
                        dashArray: [5, 5],
                        dotData: const FlDotData(show: false),
                      ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Legend
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegend(
                  'Actual',
                  _getAqiColor(currentAirQuality),
                ),
                const SizedBox(width: 16),
                if (_showPrediction)
                  _buildLegend(
                    'Predicted',
                    _getAqiColor(currentAirQuality).withValues(alpha: 0.7),
                    isDashed: true,
                  ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // AQI Scale
            Text(
              'AQI Scale',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            _buildAqiScale(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildLegend(String text, Color color, {bool isDashed = false}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 2,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(1),
            border: isDashed
                ? Border.all(
                    color: color,
                    width: 2,
                    strokeAlign: BorderSide.strokeAlignInside,
                    style: BorderStyle.solid,
                  )
                : null,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }
  
  Widget _buildAqiScale() {
    final scaleItems = [
      {'min': 0, 'max': 50, 'label': 'Good', 'color': const Color(0xFF10B981)},
      {'min': 51, 'max': 100, 'label': 'Moderate', 'color': Colors.yellow[700]!},
      {'min': 101, 'max': 150, 'label': 'Unhealthy for Sensitive', 'color': Colors.orange},
      {'min': 151, 'max': 200, 'label': 'Unhealthy', 'color': Colors.red},
      {'min': 201, 'max': 300, 'label': 'Very Unhealthy', 'color': Colors.purple},
      {'min': 301, 'max': 500, 'label': 'Hazardous', 'color': const Color(0xFF7E22CE)},
    ];
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          for (final item in scaleItems)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: item['color'] as Color,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '${item['min']}-${item['max']}: ${item['label']}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[800],
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
