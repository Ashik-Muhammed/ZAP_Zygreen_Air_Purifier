import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class AQIData {
  final String time;
  final double value;
  final double? predictedValue;
  final int? confidence; // Confidence level percentage
  final Color color;
  final Color predictedColor;
  final String status;
  final String predictedStatus; // Predicted AQI category

  AQIData({
    required this.time,
    required this.value,
    this.predictedValue,
    this.confidence,
    required this.color,
    required this.predictedColor,
    required this.status,
    this.predictedStatus = '',
  });
}

class AirQualityChart extends StatefulWidget {
  final double airQuality;
  final bool isLoading;
  
  const AirQualityChart({
    super.key, 
    required this.airQuality,
    this.isLoading = false,
  });

  @override
  State<AirQualityChart> createState() => _AirQualityChartState();
}

class _AirQualityChartState extends State<AirQualityChart> {
  bool _showPrediction = false;

  // Toggle prediction visibility
  void _togglePrediction() {
    setState(() {
      _showPrediction = !_showPrediction;
    });
  }

  // Generate AQI data for the chart
  List<AQIData> get aqiData {
    if (widget.isLoading) {
      // Return placeholder data when loading
      return List.generate(12, (index) {
        return AQIData(
          time: '${index + 1}',
          value: 0,
          color: Colors.grey[300]!,
          predictedColor: Colors.grey[300]!,
          status: 'Loading...',
          predictedStatus: '',
        );
      });
    }

    final now = DateTime.now();
    final currentHour = now.hour;
    
    // Generate data for the last 12 hours
    return List.generate(12, (index) {
      final hour = (currentHour - 11 + index + 24) % 24; // Last 12 hours (11 hours ago to current)
      final time = '${hour == 0 ? 12 : hour > 12 ? hour - 12 : hour}${hour < 12 ? 'AM' : 'PM'}';
      final isCurrentHour = index == 11; // Last item is current hour
      final isFuture = index > 11; // Future hours for prediction
      
      // For the current hour, use the actual air quality value
      // For past hours, generate realistic values based on time of day
      // For future hours, generate predictions
      double baseValue = widget.airQuality.toDouble();
      double hourFactor = 0.0;
      
      // Adjust base value based on time of day (lower at night, higher during day)
      if (hour >= 22 || hour < 5) {
        // Night time (10 PM - 5 AM) - lower AQI
        hourFactor = 0.7;
      } else if (hour >= 5 && hour < 10) {
        // Morning (5 AM - 10 AM) - increasing AQI
        hourFactor = 0.8 + (hour - 5) * 0.04;
      } else if (hour >= 10 && hour < 17) {
        // Day time (10 AM - 5 PM) - higher AQI
        hourFactor = 1.0;
      } else {
        // Evening (5 PM - 10 PM) - decreasing AQI
        hourFactor = 1.0 - (hour - 17) * 0.06;
      }
      
      // Add some randomness to make it more realistic
      final randomFactor = 0.9 + (0.2 * (index % 3));
      
      final double value = isCurrentHour 
          ? widget.airQuality.toDouble() 
          : (baseValue * hourFactor * randomFactor).clamp(0, 500);
          
      // For future predictions, add some trend-based prediction
      final double predictedValue = isFuture 
          ? (value * (0.9 + 0.2 * ((index - 11) / 12))).clamp(0, 500)
          : value;
          
      return AQIData(
        time: time,
        value: isFuture ? 0 : value, // Don't show values for future hours
        predictedValue: isFuture ? predictedValue : null,
        confidence: isFuture ? (85 - (index - 11) * 5).clamp(60, 90) : null,
        color: _getAqiColor(value),
        predictedColor: _getAqiColor(predictedValue).withValues(alpha: 0.6),
        status: isFuture ? '' : _getAqiStatus(value),
        predictedStatus: isFuture ? _getAqiStatus(predictedValue) : '',
      );
    });
  }
  
  Color _getAqiColor(double value) {
    if (value <= 50) return Colors.green;
    if (value <= 100) return Colors.yellow[700]!;
    if (value <= 150) return Colors.orange;
    if (value <= 200) return Colors.red;
    if (value <= 300) return Colors.purple;
    return Colors.brown[900]!;
  }
  
  String _getAqiStatus(double value) {
    if (value <= 50) return 'Good';
    if (value <= 100) return 'Moderate';
    if (value <= 150) return 'Unhealthy for Sensitive';
    if (value <= 200) return 'Unhealthy';
    if (value <= 300) return 'Very Unhealthy';
    return 'Hazardous';
  }

  // Get the next hour's prediction
  AQIData? getNextHourPrediction() {
    if (widget.isLoading) return null;
    
    final now = DateTime.now();
    final currentHour = now.hour;
    
    // Get the next hour's data point
    final nextHourIndex = (currentHour % 12) + 1; // Get index of next hour
    if (nextHourIndex < aqiData.length) {
      return aqiData[nextHourIndex];
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Air Quality',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Text(
                '${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')} PM',
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // AQI Status Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withAlpha(10),
                  spreadRadius: 1,
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'AQI Now',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Current AQI
                    _buildAqiBox(
                      value: widget.airQuality.toInt().toString(),
                      label: _getAqiStatus(widget.airQuality.toDouble()),
                      color: _getAqiColor(widget.airQuality.toDouble()),
                    ),
                    // Prediction
                    if (_showPrediction) ...[
                      Container(
                        width: 1,
                        height: 40,
                        color: Colors.grey[200],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text(
                            'Predicted AQI',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            getNextHourPrediction()?.predictedValue.toString() ?? '',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: getNextHourPrediction()?.predictedColor ?? Colors.grey,
                            ),
                          ),
                          Text(
                            getNextHourPrediction()?.predictedStatus ?? '',
                            style: TextStyle(
                              fontSize: 12,
                              color: getNextHourPrediction()?.predictedColor ?? Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
                // Confidence Indicator
                if (_showPrediction) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: LinearProgressIndicator(
                          value: (getNextHourPrediction()?.confidence ?? 0) / 100,
                          backgroundColor: Colors.grey[200],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            getNextHourPrediction()?.predictedColor ?? Colors.grey,
                          ),
                          minHeight: 6,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${getNextHourPrediction()?.confidence}% confident',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Chart
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withAlpha(10),
                  spreadRadius: 1,
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Air Quality Index (AQI)',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const SizedBox(height: 16),
                // Chart with improved styling
                SizedBox(
                  height: 220,
                  child: LineChart(
                    LineChartData(
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: 20,
                        getDrawingHorizontalLine: (value) => FlLine(
                          color: Colors.grey[100]!,
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
                              if (index >= 0 && index < aqiData.length) {
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    aqiData[index].time,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey[600],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                );
                              }
                              return const Text('');
                            },
                            reservedSize: 32,
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: 20,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                value.toInt().toString(),
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey[500],
                                ),
                              );
                            },
                            reservedSize: 28,
                          ),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      borderData: FlBorderData(
                        show: true,
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      minX: 0,
                      maxX: aqiData.length.toDouble() - 1,
                      minY: 0,
                      maxY: 100,
                      lineBarsData: [
                        // Current AQI Line
                        LineChartBarData(
                          spots: aqiData.asMap().entries.map((entry) {
                            return FlSpot(
                              entry.key.toDouble(),
                              entry.value.value,
                            );
                          }).toList(),
                          isCurved: true,
                          color: Colors.green[700],
                          barWidth: 3.5,
                          isStrokeCapRound: true,
                          dotData: FlDotData(
                            show: true,
                            getDotPainter: (spot, percent, barData, index) {
                              return FlDotCirclePainter(
                                radius: 4,
                                color: Colors.white,
                                strokeWidth: 2.5,
                                strokeColor: aqiData[index].color,
                              );
                            },
                          ),
                          belowBarData: BarAreaData(
                            show: true,
                            gradient: LinearGradient(
                              colors: [
                                Colors.green.withValues(alpha: 0.1),
                                Colors.green.withValues(alpha: 0.01),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              stops: const [0.0, 0.8],
                            ),
                          ),
                        ),
                        // Prediction Line (dashed)
                        if (_showPrediction)
                          LineChartBarData(
                            spots: aqiData.asMap().entries.map((entry) {
                              return FlSpot(
                                entry.key.toDouble(),
                                entry.value.predictedValue ?? 0,
                              );
                            }).toList(),
                            isCurved: true,
                            color: Colors.blue[400]!,
                            barWidth: 2.5,
                            isStrokeCapRound: true,
                            dashArray: [5, 3],
                            dotData: FlDotData(
                              show: true,
                              getDotPainter: (spot, percent, barData, index) {
                                return FlDotCirclePainter(
                                  radius: 3,
                                  color: Colors.white,
                                  strokeWidth: 2,
                                  strokeColor: aqiData[index].predictedColor,
                                );
                              },
                            ),
                            belowBarData: BarAreaData(
                              show: true,
                              gradient: LinearGradient(
                                colors: [
                                  Colors.blue.withValues(alpha: 0.08),
                                  Colors.blue.withValues(alpha: 0.01),
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                stops: const [0.0, 0.8],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                // AQI Scale
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildAqiScaleItem('0', 'Good', Colors.green),
                    _buildAqiScaleItem('50', 'Moderate', Colors.orange),
                    _buildAqiScaleItem('100+', 'Unhealthy', Colors.red),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _togglePrediction,
            child: Text(_showPrediction ? 'Hide Prediction' : 'Show Prediction'),
          ),
        ],
      ),
    );
  }

  Widget _buildAqiBox({
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: color,
            height: 1,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildAqiScaleItem(String value, String label, Color color) {
    return Container(
      height: 40,
      width: 60,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: color,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
