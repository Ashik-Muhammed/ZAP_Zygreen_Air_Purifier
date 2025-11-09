import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:zygreen_air_purifier/services/firebase_service.dart';
import 'package:zygreen_air_purifier/theme/app_theme.dart';

class AirQualityTrendScreen extends StatefulWidget {
  final double currentAirQuality;

  const AirQualityTrendScreen({
    super.key,
    required this.currentAirQuality,
  });

  @override
  State<AirQualityTrendScreen> createState() => _AirQualityTrendScreenState();
}

class _AirQualityTrendScreenState extends State<AirQualityTrendScreen> {
  bool _showPrediction = true;
  bool _isLoading = true;
  String? _error;
  List<Map<String, dynamic>> _aqiData = [];
  StreamSubscription? _dataSubscription;
  final FirebaseService _firebaseService = FirebaseService();
  
  @override
  void initState() {
    super.initState();
    _loadHistoricalData();
  }
  
  @override
  void dispose() {
    _dataSubscription?.cancel();
    super.dispose();
  }
  
  Future<void> _loadHistoricalData() async {
    try {
      setState(() => _isLoading = true);
      
      // Get last 24 hours of data (assuming 1 reading per hour)
      _dataSubscription = _firebaseService
          .getHistoricalData(limit: 24)
          .listen((data) {
            if (mounted) {
              setState(() {
                _aqiData = data.map((entry) => _formatDataPoint(entry)).toList();
                _isLoading = false;
                _error = null;
              });
            }
          }, onError: (error) {
            if (mounted) {
              setState(() {
                _error = 'Failed to load data: $error';
                _isLoading = false;
              });
            }
          });
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Error: $e';
          _isLoading = false;
        });
      }
    }
  }
  
  Map<String, dynamic> _formatDataPoint(Map<String, dynamic> entry) {
    final timestamp = entry['timestamp'] as int;
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    final hour = date.hour;
    String timeLabel;
    
    // Format time as 12-hour with AM/PM
    if (hour == 0) {
      timeLabel = '12 AM';
    } else if (hour < 12) {
      timeLabel = '$hour AM';
    } else if (hour == 12) {
      timeLabel = '12 PM';
    } else {
      timeLabel = '${hour - 12} PM';
    }
    
    return {
      'time': timeLabel,
      'value': entry['airQuality']?.toDouble() ?? 0.0,
      'predicted': false,
      'timestamp': timestamp,
    };
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
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Air Quality Trend'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadHistoricalData,
            tooltip: 'Refresh Data',
          ),
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!, style: const TextStyle(color: Colors.red)))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
            // Current AQI Status
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _getAqiColor(widget.currentAirQuality).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _getAqiColor(widget.currentAirQuality).withValues(alpha: 0.3),
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
                        widget.currentAirQuality.toStringAsFixed(1),
                        style: theme.textTheme.headlineMedium?.copyWith(
                          color: _getAqiColor(widget.currentAirQuality),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getAqiColor(widget.currentAirQuality).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          _getAqiStatus(widget.currentAirQuality),
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: _getAqiColor(widget.currentAirQuality),
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
                          if (_aqiData.isNotEmpty && index >= 0 && index < _aqiData.length) {
                            // Only show every 2nd label to prevent overcrowding
                            if (index % 2 == 0) {
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
                      spots: _aqiData.isNotEmpty
                          ? _aqiData
                              .where((point) => !point['predicted'])
                              .toList()
                              .asMap()
                              .entries
                              .map((entry) => FlSpot(
                                    entry.key.toDouble(),
                                    entry.value['value'].toDouble(),
                                  ))
                              .toList()
                          : [const FlSpot(0, 0)],
                      isCurved: true,
                      color: _getAqiColor(widget.currentAirQuality),
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: _getAqiColor(widget.currentAirQuality).withValues(alpha: 0.1),
                      ),
                    ),
                    // Predicted AQI Line (dashed)
                    if (_showPrediction)
                      LineChartBarData(
                        spots: _aqiData.isNotEmpty
                            ? _aqiData
                                .where((point) => point['predicted'] || !_showPrediction)
                                .toList()
                                .asMap()
                                .entries
                                .map((entry) => FlSpot(
                                      entry.key.toDouble(),
                                      entry.value['value'].toDouble(),
                                    ))
                                .toList()
                            : [const FlSpot(0, 0)],
                        isCurved: true,
                        color: _getAqiColor(widget.currentAirQuality).withValues(alpha: 0.7),
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
                  _getAqiColor(widget.currentAirQuality),
                ),
                const SizedBox(width: 16),
                if (_showPrediction)
                  _buildLegend(
                    'Predicted',
                    _getAqiColor(widget.currentAirQuality).withValues(alpha: 0.7),
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
