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
  const AirQualityChart({super.key});

  @override
  State<AirQualityChart> createState() => _AirQualityChartState();
}

class _AirQualityChartState extends State<AirQualityChart> {
  final List<AQIData> aqiData = [
    AQIData(
      time: '12AM',
      value: 50,
      predictedValue: 52,
      confidence: 88,
      color: Colors.green,
      predictedColor: Colors.green.withValues(alpha: 0.6),
      status: 'Good',
      predictedStatus: 'Good',
    ),
    AQIData(
      time: '3AM',
      value: 45,
      predictedValue: 48,
      confidence: 85,
      color: Colors.green,
      predictedColor: Colors.green.withValues(alpha: 0.6),
      status: 'Good',
      predictedStatus: 'Good',
    ),
    AQIData(
      time: '6AM',
      value: 40,
      predictedValue: 55,
      confidence: 82,
      color: Colors.green,
      predictedColor: Colors.green.withValues(alpha: 0.6),
      status: 'Good',
      predictedStatus: 'Good',
    ),
    AQIData(
      time: '9AM',
      value: 60,
      predictedValue: 65,
      confidence: 85,
      color: Colors.orange,
      predictedColor: Colors.orange.withValues(alpha: 0.6),
      status: 'Moderate',
      predictedStatus: 'Moderate',
    ),
    AQIData(
      time: '12PM',
      value: 75,
      predictedValue: 78,
      confidence: 88,
      color: Colors.orange,
      predictedColor: Colors.orange.withValues(alpha: 0.6),
      status: 'Moderate',
      predictedStatus: 'Moderate',
    ),
    AQIData(
      time: '3PM',
      value: 85,
      predictedValue: 88,
      confidence: 85,
      color: Colors.orange,
      predictedColor: Colors.orange.withValues(alpha: 0.6),
      status: 'Moderate',
      predictedStatus: 'Moderate',
    ),
    AQIData(
      time: '6PM',
      value: 65,
      predictedValue: 72,
      confidence: 82,
      color: Colors.orange,
      predictedColor: Colors.orange.withValues(alpha: 0.6),
      status: 'Moderate',
      predictedStatus: 'Moderate',
    ),
    // Predicted data points
    AQIData(
      time: '9PM',
      value: 0,
      predictedValue: 78,
      confidence: 80,
      color: Colors.transparent,
      predictedColor: Colors.orange.withValues(alpha: 0.6),
      status: 'Predicted',
      predictedStatus: 'Moderate',
    ),
    AQIData(
      time: '12AM',
      value: 0,
      predictedValue: 85,
      confidence: 78,
      color: Colors.transparent,
      predictedColor: Colors.orange.withValues(alpha: 0.6),
      status: 'Predicted',
      predictedStatus: 'Moderate',
    ),
    AQIData(
      time: '3AM',
      value: 0,
      predictedValue: 92,
      confidence: 75,
      color: Colors.transparent,
      predictedColor: Colors.orange.withValues(alpha: 0.6),
      status: 'Predicted',
      predictedStatus: 'Moderate',
    ),
  ];

  bool _showPrediction = false;

  // Toggle prediction visibility
  void _togglePrediction() {
    setState(() {
      _showPrediction = !_showPrediction;
    });
  }

  // Get the next hour's prediction
  AQIData? getNextHourPrediction() {
    final now = DateTime.now();
    final currentHour = now.hour;

    // Find the next hour's data
    for (var data in aqiData) {
      final hour = int.tryParse(data.time.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
      final isPM = data.time.contains('PM') && hour < 12;
      final hour24 = isPM ? hour + 12 : (data.time.contains('AM') && hour == 12 ? 0 : hour);

      if (hour24 > currentHour) {
        return data;
      }
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
                      value: '45',
                      label: 'Good',
                      color: Colors.green,
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
