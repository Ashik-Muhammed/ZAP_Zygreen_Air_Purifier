import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:zygreen_air_purifier/models/air_quality_data.dart';

class AirQualityForecastCard extends StatelessWidget {
  final int currentAqi;
  final List<AirQualityData> forecastData;
  final bool isLoading;

  const AirQualityForecastCard({
    super.key,
    required this.currentAqi,
    required this.forecastData,
    this.isLoading = false,
  });

  // Adjusted colors to pop on dark background
  Color _getAqiColor(int aqi) {
    if (aqi <= 50) return const Color(0xFF00E676);
    if (aqi <= 100) return const Color(0xFFFFC107);
    if (aqi <= 150) return const Color(0xFFFF9800);
    if (aqi <= 200) return const Color(0xFFF44336);
    if (aqi <= 300) return const Color(0xFF9C27B0);
    return const Color(0xFF7B1FA2);
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return _buildLoadingState();
    }

    if (forecastData.isEmpty) {
      return const SizedBox.shrink();
    }

    // Logic
    final forecastAqi = (forecastData.first.aqi ?? 0).round();
    final difference = forecastAqi - currentAqi;
    final isImproving = difference <= 0;

    // Glassmorphism Container (Matches Dashboard)
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        // Dark glass background
        color: Colors.white.withValues(alpha: 0.08), 
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          _buildCurrentStatus(currentAqi, forecastAqi),
          const SizedBox(height: 24),
          _buildHourlyForecast(context),
          const SizedBox(height: 20),
          _buildForecastSummary(isImproving, difference.abs()),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        // Icon container matching dashboard style
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFF00D9FF).withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.insights_rounded, 
            color: Color(0xFF00D9FF), 
            size: 20
          ),
        ),
        const SizedBox(width: 16),
        const Text(
          'Air Quality Forecast',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildCurrentStatus(int current, int forecast) {
    return Row(
      children: [
        Expanded(
          child: _buildAqiIndicator('Current', current, _getAqiColor(current))
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildAqiIndicator('1h Forecast', forecast, _getAqiColor(forecast))
        ),
      ],
    );
  }

  Widget _buildAqiIndicator(String label, int value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value.toString(),
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: color,
                  height: 1.0,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                'AQI',
                style: TextStyle(
                  color: color.withValues(alpha: 0.8),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHourlyForecast(BuildContext context) {
    final hourlyData = forecastData.take(5).toList();
    if (hourlyData.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hourly Trend',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 90, // Fixed height for the list
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: hourlyData.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final data = hourlyData[index];
              final time = DateFormat.j().format(data.timestamp);
              final aqi = (data.aqi ?? 0).round();
              final color = _getAqiColor(aqi);

              return Container(
                width: 64,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      time, 
                      style: TextStyle(
                        fontSize: 11, 
                        color: Colors.white.withValues(alpha: 0.6)
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 36,
                      height: 36,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                        border: Border.all(color: color.withValues(alpha: 0.6), width: 1.5),
                      ),
                      child: Text(
                        aqi.toString(),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
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

  Widget _buildForecastSummary(bool isImproving, int difference) {
    final color = isImproving ? const Color(0xFF00E676) : const Color(0xFFFF9800);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        // Subtle colored background
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isImproving ? Icons.trending_down : Icons.trending_up,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isImproving ? 'Improving Air Quality' : 'Declining Air Quality',
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isImproving 
                      ? 'Expected to drop by $difference points.' 
                      : 'Expected to rise by $difference points.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildLoadingState() {
    return Container(
      height: 200,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: const Center(
        child: CircularProgressIndicator(color: Color(0xFF00D9FF)),
      ),
    );
  }
  
}