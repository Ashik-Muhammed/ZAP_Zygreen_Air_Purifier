import 'package:flutter/material.dart';
import 'package:zygreen_air_purifier/theme/app_theme.dart';
import 'package:zygreen_air_purifier/widgets/metric_card.dart';
import 'package:zygreen_air_purifier/widgets/air_quality_chart.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Air Quality',
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // Navigate to notifications
            },
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Air Quality Chart
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: AppTheme.spacingM, vertical: AppTheme.spacingS),
                child: AirQualityChart(),
              ),
              
              // Current Air Quality Status
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingM, vertical: AppTheme.spacingS),
                child: Container(
                  decoration: AppTheme.cardDecoration(),
                  padding: const EdgeInsets.all(AppTheme.spacingM),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Current Air Quality',
                            style: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const _AirQualityStatus(label: 'Good', color: AppTheme.success),
                        ],
                      ),
                      const SizedBox(height: AppTheme.spacingM),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(AppTheme.radiusS),
                        child: LinearProgressIndicator(
                          value: 0.3,
                          backgroundColor: Colors.grey.shade100,
                          valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.success),
                          minHeight: 8,
                        ),
                      ),
                      const SizedBox(height: AppTheme.spacingS),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildAqiLabel('0'),
                          _buildAqiLabel('50'),
                          _buildAqiLabel('100'),
                          _buildAqiLabel('200'),
                          _buildAqiLabel('300+', isBold: true),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              
              // Air Quality Metrics
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingM,
                  vertical: AppTheme.spacingS,
                ),
                child: Text(
                  'Air Quality Metrics',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              
              // Metrics Grid
              const Padding(
                padding:   EdgeInsets.symmetric(horizontal: AppTheme.spacingM, vertical: AppTheme.spacingS),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: MetricCard(
                            title: 'PM2.5',
                            value: '12',
                            unit: 'µg/m³',
                            icon: Icons.air,
                            color: AppTheme.accent,
                          ),
                        ),
                        SizedBox(width: AppTheme.spacingM),
                        Expanded(
                          child: MetricCard(
                            title: 'PM10',
                            value: '24',
                            unit: 'µg/m³',
                            icon: Icons.air,
                            color: AppTheme.secondary,
                          ),
                        ),
                      ],
                    ),
                     SizedBox(height: AppTheme.spacingM),
                    Row(
                      children: [
                        Expanded(
                          child: MetricCard(
                            title: 'Temperature',
                            value: '24',
                            unit: '°C',
                            icon: Icons.thermostat,
                            color: AppTheme.warning,
                          ),
                        ),
                        SizedBox(width: AppTheme.spacingM),
                        Expanded(
                          child: MetricCard(
                            title: 'Humidity',
                            value: '45',
                            unit: '%',
                            icon: Icons.water_drop,
                            color: AppTheme.info,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // AI Recommendations
              const Padding(
                padding: EdgeInsets.fromLTRB(24, 16, 24, 8),
                child: Text(
                  'Recommendations',
                  style: TextStyle(
                    color: AppTheme.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        _buildRecommendationItem(
                          'Open windows for 15 minutes',
                          'Improves air circulation and reduces CO₂ levels',
                          Icons.refresh_outlined,
                        ),
                       const Divider(height: 24),
                        _buildRecommendationItem(
                          'Turn on air purifier',
                          'Recommended for optimal air quality maintenance',
                          Icons.air_outlined,
                        ),
                        const Divider(height: 24),
                        _buildRecommendationItem(
                          'Add indoor plants',
                          'Natural air purifiers like snake plants are effective',
                          Icons.eco_outlined,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecommendationItem(String title, String subtitle, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: AppTheme.primary,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Helper method to build AQI labels
  Widget _buildAqiLabel(String text, {bool isBold = false}) {
    return Builder(
      builder: (context) {
        final textStyle = Theme.of(context).textTheme.labelMedium?.copyWith(
          fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
        );
        return Text(text, style: textStyle);
      },
    );
  }
}

class _AirQualityStatus extends StatelessWidget {
  final String label;
  final Color color;

  const _AirQualityStatus({
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingS,
        vertical: AppTheme.spacingXS,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}