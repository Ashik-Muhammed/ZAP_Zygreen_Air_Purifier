import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:zygreen_air_purifier/theme/app_theme.dart';

class UserManualScreen extends StatelessWidget {
  const UserManualScreen({super.key});

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
                'User Manual',
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
                _buildSection(
                  context,
                  title: 'PHASE 1: INITIAL SETUP',
                  icon: Icons.settings_outlined,
                  children: [
                    _buildStep(
                      context,
                      title: '1. Fill the Cylinder',
                      content: '1. Open the top lid of the device.\n'
                          '2. Fill the main cylinder with normal or filtered water.\n\n'
                          'Important: Avoid chlorinated tap water—chlorine harms the algae.',
                      imagePath: 'assets/images/ob1.jpg',
                    ),
                    _buildStep(
                      context,
                      title: '2. Add the Algae Culture',
                      content: '1. Take the culture vial provided in your starter kit.\n'
                          '2. Pour the full contents into the water-filled cylinder.',
                      imagePath: 'assets/images/ob2.jpg',
                    ),
                    _buildStep(
                      context,
                      title: '3. Power Up & Connect',
                      content: '1. Plug your purifier into a power outlet.\n'
                          '2. Download the zygreen app.\n'
                          '3. Follow the app instructions to pair your device.\n\n'
                          'Your system is now active—absorbing CO₂ and releasing fresh oxygen.',
                      imagePath: 'assets/images/ob3.jpg',
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.spacingXL),
                _buildSection(
                  context,
                  title: 'PHASE 2: MONTHLY MAINTENANCE',
                  icon: Icons.construction_outlined,
                  children: [
                    _buildStep(
                      context,
                      title: '1. Clean the Bio-Filter',
                      content: '1. Turn off the device.\n'
                          '2. Remove the bio-filter unit.\n'
                          '3. Dispose of the collected dead algae biomass (safe to compost).\n'
                          '4. Rinse and clean the filter housing as guided in the app.\n'
                          '5. Insert the clean filter back into the unit.',
                      imagePath: 'assets/images/ob4.jpg',
                    ),
                    _buildStep(
                      context,
                      title: '2. Empty the Dehumidifier',
                      content: '1. Locate the dehumidifier tank at the bottom/back.\n'
                          '2. Slide it out and discard the collected water.\n\n'
                          'Do not reuse this water in the algae cylinder.',
                      imagePath: 'assets/images/ob5.jpg',
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.spacingXL),
                _buildSection(
                  context,
                  title: 'PHASE 3: GENERAL CARE',
                  icon: Icons.health_and_safety_outlined,
                  children: [
                    _buildBulletPoint(
                      'Follow App Alerts: The app monitors algae health and will notify you about cleaning or refilling.',
                    ),
                    _buildBulletPoint(
                      'Light & Heat: The device includes internal grow lights. Keep it away from direct sunlight or heat sources to prevent overheating.',
                    ),
                    _buildBulletPoint(
                      'Stable Placement: Place the purifier on a flat, steady surface for best airflow and algae growth.',
                    ),
                  ],
                ),
                const SizedBox(height: 40),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primary.withAlpha(25),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: AppTheme.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: textTheme.titleLarge?.copyWith(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...children,
      ],
    );
  }

  Widget _buildStep(
    BuildContext context, {
    required String title,
    required String content,
    String? imagePath,
  }) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: textTheme.titleMedium?.copyWith(
              color: AppTheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          if (imagePath != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                imagePath,
                width: double.infinity,
                fit: BoxFit.cover,
                height: 180,
              ),
            ),
            const SizedBox(height: 12),
          ],
          Text(
            content,
            style: textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSecondary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 4, right: 8),
            child: Icon(
              Icons.circle,
              size: 8,
              color: AppTheme.primary,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}