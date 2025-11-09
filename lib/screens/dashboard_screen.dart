// ignore_for_file: unused_element

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:zygreen_air_purifier/providers/sensor_provider.dart';
import 'package:zygreen_air_purifier/screens/air_quality_trend_screen.dart';
import 'package:zygreen_air_purifier/theme/app_theme.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    // Initialize data when widget is first created
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final sensorProvider = Provider.of<SensorProvider>(context, listen: false);
      sensorProvider.initSensorData();
      
      // Set up periodic refresh every 30 seconds
      _refreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
        sensorProvider.initSensorData(); // Reuse initSensorData for refresh
      });
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
    super.dispose();
  }

  Color _getTemperatureColor(double temperature) {
    if (temperature < 18) return Colors.blue;
    if (temperature < 25) return Colors.green;
    if (temperature < 30) return Colors.orange;
    return Colors.red;
  }

  Color _getHumidityColor(double humidity) {
    if (humidity < 30) return Colors.orange;
    if (humidity < 60) return Colors.green;
    return Colors.blue;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await Provider.of<SensorProvider>(context, listen: false)
                .refreshSensorData();
          },
          child: Consumer<SensorProvider>(
            builder: (context, sensorProvider, _) {
              return CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // App Bar
                  SliverAppBar(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    floating: true,
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hello, User',
                          style: textTheme.titleLarge?.copyWith(
                            color: Colors.black87,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Here\'s your air quality',
                          style: textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    actions: [
                      IconButton(
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(Icons.notifications_outlined,
                              color: Colors.black87),
                        ),
                        onPressed: () {},
                      ),
                      const SizedBox(width: 16),
                    ],
                  ),

                  // Main content
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildAirQualityCard(context, sensorProvider, theme),
                          const SizedBox(height: 20),
                          _buildMetricsGrid(context, sensorProvider, theme),
                          const SizedBox(height: 20),
                          _buildRecommendationsSection(theme),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  // --- AIR QUALITY CARD ---
  Widget _buildAirQualityCard(
      BuildContext context, SensorProvider sensorProvider, ThemeData theme) {
    final aqi = sensorProvider.airQuality.toDouble();
    final aqiColor = _getAqiColor(aqi);
    final aqiStatus = _getAqiStatus(aqi);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AirQualityTrendScreen(
              currentAirQuality: sensorProvider.airQuality.toDouble(),
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: aqiColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: aqiColor.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Air Quality Index (AQI)',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: aqiColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    aqiStatus,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: aqiColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  aqi.toStringAsFixed(1),
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: aqiColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    'AQI',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  'View Full Trend',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 12,
                  color: theme.primaryColor,
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildAqiProgressBar(aqi, aqiColor, theme),
          ],
        ),
      ),
    );
  }

  Widget _buildAqiProgressBar(double aqiValue, Color aqiColor, ThemeData theme) {
    final double progress = (aqiValue / 500).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LayoutBuilder(
          builder: (context, constraints) => Container(
            height: 8,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(4),
            ),
            child: Stack(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeInOut,
                  width: constraints.maxWidth * progress,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF10B981), Color(0xFF3B82F6)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('0', style: TextStyle(fontSize: 10, color: Colors.grey)),
            Text('50', style: TextStyle(fontSize: 10, color: Colors.grey)),
            Text('100', style: TextStyle(fontSize: 10, color: Colors.grey)),
            Text('200', style: TextStyle(fontSize: 10, color: Colors.grey)),
            Text('300+', style: TextStyle(fontSize: 10, color: Colors.grey)),
          ],
        ),
      ],
    );
  }

  String _getAqiStatus(double aqi) {
    if (aqi <= 50) return 'Good';
    if (aqi <= 100) return 'Moderate';
    if (aqi <= 150) return 'Unhealthy (Sensitive)';
    if (aqi <= 200) return 'Unhealthy';
    if (aqi <= 300) return 'Very Unhealthy';
    return 'Hazardous';
  }

  Color _getAqiColor(double aqi) {
    if (aqi <= 50) return AppTheme.success;
    if (aqi <= 100) return Colors.yellow[700]!;
    if (aqi <= 150) return Colors.orange;
    if (aqi <= 200) return Colors.red;
    if (aqi <= 300) return Colors.purple;
    return Colors.deepPurple[900]!;
  }

  // --- METRICS GRID ---
  Widget _buildMetricsGrid(
      BuildContext context, SensorProvider sensorProvider, ThemeData theme) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.2,
      children: [
        _buildMetricCard(
          context: context,
          title: 'PM2.5',
          value: sensorProvider.pm25.toStringAsFixed(1),
          unit: 'µg/m³',
          icon: Icons.air,
          color: const Color(0xFF3B82F6),
          isLoading: sensorProvider.isLoading,
        ),
        _buildMetricCard(
          context: context,
          title: 'PM10',
          value: sensorProvider.pm10.toStringAsFixed(1),
          unit: 'µg/m³',
          icon: Icons.air,
          color: const Color(0xFF8B5CF6),
          isLoading: sensorProvider.isLoading,
        ),
        _buildMetricCard(
          context: context,
          title: 'Temperature',
          value: sensorProvider.temperature.toStringAsFixed(1),
          unit: '°C',
          icon: Icons.thermostat,
          color: _getTemperatureColor(sensorProvider.temperature),
          isLoading: sensorProvider.isLoading,
        ),
        _buildMetricCard(
          context: context,
          title: 'Humidity',
          value: sensorProvider.humidity.toStringAsFixed(1),
          unit: '%',
          icon: Icons.water_drop,
          color: _getHumidityColor(sensorProvider.humidity),
          isLoading: sensorProvider.isLoading,
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required BuildContext context,
    required String title,
    required String value,
    required String unit,
    required IconData icon,
    required Color color,
    required bool isLoading,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const Spacer(),
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (isLoading)
            Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                height: 24,
                width: 60,
                color: Colors.white,
              ),
            )
          else
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              child: RichText(
                key: ValueKey(value),
                text: TextSpan(
                  text: value,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                  children: [
                    TextSpan(
                      text: ' $unit',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  // --- RECOMMENDATIONS ---
  Widget _buildRecommendationsSection(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
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
          Text(
            'Recommendations',
            style: theme.textTheme.titleMedium?.copyWith(
              color: Colors.black87,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          _buildRecommendationItem(
            'Open Windows',
            'Ventilate your space for better air circulation',
            Icons.open_in_new,
            const Color(0xFF10B981),
          ),
          const SizedBox(height: 12),
          _buildRecommendationItem(
            'Use Air Purifier',
            'Turn on your air purifier to improve air quality',
            Icons.air,
            const Color(0xFF3B82F6),
          ),
          const SizedBox(height: 12),
          _buildRecommendationItem(
            'Check Filters',
            'Time to clean or replace your air filters',
            Icons.filter_alt,
            const Color(0xFF8B5CF6),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationItem(
      String title, String subtitle, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.w600,
                        fontSize: 14)),
                const SizedBox(height: 4),
                Text(subtitle,
                    style: TextStyle(color: Colors.grey[600], fontSize: 12)),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: Colors.grey[400]),
        ],
      ),
    );
  }
}

class _AirQualityStatus extends StatelessWidget {
  final int aqiValue;
  const _AirQualityStatus({required this.aqiValue});

  String get _getAqiLabel {
    if (aqiValue <= 50) return 'Good';
    if (aqiValue <= 100) return 'Moderate';
    if (aqiValue <= 150) return 'Unhealthy (Sensitive)';
    if (aqiValue <= 200) return 'Unhealthy';
    if (aqiValue <= 300) return 'Very Unhealthy';
    return 'Hazardous';
  }

  Color get _getAqiColor {
    if (aqiValue <= 50) return AppTheme.success;
    if (aqiValue <= 100) return Colors.yellow[700]!;
    if (aqiValue <= 150) return Colors.orange;
    if (aqiValue <= 200) return Colors.red;
    if (aqiValue <= 300) return Colors.purple;
    return Colors.deepPurple[900]!;
  }

  @override
  Widget build(BuildContext context) {
    final color = _getAqiColor;
    final label = _getAqiLabel;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.5), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Text(label,
              style: Theme.of(context)
                  .textTheme
                  .labelMedium
                  ?.copyWith(color: color, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
