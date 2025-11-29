import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:zygreen_air_purifier/theme/app_theme.dart';

class DataPrivacyScreen extends StatelessWidget {
  const DataPrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 140.0,
            pinned: true,
            backgroundColor: AppTheme.surface,
            systemOverlayStyle: SystemUiOverlayStyle.dark,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'Data & Privacy',
                style: textTheme.titleLarge?.copyWith(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppTheme.primary.withAlpha(25),
                      AppTheme.background,
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(AppTheme.spacingM),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildSectionHeader('Data Collection', context: context),
                const SizedBox(height: AppTheme.spacingS),
                _buildPrivacyCard(
                  context,
                  icon: Icons.data_usage_rounded,
                  title: 'What data we collect',
                  content:
                      'We collect air quality metrics (PM2.5, PM10, temperature, humidity) to provide you with insights and improve our services. All data is anonymized and cannot be used to identify you personally.',
                ),
                const SizedBox(height: AppTheme.spacingM),
                _buildPrivacyCard(
                  context,
                  icon: Icons.analytics_rounded,
                  title: 'How we use your data',
                  bulletPoints: const [
                    'Provide real-time air quality monitoring',
                    'Generate historical trends and reports',
                    'Improve our air quality prediction algorithms',
                    'Enhance app functionality and user experience',
                  ],
                ),
                const SizedBox(height: AppTheme.spacingL),
                _buildSectionHeader('Data Security', context: context),
                const SizedBox(height: AppTheme.spacingS),
                _buildPrivacyCard(
                  context,
                  icon: Icons.security_rounded,
                  title: 'Protecting your information',
                  content:
                      'We implement industry-standard security measures to protect your data. All data transmitted between your device and our servers is encrypted using TLS 1.2+.',
                ),
                const SizedBox(height: AppTheme.spacingL),
                _buildSectionHeader('Your Rights', context: context),
                const SizedBox(height: AppTheme.spacingS),
                _buildPrivacyCard(
                  context,
                  icon: Icons.privacy_tip_rounded,
                  title: 'Control your data',
                  content:
                      'You have the right to access, correct, or delete your personal data. You can also request a copy of your data or withdraw your consent at any time.',
                ),
                const SizedBox(height: AppTheme.spacingXL),
                Container(
                  padding: const EdgeInsets.all(AppTheme.spacingL),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(AppTheme.radiusL),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(8),  // ~3% opacity
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppTheme.accent.withAlpha(25),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.help_outline_rounded,
                              color: AppTheme.accent,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: AppTheme.spacingM),
                          Text(
                            'Need Help?',
                            style: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppTheme.spacingM),
                      Text(
                        'If you have any questions about our data practices, please contact us at:',
                        style: textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: AppTheme.spacingM),
                      InkWell(
                        onTap: () {
                          // Handle email tap
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 4),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.email_rounded,
                                color: AppTheme.primary,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'zygreeninnovations@gmail.com',
                                style: textTheme.bodyLarge?.copyWith(
                                  color: AppTheme.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppTheme.spacingXL),
                Center(
                  child: Text(
                    'Last Updated: ${DateTime.now().toString().split(' ')[0]}',
                    style: textTheme.bodySmall?.copyWith(
                      color: AppTheme.textTertiary,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, {BuildContext? context}) {
    final theme = context != null ? Theme.of(context) : ThemeData();
    final textTheme = theme.textTheme;
    return Row(
      children: [
        Container(
          height: 24,
          width: 4,
          decoration: BoxDecoration(
            color: AppTheme.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
        ),
      ],
    );
  }

  Widget _buildPrivacyCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? content,
    List<String>? bulletPoints,
  }) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusL),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withAlpha(25),  // ~10% opacity
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: AppTheme.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: AppTheme.spacingM),
                Expanded(
                  child: Text(
                    title,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingM),
            if (content != null)
              Text(
                content,
                style: textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                  height: 1.6,
                ),
              ),
            if (bulletPoints != null) ...[
              const SizedBox(height: 8),
              ...bulletPoints.map((point) => Padding(
                    padding: const EdgeInsets.only(bottom: 6.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 5.0, right: 8.0),
                          child: Icon(
                            Icons.circle,
                            size: 6,
                            color: AppTheme.primary,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            point,
                            style: textTheme.bodyMedium?.copyWith(
                              color: AppTheme.textSecondary,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                ),
            ],
          ],
        ),
      ),
    );
  }
}