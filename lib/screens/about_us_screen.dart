import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:zygreen_air_purifier/theme/app_theme.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingM),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: AppTheme.spacingL),
                
                // Mission & Story Section
                _buildSectionHeader(context, 'Our Purpose'),
                const SizedBox(height: AppTheme.spacingM),
                _buildModernInfoCard(
                  context,
                  title: 'Our Mission',
                  content:
                      'At Zygreen, we are on a mission to build sustainable and innovative products for future generations.\n\nWe develop premium, eco-friendly solutions that merge sustainability with modern lifestyles.',
                  icon: Icons.eco_rounded,
                  accentColor: AppTheme.primary,
                ),
                const SizedBox(height: AppTheme.spacingM),
                _buildModernInfoCard(
                  context,
                  title: 'Our Story',
                  content:
                      'Founded to bridge the gap between education and industry, Zygreen empowers students and professionals in life sciences. We are a dynamic team delivering high-quality educational experiences.',
                  icon: Icons.history_edu_rounded,
                  accentColor: AppTheme.secondary,
                ),

                const SizedBox(height: AppTheme.spacingXL),

                

                const SizedBox(height: AppTheme.spacingXL),

                // Contact Section
                _buildSectionHeader(context, 'Get in Touch'),
                const SizedBox(height: AppTheme.spacingM),
                Container(
                  padding: const EdgeInsets.all(AppTheme.spacingM),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(AppTheme.radiusL),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _buildContactTile(
                        context,
                        Icons.email_outlined,
                        'Email Us',
                        'zygreeninnovations@gmail.com',
                        () {},
                      ),
                      const Divider(height: 30),
                      _buildContactTile(
                        context,
                        Icons.phone_outlined,
                        'Call Us',
                        '+91 9495501806',
                        () {},
                      ),
                      const Divider(height: 30),
                      _buildContactTile(
                        context,
                        Icons.location_on_outlined,
                        'Visit Us',
                        'Pathanamthitta, Kerala, India',
                        () {},
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppTheme.spacingXL),
                
                // Footer
                Center(
                  child: Column(
                    children: [
                      Image.asset('assets/images/logo.png', height: 40, width: 40, color: Colors.grey.shade400),
                      const SizedBox(height: 8),
                      Text(
                        'Version 1.0.0',
                        style: textTheme.bodySmall?.copyWith(color: Colors.grey.shade400),
                      ),
                    ],
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

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 280.0,
      pinned: true,
      stretch: true,
      backgroundColor: AppTheme.surface,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.parallax,
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Decorative Gradient Background
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppTheme.primary.withValues(alpha: 0.15),
                    AppTheme.background,
                  ],
                ),
              ),
            ),
            // Decorative Circles
            Positioned(
              top: -50,
              right: -50,
              child: CircleAvatar(
                radius: 100,
                backgroundColor: AppTheme.primary.withValues(alpha: 0.05),
              ),
            ),
            Positioned(
              top: 100,
              left: -30,
              child: CircleAvatar(
                radius: 60,
                backgroundColor: AppTheme.secondary.withValues(alpha: 0.05),
              ),
            ),
            // Content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 40), // Offset for status bar
                  Container(
                    width: 110,
                    height: 110,
                    padding: const EdgeInsets.all(AppTheme.spacingS),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primary.withValues(alpha: 0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/logo.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingL),
                  const Text(
                    'Sustainable Future',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Where Innovation meets Nature',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
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
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
        ),
      ],
    );
  }

  Widget _buildModernInfoCard(
    BuildContext context, {
    required String title,
    required String content,
    required IconData icon,
    required Color accentColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusL),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
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
                    color: accentColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: accentColor, size: 24),
                ),
                const SizedBox(width: AppTheme.spacingM),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingM),
            Text(
              content,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                    height: 1.6,
                  ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildContactTile(BuildContext context, IconData icon, String title,
      String subtitle, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppTheme.textPrimary, size: 22),
          ),
          const SizedBox(width: AppTheme.spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 15,
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios_rounded,
              size: 16, color: Colors.grey.shade300),
        ],
      ),
    );
  }
}