import 'dart:math';
import 'package:flutter/material.dart';
import 'package:zygreen_air_purifier/models/air_quality_data.dart';
import 'package:intl/intl.dart';
import 'package:zygreen_air_purifier/theme/app_theme.dart';

class AirQualityForecastCard extends StatelessWidget {
  final List<AirQualityData> historicalData;
  final List<AirQualityData> forecastData;
  final bool isLoading;

  const AirQualityForecastCard({
    super.key,
    required this.historicalData,
    required this.forecastData,
    this.isLoading = false,
  });

  // AQI Level Colors
  static const Color _aqiGood = Color(0xFF00E676);
  static const Color _aqiModerate = Color(0xFFFFC107);
  static const Color _aqiUnhealthySensitive = Color(0xFFFF9800);
  static const Color _aqiUnhealthy = Color(0xFFF44336);
  static const Color _aqiVeryUnhealthy = Color(0xFF9C27B0);
  static const Color _aqiHazardous = Color(0xFF7B1FA2);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    if (isLoading) {
      return _buildLoadingCard(theme);
    }

    if (historicalData.isEmpty || forecastData.isEmpty) {
      return _buildEmptyState(theme);
    }

    final currentAqi = historicalData.isNotEmpty ? historicalData.last.aqi ?? 0 : 0;
    final forecastAqi = forecastData.isNotEmpty ? forecastData.last.aqi ?? 0 : 0;
    final difference = forecastAqi - currentAqi;
    final isImproving = difference <= 0;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.air,
                  color: AppTheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Air Quality Forecast',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const Spacer(),
                const Tooltip(
                  message: 'Based on historical data and trends',
                  child: Icon(Icons.info_outline, size: 20),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildCurrentStatus(theme, currentAqi, forecastAqi),
            const SizedBox(height: 24),
            SizedBox(
              height: 180,
              child: _buildForecastChart(theme),
            ),
            const SizedBox(height: 16),
            _buildHourlyForecast(theme),
            const SizedBox(height: 8),
            _buildForecastSummary(theme, isImproving, difference.abs().toInt()),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingCard(ThemeData theme) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: const Padding(
        padding: EdgeInsets.all(24.0),
        child: Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Icon(
              Icons.insights_outlined,
              size: 48,
              color: theme.hintColor.withAlpha(128),
            ),
            const SizedBox(height: 16),
            Text(
              'Not enough data for prediction',
              style: theme.textTheme.bodyLarge?.copyWith(color: theme.hintColor),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForecastChart(ThemeData theme) {
    if (historicalData.isEmpty && forecastData.isEmpty) return const SizedBox();
    
    final allData = [...historicalData, ...forecastData];
    final pmValues = allData.map((e) => e.pm25 ?? 0).toList();
    final minPm = pmValues.reduce((a, b) => a < b ? a : b);
    final maxPm = pmValues.reduce((a, b) => a > b ? a : b);

    return CustomPaint(
      painter: _ForecastChartPainter(
        historicalData: historicalData,
        forecastData: forecastData,
        minValue: minPm,
        maxValue: maxPm,
        theme: theme,
      ),
    );
  }

  Widget _buildCurrentStatus(ThemeData theme, int currentAqi, int forecastAqi) {
    Color getAqiColor(int aqi) {
      if (aqi <= 50) return _aqiGood;
      if (aqi <= 100) return _aqiModerate;
      if (aqi <= 150) return _aqiUnhealthySensitive;
      if (aqi <= 200) return _aqiUnhealthy;
      if (aqi <= 300) return _aqiVeryUnhealthy;
      return _aqiHazardous;
    }

    return Row(
      children: [
        _buildAqiIndicator('Current', currentAqi, getAqiColor(currentAqi), theme),
        const SizedBox(width: 16),
        _buildAqiIndicator('Forecast', forecastAqi, getAqiColor(forecastAqi), theme),
      ],
    );
  }

  Widget _buildAqiIndicator(String label, int value, Color color, ThemeData theme) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.primary.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  value.toString(),
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  'AQI',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: color,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHourlyForecast(ThemeData theme) {
    // Show next 6 hours forecast
    final hourlyForecast = forecastData.length > 6 
        ? forecastData.sublist(0, 6)
        : forecastData;

    return SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: hourlyForecast.length,
        itemBuilder: (context, index) {
          final data = hourlyForecast[index];
          final aqi = data.aqi ?? 0;
          final time = DateFormat('ha').format(data.timestamp);
          
          return Container(
            width: 60,
            margin: const EdgeInsets.only(right: 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  time,
                  style: theme.textTheme.bodySmall,
                ),
                const SizedBox(height: 4),
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: _getAqiColor(aqi).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _getAqiColor(aqi),
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      aqi.toString(),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: _getAqiColor(aqi),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Color _getAqiColor(int aqi) {
    if (aqi <= 50) return _aqiGood;
    if (aqi <= 100) return _aqiModerate;
    if (aqi <= 150) return _aqiUnhealthySensitive;
    if (aqi <= 200) return _aqiUnhealthy;
    if (aqi <= 300) return _aqiVeryUnhealthy;
    return _aqiHazardous;
  }


  Widget _buildForecastSummary(ThemeData theme, bool isImproving, int difference) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isImproving 
            ? Colors.green.withAlpha(25) 
            : Colors.orange.withAlpha(25),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isImproving 
              ? Colors.green.withAlpha(100) 
              : Colors.orange.withAlpha(100),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isImproving ? Colors.green.withAlpha(50) : Colors.orange.withAlpha(50),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isImproving ? Icons.trending_down : Icons.trending_up,
              color: isImproving ? Colors.green : Colors.orange,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isImproving 
                      ? 'Air quality is improving' 
                      : 'Air quality may worsen',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isImproving
                      ? 'Expected improvement of $difference AQI points in the next few hours.'
                      : 'Expected increase of $difference AQI points. Consider taking precautions.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
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

class _ForecastChartPainter extends CustomPainter {
  final List<AirQualityData> historicalData;
  final List<AirQualityData> forecastData;
  final double minValue;
  final double maxValue;
  final ThemeData theme;
  
  static const double padding = 24.0;
  static const double pointRadius = 4.0;
  
  _ForecastChartPainter({
    required this.historicalData,
    required this.forecastData,
    required this.minValue,
    required this.maxValue,
    required this.theme,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (historicalData.isEmpty && forecastData.isEmpty) return;
    
    final allData = [...historicalData, ...forecastData];
    final valueRange = (maxValue - minValue).clamp(1.0, double.infinity);
    
    // Draw grid lines
    final gridPaint = Paint()
      ..color = theme.dividerColor.withValues(alpha: 0.2)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
    
    // Draw horizontal grid lines
    const horizontalLines = 5;
    for (var i = 0; i <= horizontalLines; i++) {
      final y = size.height - (i * size.height / horizontalLines);
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        gridPaint,
      );
    }
    
    // Draw vertical grid lines
    final verticalLines = min(6, allData.length - 1);
    if (verticalLines > 0) {
      for (var i = 0; i <= verticalLines; i++) {
        final x = (i * size.width / verticalLines);
        canvas.drawLine(
          Offset(x, 0),
          Offset(x, size.height),
          gridPaint,
        );
      }
    }
    
    // Draw grid lines
    _drawGrid(canvas, size, valueRange);
    
    // Draw historical data line
    if (historicalData.length > 1) {
      _drawLine(
        canvas,
        size,
        historicalData,
        minValue,
        valueRange,
        theme.primaryColor,
        false,
      );
    }
    
    // Draw forecast line
    if (forecastData.length > 1) {
      _drawLine(
        canvas,
        size,
        forecastData,
        minValue,
        valueRange,
        Colors.orange,
        true,
      );
    }
    
    // Draw current point
    if (historicalData.isNotEmpty) {
      final lastPoint = historicalData.last;
      final x = _getX(0, size, allData.length);
      final y = _getY(lastPoint.pm25 ?? 0, size, minValue, valueRange);
      
      final paint = Paint()
        ..color = theme.primaryColor
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(Offset(x, y), pointRadius * 1.5, paint);
    }
  }
  
  void _drawGrid(Canvas canvas, Size size, double valueRange) {
    final paint = Paint()
      ..color = theme.hintColor.withAlpha(77)
      ..strokeWidth = 1.0;
    
    // Draw horizontal grid lines
    const horizontalLines = 4;
    for (var i = 0; i <= horizontalLines; i++) {
      final y = padding + (size.height - 2 * padding) * (1 - i / horizontalLines);
      canvas.drawLine(
        Offset(padding, y),
        Offset(size.width - padding, y),
        paint,
      );
    }
  }
  
  void _drawLine(
    Canvas canvas,
    Size size,
    List<AirQualityData> data,
    double minValue,
    double valueRange,
    Color color,
    bool isDashed,
  ) {
    if (data.length < 2) return;
    
    final path = Path();
    final points = <Offset>[];
    
    // Create points
    for (var i = 0; i < data.length; i++) {
      final x = _getX(i, size, data.length);
      final y = _getY(data[i].pm25 ?? 0, size, minValue, valueRange);
      points.add(Offset(x, y));
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    
    // Draw line
    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    
    if (isDashed) {
      // Draw dashed line for forecast
      const dashWidth = 4.0;
      const dashSpace = 2.0;
      
      for (var i = 0; i < points.length - 1; i++) {
        final p1 = points[i];
        final p2 = points[i + 1];
        
        final dx = p2.dx - p1.dx;
        final dy = p2.dy - p1.dy;
        final distanceTotal = sqrt(dx * dx + dy * dy);
        
        var distanceCovered = 0.0;
        while (distanceCovered < distanceTotal) {
          final ratio = distanceCovered / distanceTotal;
          final x1 = p1.dx + dx * ratio;
          final y1 = p1.dy + dy * ratio;
          
          distanceCovered += dashWidth;
          if (distanceCovered > distanceTotal) {
            distanceCovered = distanceTotal;
          }
          
          final ratio2 = distanceCovered / distanceTotal;
          final x2 = p1.dx + dx * ratio2;
          final y2 = p1.dy + dy * ratio2;
          
          canvas.drawLine(Offset(x1, y1), Offset(x2, y2), linePaint);
          distanceCovered += dashSpace;
        }
      }
    } else {
      // Draw solid line for historical data
      canvas.drawPath(path, linePaint);
    }
    
    // Draw points
    final pointPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    
    for (final point in points) {
      canvas.drawCircle(point, pointRadius, pointPaint);
    }
  }
  
  double _getX(int index, Size size, int totalPoints) {
    final width = size.width - 2 * padding;
    return padding + (width / (totalPoints - 1)) * index;
  }
  
  double _getY(double value, Size size, double minValue, double valueRange) {
    final height = size.height - 2 * padding;
    final normalizedValue = (value - minValue) / valueRange;
    return size.height - padding - (normalizedValue * height);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
