// ignore_for_file: curly_braces_in_flow_control_structures

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class AQIData {
  final String time;
  final double value;
  final double? predictedValue;
  final int? confidence;
  final Color color;
  final Color predictedColor;
  final String status;
  final String predictedStatus;

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

  void _togglePrediction() {
    setState(() {
      _showPrediction = !_showPrediction;
    });
  }

  // ------------------- AQI Helpers -------------------
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

  // ------------------- Generate AQI Data -------------------
  List<AQIData> get aqiData {
    if (widget.isLoading) {
      return List.generate(
        12,
        (i) => AQIData(
          time: '${i + 1}',
          value: 0,
          color: Colors.grey[300]!,
          predictedColor: Colors.grey[300]!,
          status: 'Loading...',
        ),
      );
    }

    final now = DateTime.now();
    final currentHour = now.hour;

    return List.generate(12, (index) {
      final hour = (currentHour - 11 + index + 24) % 24; // last 12 hours
      final timeLabel = '${hour == 0 ? 12 : hour > 12 ? hour - 12 : hour}${hour < 12 ? 'AM' : 'PM'}';
      final isCurrentHour = index == 11;

      double baseValue = widget.airQuality;
      double factor;

      if (hour >= 22 || hour < 5) factor = 0.7;
      else if (hour >= 5 && hour < 10) factor = 0.8 + (hour - 5) * 0.04;
      else if (hour >= 10 && hour < 17) factor = 1.0;
      else factor = 1.0 - (hour - 17) * 0.06;

      double randomFactor = 0.9 + (0.2 * (index % 3));
      double value = isCurrentHour ? baseValue : (baseValue * factor * randomFactor).clamp(0, 500);

      double predictedValue = (value * (1.0 + 0.05)).clamp(0, 500);

      return AQIData(
        time: timeLabel,
        value: isCurrentHour ? value : value,
        predictedValue: predictedValue,
        confidence: 80,
        color: _getAqiColor(value),
        predictedColor: _getAqiColor(predictedValue).withValues(alpha: 0.6),
        status: _getAqiStatus(value),
        predictedStatus: _getAqiStatus(predictedValue),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final data = aqiData;
    final maxY = [
      ...data.map((d) => d.value),
      ...data.map((d) => d.predictedValue ?? 0)
    ].reduce((a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with title and toggle
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Flexible(
                child: Text(
                  'Air Quality Trend',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2D3748),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8), // Add some spacing
              // Prediction Toggle
              Container(
                constraints: const BoxConstraints(maxWidth: 200), // Limit the width
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: IntrinsicWidth(
                  child: Row(
                    mainAxisSize: MainAxisSize.min, // Take minimum width needed
                    children: [
                      Expanded(
                        child: _buildToggleButton('Current', !_showPrediction, onTap: () {
                          if (_showPrediction) _togglePrediction();
                        }),
                      ),
                      Expanded(
                        child: _buildToggleButton('Forecast', _showPrediction, onTap: () {
                          if (!_showPrediction) _togglePrediction();
                        }),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Chart
          SizedBox(
            height: 260,
            child: LineChart(
              LineChartData(
                minX: 0,
                maxX: (data.length - 1).toDouble(),
                minY: 0,
                maxY: (maxY * 1.2).clamp(50, 500),
                gridData: FlGridData(
                  show: true,
                  horizontalInterval: 50,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: Colors.grey[100]!,
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: data.length > 10 ? 3 : 2, // Adjust interval based on data points
                      reservedSize: 32, // Increased reserved space for bottom labels
                      getTitlesWidget: (value, meta) {
                        final idx = value.toInt();
                        if (idx >= 0 && idx < data.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 10.0),
                            child: Text(
                              data[idx].time,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 10, // Slightly smaller font
                                color: Color(0xFF718096),
                                fontWeight: FontWeight.w500,
                                height: 1.2,
                              ),
                            ),
                          );
                        }
                        return const SizedBox();
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: maxY > 200 ? 100 : 50, // Adjust interval based on max Y value
                      reservedSize: 42, // Increased reserved space for left labels
                      getTitlesWidget: (value, meta) {
                        // Only show whole numbers for AQI
                        if (value % (maxY > 200 ? 100 : 50) != 0) {
                          return const SizedBox();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(right: 10.0),
                          child: Text(
                            value.toInt().toString(),
                            style: const TextStyle(
                              fontSize: 10, // Slightly smaller font
                              color: Color(0xFF718096),
                              fontWeight: FontWeight.w500,
                              height: 1.2,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  // Current AQI Line
                  LineChartBarData(
                    spots: data.asMap().entries.map((e) => 
                      FlSpot(e.key.toDouble(), e.value.value)
                    ).toList(),
                    isCurved: true,
                    curveSmoothness: 0.3,
                    color: const Color(0xFF48BB78), // Green
                    barWidth: 3.5,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                        radius: 4,
                        color: Colors.white,
                        strokeWidth: 2,
                        strokeColor: const Color(0xFF48BB78),
                      ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF48BB78).withValues(alpha: 0.1),
                          const Color(0xFF48BB78).withValues(alpha: 0.01),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                  // Prediction Line
                  if (_showPrediction)
                    LineChartBarData(
                      spots: data.asMap().entries.map((e) => 
                        FlSpot(e.key.toDouble(), e.value.predictedValue ?? 0)
                      ).toList(),
                      isCurved: true,
                      curveSmoothness: 0.3,
                      color: const Color(0xFF4299E1), // Blue
                      barWidth: 2.5,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                          radius: 3,
                          color: Colors.white,
                          strokeWidth: 2,
                          strokeColor: const Color(0xFF4299E1),
                        ),
                      ),
                      dashArray: [5, 3],
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF4299E1).withValues(alpha: 0.1),
                            const Color(0xFF4299E1).withValues(alpha: 0.01),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          // Legend
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem('Current', const Color(0xFF48BB78)),
              const SizedBox(width: 20),
              if (_showPrediction) 
                _buildLegendItem('Forecast', const Color(0xFF4299E1)),
            ],
          ),
        ],
      ),
    );
  }

  // Helper method for toggle buttons
  Widget _buildToggleButton(String text, bool isActive, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF48BB78) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isActive ? Colors.white : const Color(0xFF718096),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  // Helper method for legend items
  Widget _buildLegendItem(String text, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(
            color: Color(0xFF4A5568),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
