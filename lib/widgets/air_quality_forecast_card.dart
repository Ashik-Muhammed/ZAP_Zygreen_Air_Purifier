import 'package:flutter/material.dart';
import 'package:zygreen_air_purifier/models/air_quality_data.dart';
import 'package:zygreen_air_purifier/theme/app_theme.dart';
import 'package:intl/intl.dart';

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
            _buildHourlyForecast(theme, context),
            const SizedBox(height: 16),
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

  // Helper method to get AQI color based on AQI value
  static Color _getAqiColor(int aqi) {
    if (aqi <= 50) return _aqiGood;
    if (aqi <= 100) return _aqiModerate;
    if (aqi <= 150) return _aqiUnhealthySensitive;
    if (aqi <= 200) return _aqiUnhealthy;
    if (aqi <= 300) return _aqiVeryUnhealthy;
    return _aqiHazardous;
  }

  Widget _buildCurrentStatus(ThemeData theme, int currentAqi, int forecastAqi) {

    return Row(
      children: [
        _buildAqiIndicator('Current', currentAqi, AirQualityForecastCard._getAqiColor(currentAqi), theme),
        const SizedBox(width: 16),
        _buildAqiIndicator('Forecast', forecastAqi, AirQualityForecastCard._getAqiColor(forecastAqi), theme),
      ],
    );
  }

  Widget _buildAqiIndicator(String label, int value, Color color, ThemeData theme) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.primary.withAlpha(25),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withAlpha(100)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withAlpha(179), // 0.7 * 255 ≈ 179
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

  Widget _buildHourlyForecast(ThemeData theme, BuildContext context) {
    // Get the current locale from the BuildContext
    final locale = Localizations.localeOf(context).toString();
    // Take up to 6 hours of forecast data
    final hourlyData = forecastData.take(6).toList();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hourly Forecast',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 100,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: hourlyData.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final data = hourlyData[index];
              // Use locale-aware time format (12/24h based on device settings)
              final time = DateFormat.j(locale).format(data.timestamp);
              final aqi = data.aqi ?? 0;
              final color = _getAqiColor(aqi);
              
              return Container(
                width: 70,
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.dividerColor.withAlpha(50),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(20),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      time,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withAlpha(200),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      width: 36,
                      height: 36,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: color.withAlpha(30),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: color.withAlpha(150),
                          width: 1.5,
                        ),
                      ),
                      child: Text(
                        aqi.toString(),
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
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
                    color: theme.colorScheme.onSurface.withAlpha(179), // 0.7 * 255 ≈ 179
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
