import 'package:flutter/material.dart';
import 'package:zygreen_air_purifier/theme/app_theme.dart';

class ContactUsScreen extends StatelessWidget {
  const ContactUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 50.0,
            floating: true,
            pinned: true,
            backgroundColor: AppTheme.primary,
            elevation: 0,
            title: const Text(
              'Contact Us',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppTheme.primary,
                      AppTheme.primary.withValues(alpha: 0.8),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Get in Touch',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'We\'d love to hear from you. Reach out to us through any of these channels.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                         const SizedBox(height: 20),
                                    _buildContactCard(
                    context,
                    title: 'Our Website',
                    subtitle: 'zygreen.in',
                    description: 'Visit our website for more information',
                    icon: Icons.location_on_rounded,
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 32),
                  _buildContactCard(
                    context,
                    title: 'Email Us',
                    subtitle: 'zygreeninnovations@gmail.com',
                    description: 'Response within 24 hours',
                    icon: Icons.email_rounded,
                    color: Colors.redAccent,
                  ),
                  const SizedBox(height: 20),
                  _buildContactCard(
                    context,
                    title: 'Call Us',
                    subtitle: '+91 9495501806',
                    description: 'Mon - Sat, 9am - 6pm',
                    icon: Icons.phone_rounded,
                    color: Colors.green,
                  ),
                  const SizedBox(height: 20),
                  _buildContactCard(
                    context,
                    title: 'Visit Us',
                    subtitle: 'Pathanamthitta',
                    description: 'Kerala, India',
                    icon: Icons.location_on_rounded,
                    color: Colors.blue,
                  ),
           
                  const SizedBox(height: 20),
                  
                  
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String description,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
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

}