import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:zygreen_air_purifier/providers/sensor_provider.dart';
import 'package:zygreen_air_purifier/providers/air_quality_provider.dart';
import 'package:zygreen_air_purifier/models/air_quality_data.dart';

class AirQualityTrendScreen extends StatefulWidget {
  const AirQualityTrendScreen({super.key});

  @override
  State<AirQualityTrendScreen> createState() => _AirQualityTrendScreenState();
}

class _AirQualityTrendScreenState extends State<AirQualityTrendScreen> {
  bool _showPrediction = true;
  String _selectedTimeRange = '24h';
  
  // Get formatted time range for display
  String _formatTimeRange(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 1) {
      return DateFormat('MMM d').format(dateTime);
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else {
      return DateFormat('h a').format(dateTime);
    }
  }
  
  // Filter and prepare data based on selected time range
  List<AirQualityData> _getFilteredData(List<AirQualityData> allData) {
    final now = DateTime.now();
    DateTime startTime;
    
    switch (_selectedTimeRange) {
      case '12h':
        startTime = now.subtract(const Duration(hours: 12));
        break;
      case '7d':
        startTime = now.subtract(const Duration(days: 7));
        break;
      case '30d':
        startTime = now.subtract(const Duration(days: 30));
        break;
      case '24h':
      default:
        startTime = now.subtract(const Duration(hours: 24));
        break;
    }
    
    return allData.where((data) => data.timestamp.isAfter(startTime)).toList();
  }

  // AQI Level Colors (matching the app's theme)
  static const Color _aqiGood = Color(0xFF00E676);
  static const Color _aqiModerate = Color(0xFFFFC107);
  static const Color _aqiUnhealthySensitive = Color(0xFFFF9800);
  static const Color _aqiUnhealthy = Color(0xFFF44336);
  static const Color _aqiVeryUnhealthy = Color(0xFF9C27B0);
  static const Color _aqiHazardous = Color(0xFF7B1FA2);
  
  Color _getAqiColor(double value) {
    if (value <= 50) return _aqiGood;
    if (value <= 100) return _aqiModerate;
    if (value <= 150) return _aqiUnhealthySensitive;
    if (value <= 200) return _aqiUnhealthy;
    if (value <= 300) return _aqiVeryUnhealthy;
    return _aqiHazardous;
  }

  String _getAqiStatus(double value) {
    if (value <= 50) return 'Good';
    if (value <= 100) return 'Moderate';
    if (value <= 150) return 'Unhealthy (Sensitive)';
    if (value <= 200) return 'Unhealthy';
    if (value <= 300) return 'Very Unhealthy';
    return 'Hazardous';
  }
  
  // Helper widget for stat cards
  Widget _buildStatCard(BuildContext context, String title, String value, Color color) {
    final theme = Theme.of(context);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.hintColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: theme.textTheme.titleLarge?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Track which points are being touched
  List<int> _touchedIndices = [];
  
  // Sample data points to reduce clutter in the chart
  List<AirQualityData> _sampleData(List<AirQualityData> data, {int maxPoints = 50}) {
    if (data.length <= maxPoints) return data;
    
    final step = (data.length / maxPoints).ceil();
    return List.generate(
      (data.length / step).ceil(),
      (index) => data[index * step],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sensorProvider = Provider.of<SensorProvider>(context);
    final airQualityProvider = Provider.of<AirQualityProvider>(context);
    final currentAirQuality = sensorProvider.airQuality.toDouble();
    
    // Get combined historical and forecast data
    final allData = [
      ...airQualityProvider.historicalData,
      ...airQualityProvider.forecastData,
    ];
    
    // Filter data based on selected time range
    final filteredData = _getFilteredData(allData);
    final historicalData = _getFilteredData(airQualityProvider.historicalData);
    
    // Calculate statistics
    final aqiValues = filteredData.map((e) => e.aqi ?? 0).toList();
    final minAqi = aqiValues.isEmpty ? 0 : aqiValues.reduce((a, b) => a < b ? a : b);
    final maxAqi = aqiValues.isEmpty ? 0 : aqiValues.reduce((a, b) => a > b ? a : b);
    final avgAqi = aqiValues.isEmpty ? 0 : aqiValues.reduce((a, b) => a + b) / aqiValues.length;
    
    // Calculate trend (comparing current period with equivalent previous period)
    final currentPeriod = historicalData;
    
    // Calculate the duration of the current period
    final duration = _selectedTimeRange == '12h' 
        ? const Duration(hours: 12)
        : _selectedTimeRange == '24h'
            ? const Duration(hours: 24)
            : _selectedTimeRange == '7d'
                ? const Duration(days: 7)
                : const Duration(days: 30);
    
    // Get the previous period data (same duration as current period, but before the current period)
    final periodEnd = DateTime.now().subtract(duration);
    final periodStart = periodEnd.subtract(duration);
    
    // Include data points that fall exactly on the period boundaries
    final previousPeriod = airQualityProvider.historicalData
        .where((data) => 
            !data.timestamp.isBefore(periodStart) && 
            !data.timestamp.isAfter(periodEnd))
        .toList();
    
    // Calculate average AQI for current period
    final currentPeriodAqi = currentPeriod.map((e) => e.aqi ?? 0).toList();
    final currentAvg = currentPeriodAqi.isEmpty ? 0 : 
        currentPeriodAqi.reduce((a, b) => a + b) / currentPeriodAqi.length;
    
    // Calculate average AQI for previous period
    final previousPeriodAqi = previousPeriod.map((e) => e.aqi ?? 0).toList();
    final previousAvg = previousPeriodAqi.isEmpty ? 0 : 
        previousPeriodAqi.reduce((a, b) => a + b) / previousPeriodAqi.length;
    
    // Calculate trend percentage
    final trend = previousAvg > 0 ? ((currentAvg - previousAvg) / previousAvg) * 100 : 0;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Air Quality Trend'),
        actions: [
          // Time range selector
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: DropdownButton<String>(
              value: _selectedTimeRange,
              underline: const SizedBox(),
              icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedTimeRange = newValue;
                  });
                }
              },
              items: <String>['12h', '24h', '7d', '30d']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    value,
                    style: const TextStyle(color: Colors.black),
                  ),
                );
              }).toList(),
            ),
          ),
          IconButton(
            icon: Icon(_showPrediction ? Icons.visibility : Icons.visibility_off),
            onPressed: () {
              setState(() {
                _showPrediction = !_showPrediction;
              });
            },
            tooltip: _showPrediction ? 'Hide Forecast' : 'Show Forecast',
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
                color: _getAqiColor(currentAirQuality).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _getAqiColor(currentAirQuality).withValues(alpha: 0.3),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
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
            
            // AQI Chart
            const SizedBox(height: 24),
            Text(
              'AQI Trend',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 350,
              child: LineChart(
                LineChartData(
                  minX: 0,
                  // Use sampled data for better performance and clarity
                  maxX: filteredData.isNotEmpty ? (filteredData.length - 1).toDouble() : 1,
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      tooltipBgColor: theme.cardColor.withValues(alpha: 0.9),
                      tooltipRoundedRadius: 8,
                      getTooltipItems: (List<LineBarSpot> touchedSpots) {
                        return touchedSpots.map((spot) {
                          // Get the original data index from the x-coordinate
                          final dataIndex = spot.x.toInt();
                          // Ensure the index is within bounds
                          final isIndexValid = dataIndex >= 0 && dataIndex < filteredData.length;
                          final timestamp = isIndexValid 
                              ? _formatTimeRange(filteredData[dataIndex].timestamp)
                              : 'Unknown time';
                              
                          final text = '$timestamp\n${spot.y.toStringAsFixed(1)} AQI';
                          return LineTooltipItem(
                            text,
                            theme.textTheme.bodyMedium!,
                            textAlign: TextAlign.center,
                            children: [
                              TextSpan(
                                text: '\n${_getAqiStatus(spot.y)}',
                                style: theme.textTheme.bodySmall!.copyWith(
                                  color: _getAqiColor(spot.y),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          );
                        }).toList();
                      },
                    ),
                    touchCallback: (FlTouchEvent event, LineTouchResponse? touchResponse) {
                      if (!mounted) return;
                      
                      if (event is FlPanEndEvent || event is FlLongPressEnd) {
                        setState(() {
                          _touchedIndices = [];
                        });
                      } else if (touchResponse?.lineBarSpots != null) {
                        setState(() {
                          _touchedIndices = touchResponse!.lineBarSpots!
                              .map((spot) => spot.x.toInt()) // Store original data index
                              .toList();
                        });
                      }
                    },
                  ),
                  minY: (minAqi * 0.9).clamp(0, double.infinity), // Add some padding, ensure non-negative
                  maxY: (maxAqi * 1.1).clamp(0, double.infinity), // Add some padding, ensure non-negative
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: true,
                    drawHorizontalLine: true,
                    horizontalInterval: maxAqi > minAqi ? ((maxAqi - minAqi) / 4).roundToDouble() : 10,
                    verticalInterval: filteredData.length > 10 ? (filteredData.length / 4).floorToDouble() : 1,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: theme.dividerColor.withValues(alpha: 0.1),
                      strokeWidth: 0.5,
                      dashArray: [4, 4],
                    ),
                    getDrawingVerticalLine: (value) => FlLine(
                      color: theme.dividerColor.withValues(alpha: 0.05),
                      strokeWidth: 0.5,
                      dashArray: [2, 4],
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: filteredData.length > 10 ? (filteredData.length / 4).floorToDouble() : 1,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= 0 && 
                              value.toInt() < filteredData.length &&
                              value.toInt() % ((filteredData.length / 4).floor().clamp(1, filteredData.length)) == 0) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                _formatTimeRange(filteredData[value.toInt()].timestamp),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.hintColor,
                                  fontSize: 10,
                                ),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: maxAqi > minAqi ? ((maxAqi - minAqi) / 4).roundToDouble() : 10,
                        reservedSize: 36,
                        getTitlesWidget: (value, meta) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Text(
                              value.toInt().toString(),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.hintColor,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(
                      color: theme.dividerColor.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  lineBarsData: [
                    // Historical data line (only actual historical data, no forecast)
                    LineChartBarData(
                      spots: _sampleData(historicalData, maxPoints: 50).asMap().entries.map((entry) {
                        // Find the original index to maintain correct x-position
                        final originalIndex = historicalData.indexOf(entry.value);
                        return FlSpot(
                          originalIndex.toDouble(),
                          entry.value.aqi?.toDouble() ?? 0,
                        );
                      }).toList(),
                      isCurved: true,
                      curveSmoothness: 0.3, // Slightly smoother curve
                      color: theme.primaryColor,
                      barWidth: 2.5,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          final dataIndex = spot.x.toInt();
                          final isTouched = _touchedIndices.contains(dataIndex);
                          return FlDotCirclePainter(
                            radius: isTouched ? 5 : 0, // Only show dot when touched
                            color: _getAqiColor(spot.y),
                            strokeWidth: 2,
                            strokeColor: Colors.white,
                          );
                        },
                        checkToShowDot: (spot, barData) {
                          // Only show dot for the first, last, and touched points
                          final dataIndex = spot.x.toInt();
                          return dataIndex == 0 || 
                                 dataIndex == historicalData.length - 1 ||
                                 _touchedIndices.any((i) => i == dataIndex);
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            theme.primaryColor.withValues(alpha: 0.2),
                            theme.primaryColor.withValues(alpha: 0.05),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                    // Forecast line (dashed)
                    if (_showPrediction && airQualityProvider.forecastData.isNotEmpty)
                      LineChartBarData(
                        spots: _sampleData(filteredData.where((d) => d.timestamp.isAfter(DateTime.now())).toList(), maxPoints: 20).map((dataPoint) {
                          final index = filteredData.indexOf(dataPoint);
                          return FlSpot(
                            index.toDouble(),
                            dataPoint.aqi?.toDouble() ?? 0,
                          );
                        }).toList(),
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
            
            // Statistics Section
            const SizedBox(height: 24),
            Text(
              'AQI Statistics',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildStatCard(
                  context,
                  'Min AQI',
                  minAqi.toStringAsFixed(0),
                  _getAqiColor(minAqi.toDouble()),
                ),
                const SizedBox(width: 12),
                _buildStatCard(
                  context,
                  'Avg AQI',
                  avgAqi.toStringAsFixed(1),
                  _getAqiColor(avgAqi.toDouble()),
                ),
                const SizedBox(width: 12),
                _buildStatCard(
                  context,
                  'Max AQI',
                  maxAqi.toStringAsFixed(0),
                  _getAqiColor(maxAqi.toDouble()),
                ),
              ],
            ),
            
            // Trend Indicator
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.dividerColor.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    trend >= 0 ? Icons.trending_up : Icons.trending_down,
                    color: trend >= 0 ? Colors.red : Colors.green,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          trend >= 0 ? 'AQI Trend: Increasing' : 'AQI Trend: Improving',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          trend >= 0 
                              ? '${trend.abs().toStringAsFixed(1)}% higher than previous period'
                              : '${trend.abs().toStringAsFixed(1)}% lower than previous period',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.hintColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
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
