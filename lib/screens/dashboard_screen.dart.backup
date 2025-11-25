// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zygreen_air_purifier/theme/app_theme.dart';
import 'package:zygreen_air_purifier/providers/sensor_provider.dart';
import 'package:zygreen_air_purifier/screens/air_quality_trend_screen.dart';
import 'package:zygreen_air_purifier/screens/connect_device_screen.dart';
import 'package:zygreen_air_purifier/providers/esp32_provider.dart';
import 'package:zygreen_air_purifier/providers/air_quality_provider.dart';
import 'package:zygreen_air_purifier/widgets/air_quality_forecast_card.dart';
import 'package:zygreen_air_purifier/models/air_quality_data.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _isConnected = false;
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;
  
  // Track previous sensor values to avoid unnecessary updates
  double? _lastPm25;
  double? _lastPm10;
  double? _lastTemperature;
  double? _lastHumidity;
  
  // Store the cleanup function for the sensor listener
  VoidCallback? _disposeListener;

  late Animation<double> _pulseAnimation;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
    _checkConnectivity();

    // Listen to connectivity changes
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((result) {
      if (!mounted) return;
      setState(() {
        _isConnected = result != ConnectivityResult.none;
      });
      if (_isConnected) {
        _initializeData();
      }
    });
    
    // Set up the sensor listener after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final sensorProvider = context.read<SensorProvider>();
      final airQualityProvider = context.read<AirQualityProvider>();
      Timer? debounceTimer;
      const debounceDuration = Duration(seconds: 5);

      void listener() {
        if (!mounted) return;
        
        // Only proceed if we have meaningful changes
        if (_lastPm25 != sensorProvider.pm25 ||
            _lastPm10 != sensorProvider.pm10 ||
            _lastTemperature != sensorProvider.temperature ||
            _lastHumidity != sensorProvider.humidity) {
              
          // Update the last values
          _lastPm25 = sensorProvider.pm25;
          _lastPm10 = sensorProvider.pm10;
          _lastTemperature = sensorProvider.temperature;
          _lastHumidity = sensorProvider.humidity;
          
          // Cancel any pending updates
          debounceTimer?.cancel();
          
          // Schedule the update with debouncing
          debounceTimer = Timer(debounceDuration, () {
            if (!mounted) return;
            
            final airQualityData = AirQualityData(
              timestamp: DateTime.now(),
              pm25: sensorProvider.pm25,
              pm10: sensorProvider.pm10,
              co2: sensorProvider.temperature * 100, // Scale temperature for demo
              voc: sensorProvider.humidity * 10, // Scale humidity for demo
            );
            
            airQualityProvider.addDataPoint(airQualityData);
          });
        }
      }

      // Add the listener
      sensorProvider.addListener(listener);
      
      // Store the cleanup function
      _disposeListener = () {
        debounceTimer?.cancel();
        sensorProvider.removeListener(listener);
      };
    });
  }
  
  

  Future<void> _checkConnectivity() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    if (!mounted) return;
    setState(() {
      _isConnected = connectivityResult != ConnectivityResult.none;
    });
    if (_isConnected) {
      _initializeData();
    }
  }

  Future<void> _initializeData() async {
    if (!mounted) return;
    final sensorProvider = context.read<SensorProvider>();
    await sensorProvider.initSensorData();
    if (!mounted) return;
  }

  @override
  void dispose() {
    // Cancel and clean up all resources
    _connectivitySubscription?.cancel();
    _disposeListener?.call();
    _animationController.dispose();
    super.dispose();
  }

  Widget _buildAnimatedBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white,
            Colors.grey[50]!,
          ],
        ),
      ),
    );
  }

  Widget _buildNoInternetUI() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.signal_wifi_off_rounded,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No Internet Connection',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please check your internet connection and try again',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _checkConnectivity,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_isConnected) {
      return Scaffold(
        body: _buildNoInternetUI(),
      );
    }
    
    final theme = Theme.of(context);
    final esp32Provider = Provider.of<ESP32Provider>(context, listen: false);

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          _buildAnimatedBackground(),
          LayoutBuilder(
            builder: (context, constraints) {
              return Consumer2<SensorProvider, AirQualityProvider>(
                builder: (context, sensorProvider, airQualityProvider, _) {
                  if (sensorProvider.isLoading) {
                    return Center(
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.primary.withOpacity(0.2),
                                    blurRadius: 20,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: const CircularProgressIndicator(strokeWidth: 3),
                            ),
                            const SizedBox(height: 24),
                            const Text(
                              'Loading sensor data...',
                              style: TextStyle(fontSize: 16, color: Colors.black54, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  if (sensorProvider.error != null) {
                    return Center(
                      child: Container(
                        margin: const EdgeInsets.all(32),
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.error_outline, color: Colors.red, size: 48),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'Connection Error',
                              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              sensorProvider.error!,
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey[600], fontSize: 14),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton.icon(
                              onPressed: sensorProvider.refreshSensorData,
                              icon: const Icon(Icons.refresh),
                              label: const Text('Retry Connection'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  // Check if device is connected
                  final isConnected = esp32Provider.isConnected && 
                                     esp32Provider.connectedDeviceId != null &&
                                     sensorProvider.deviceId != null && 
                                     sensorProvider.error == null;
                  
                  if (!isConnected) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.2),
                                    blurRadius: 15,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.devices_other_outlined,
                                size: 60,
                                color: Colors.blueGrey,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'No Device Connected',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Connect a device to monitor air quality and view real-time data',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: Colors.grey[600],
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 32),
                            ElevatedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const ConnectDeviceScreen(),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.add, size: 20),
                              label: const Text('Connect Device'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  
                  // Show dashboard only when device is connected
                  return RefreshIndicator(
                    onRefresh: () async {
                      await sensorProvider.refreshSensorData();
                    },
                    color: AppTheme.primary,
                    child: CustomScrollView(
                      physics: const BouncingScrollPhysics(),
                      slivers: [
                        _buildModernAppBar(theme, sensorProvider),
                        SliverToBoxAdapter(
                          child: FadeTransition(
                            opacity: _fadeAnimation,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildDeviceStatusCard(theme, sensorProvider),
                                  const SizedBox(height: 12),
                                  _buildHeroAQICard(sensorProvider),
                                  const SizedBox(height: 12),
                                  _buildMetricsGrid(context, theme),
                                  const SizedBox(height: 12),
                                  _buildRecommendationsSection(theme, sensorProvider),
                                  const SizedBox(height: 24),
                                  if (airQualityProvider.historicalData.isNotEmpty || 
                                      airQualityProvider.forecastData.isNotEmpty)
                                    AirQualityForecastCard(
                                      historicalData: airQualityProvider.historicalData,
                                      forecastData: airQualityProvider.forecastData,
                                      isLoading: airQualityProvider.isLoading,
                                    ),
                                  const SizedBox(height: 70),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildModernAppBar(ThemeData theme, SensorProvider sensorProvider) {
    return SliverAppBar(
      expandedHeight: 110, // Reduced from 120 to 110
      floating: false,
      pinned: true,
      backgroundColor: const Color(0xFFF8F9FA),
      elevation: 0,
      flexibleSpace: LayoutBuilder(
        builder: (context, constraints) {
          return FlexibleSpaceBar(
            titlePadding: const EdgeInsets.only(left: 20, bottom: 8), // Reduced bottom padding
            title: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: constraints.maxHeight * 0.6, // Limit height to 60% of available space
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.bottomLeft,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dashboard',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                        fontSize: 24, // Explicit font size
                      ),
                    ),
                    const SizedBox(height: 2), // Reduced from 4 to 2
                    Text(
                      'Monitor your air quality',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.black45,
                        fontSize: 11, // Slightly smaller font
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      actions: [
        // Add Device Button with improved styling
        Container(
          margin: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppTheme.primary, AppTheme.primary.withOpacity(0.8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primary.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) => const ConnectDeviceScreen(),
                    transitionsBuilder: (context, animation, secondaryAnimation, child) {
                      const begin = Offset(0.0, 1.0);
                      const end = Offset.zero;
                      const curve = Curves.easeInOut;
                      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                      var offsetAnimation = animation.drive(tween);
                      return SlideTransition(position: offsetAnimation, child: child);
                    },
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add_circle_outline, color: Colors.white, size: 20),
                    SizedBox(width: 6),
                    Text(
                      'Add Device',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 4),
        Container(
          margin: const EdgeInsets.only(right: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
              ),
            ],
          ),
          child: IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.black87),
            onPressed: () {},
          ),
        ),
      ],
    );
  }

  Widget _buildDeviceStatusCard(ThemeData theme, SensorProvider sensorProvider) {
    final esp32Provider = context.watch<ESP32Provider>();
    // Check both ESP32 connection status and sensor provider's device ID
    final isConnected = esp32Provider.isConnected && 
                       esp32Provider.connectedDeviceId != null &&
                       sensorProvider.deviceId != null && 
                       sensorProvider.error == null;
    
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isConnected 
            ? [const Color(0xFF667EEA), const Color(0xFF764BA2)]
            : [Colors.grey[400]!, Colors.grey[600]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (isConnected ? const Color(0xFF667EEA) : Colors.grey[400]!).withOpacity(0.25),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isConnected ? Icons.check_circle : Icons.error_outline,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sensorProvider.deviceId ?? 'No Device',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isConnected ? 'Online & Monitoring' : 'Disconnected',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              if (isConnected && sensorProvider.timestamp > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: Colors.greenAccent,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        'Live',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          if (isConnected) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: () async {
                  // Store context in a local variable to use after async operations
                  final currentContext = context;
                  final messenger = ScaffoldMessenger.of(currentContext);
                  
                  // Show confirmation dialog
                  final confirmed = await showDialog<bool>(
                    context: currentContext,
                    builder: (dialogContext) => AlertDialog(
                      title: const Text('Disconnect Device'),
                      content: const Text('Are you sure you want to disconnect the current device?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(dialogContext).pop(false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(dialogContext).pop(true),
                          child: const Text('Disconnect'),
                        ),
                      ],
                    ),
                  );

                  if (confirmed == true) {
                    try {
                      // First clear the sensor data
                      await sensorProvider.clearDeviceData();
                      
                      // Then disconnect from the device
                      await esp32Provider.disconnect();
                      
                      if (!mounted) return;
                      
                      // Force a refresh of the sensor data to ensure UI updates
                      await sensorProvider.refreshSensorData();
                      
                      // Show success message
                      if (mounted) {
                        messenger.showSnackBar(
                          const SnackBar(content: Text('Device disconnected')),
                        );
                      }
                    } catch (e) {
                      if (mounted) {
                        messenger.showSnackBar(
                          SnackBar(content: Text('Error disconnecting: ${e.toString()}')),
                        );
                      }
                    }
                  }
                },
                icon: const Icon(Icons.link_off, color: Colors.white, size: 18),
                label: const Text(
                  'Disconnect Device',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.2),
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
List<Color> _getAqiGradient(double aqi) {
    if (aqi <= 50) return [const Color(0xFF00D9A5), const Color(0xFF00B4DB)];
    if (aqi <= 100) return [const Color(0xFF6C5CE7), const Color(0xFF9D7FEA)];
    if (aqi <= 150) return [const Color(0xFFFFA500), const Color(0xFFFF8C00)];
    if (aqi <= 200) return [const Color(0xFFFF6B9D), const Color(0xFFC86DD7)];
    if (aqi <= 300) return [const Color(0xFF8B5CF6), const Color(0xFF6C5CE7)];
    return [const Color(0xFFDC143C), const Color(0xFF8B0000)];
  }
  Widget _buildHeroAQICard(SensorProvider sensorProvider) {
    final aqi = sensorProvider.airQuality.toDouble();
    final color = _getAqiGradient(aqi);
    final status = _getAqiStatus(aqi);
    
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AirQualityTrendScreen()),
      ),
      child: Container(
        height: 280,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: color,
          ),
          boxShadow: [
            BoxShadow(
              color: color[0].withOpacity(0.4),
              blurRadius: 30,
              offset: const Offset(0, 15),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Animated background pattern
            ...List.generate(3, (index) {
              return Positioned(
                right: -50 + (index * 30),
                top: 50 + (index * 40),
                child: ScaleTransition(
                  scale: _pulseAnimation,
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.05),
                    ),
                  ),
                ),
              );
            }),
            Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Air Quality Index',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              status,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(Icons.air, color: Colors.white, size: 28),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        aqi.toStringAsFixed(0),
                        style: const TextStyle(
                          fontSize: 80,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          height: 1,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(
                          'AQI',
                          style: TextStyle(
                            fontSize: 24,
                            color: Colors.white.withOpacity(0.8),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(Icons.trending_up, color: Colors.white.withOpacity(0.8), size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'View detailed analytics',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      Icon(Icons.arrow_forward_ios, color: Colors.white.withOpacity(0.8), size: 16),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
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

  Widget _buildMetricsGrid(BuildContext context, ThemeData theme) {
    final sensorProvider = context.watch<SensorProvider>();
    final pm25 = sensorProvider.pm25;
    final pm10 = sensorProvider.pm10;
    final temp = sensorProvider.temperature;
    final humidity = sensorProvider.humidity;

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.1,
      children: [
        _buildMetricCard(
          context,
          theme: theme,
          title: 'PM2.5',
          value: pm25.toStringAsFixed(1),
          unit: 'µg/m³',
          icon: Icons.blur_circular,
          gradient: const [Color(0xFF667EEA), Color(0xFF764BA2)],
        ),
        _buildMetricCard(
          context,
          theme: theme,
          title: 'PM10',
          value: pm10.toStringAsFixed(1),
          unit: 'µg/m³',
          icon: Icons.grain,
          gradient: const [Color(0xFFF093FB), Color(0xFFF5576C)],
        ),
        _buildMetricCard(
          context,
          theme: theme,
          title: 'Temperature',
          value: temp.toStringAsFixed(1),
          unit: '°C',
          icon: Icons.thermostat_outlined,
          gradient: [_getTemperatureColor(temp), _getTemperatureColor(temp).withOpacity(0.7)],
        ),
        _buildMetricCard(
          context,
          theme: theme,
          title: 'Humidity',
          value: humidity.toStringAsFixed(1),
          unit: '%',
          icon: Icons.water_drop_outlined,
          gradient: [_getHumidityColor(humidity), _getHumidityColor(humidity).withOpacity(0.7)],
        ),
      ],
    );
  }

  Widget _buildMetricCard(
    BuildContext context, {
    required ThemeData theme,
    required String title,
    required String value,
    required String unit,
    required IconData icon,
    required List<Color> gradient,
  }) {
    return Container(
      height: 160, // Fixed height for consistency
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, gradient[0].withOpacity(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: gradient[0].withOpacity(0.15), width: 1.0),
        boxShadow: [
          BoxShadow(
            color: gradient[0].withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.black54,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: gradient),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    value,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: gradient[0],
                      height: 1,
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  unit,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey[500],
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getTemperatureColor(double temp) {
    if (temp < 18) return const Color(0xFF3B82F6);
    if (temp < 25) return const Color(0xFF10B981);
    if (temp < 30) return const Color(0xFFF97316);
    return const Color(0xFFEF4444);
  }

  Color _getHumidityColor(double humidity) {
    if (humidity < 30) return const Color(0xFFF97316);
    if (humidity < 60) return const Color(0xFF10B981);
    return const Color(0xFF3B82F6);
  }

  Widget _buildRecommendationsSection(ThemeData theme, SensorProvider sensorProvider) {
    final aqi = sensorProvider.airQuality.toDouble();
    final temp = sensorProvider.temperature;
    final humidity = sensorProvider.humidity;
    final pm25 = sensorProvider.pm25;
    final hour = DateTime.now().hour;
    final isDaytime = hour >= 6 && hour < 18;

    // More granular AQI categories
    final isGoodAir = aqi <= 50;
    final isModerate = aqi > 50 && aqi <= 100;
    final isUnhealthy = aqi > 150 && aqi <= 200;
    final isVeryUnhealthy = aqi > 200 && aqi <= 300;
    final isHazardous = aqi > 300;

    // Time-based greetings
    String greeting;
    if (hour < 12) {
      greeting = 'Good morning';
    } else if (hour < 17) {
      greeting = 'Good afternoon';
    } else {
      greeting = 'Good evening';
    }
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 15,
            offset: const Offset(0, 8),
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
                  color: theme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.lightbulb_outline, color: theme.primaryColor, size: 24),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$greeting!',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: theme.colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Smart Recommendations',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Air Quality Recommendation
          _buildRecommendationItem(
            'Air Quality',
            _getAirQualityRecommendation(aqi, isDaytime),
            _getAirQualityIcon(aqi),
            _getAirQualityColor(aqi),
            isUnhealthy || isVeryUnhealthy || isHazardous,
          ),
          const SizedBox(height: 12),
          
          // Ventilation Recommendation
          _buildRecommendationItem(
            'Ventilation',
            _getVentilationRecommendation(aqi, pm25, temp, humidity, isDaytime),
            _getVentilationIcon(aqi, isDaytime),
            _getVentilationColor(aqi),
            isGoodAir || isModerate,
          ),
          const SizedBox(height: 12),
          
          // Health Tips
          _buildRecommendationItem(
            'Health Tips',
            _getHealthTip(aqi, pm25, temp, humidity),
            Icons.health_and_safety_outlined,
            const Color(0xFF8B5CF6),
            isUnhealthy || isVeryUnhealthy || isHazardous,
          ),
        ],
      ),
    );
  }
  
  // Helper methods for recommendations
  String _getAirQualityRecommendation(double aqi, bool isDaytime) {
    if (aqi <= 50) {
      return 'Air quality is excellent! Perfect for outdoor activities.';
    } else if (aqi <= 100) {
      return 'Air quality is acceptable. Most people can enjoy normal activities.';
    } else if (aqi <= 150) {
      return 'Sensitive groups should reduce outdoor exertion.';
    } else if (aqi <= 200) {
      return 'Everyone may begin to experience health effects.';
    } else if (aqi <= 300) {
      return 'Health alert: Everyone may experience more serious health effects.';
    } else {
      return 'Health warning of emergency conditions. Avoid all physical activity outdoors.';
    }
  }

  String _getVentilationRecommendation(double aqi, double pm25, double temp, double humidity, bool isDaytime) {
    if (aqi > 100 || pm25 > 35) {
      return 'Keep windows closed and use air purifier.';
    } else if (temp > 30 && humidity > 70) {
      return 'Use air conditioning to reduce humidity and maintain comfort.';
    } else if (isDaytime && temp > 20 && temp < 28) {
      return 'Good time to open windows for ventilation.';
    } else {
      return 'Consider natural ventilation during cooler hours.';
    }
  }

  String _getHealthTip(double aqi, double pm25, double temp, double humidity) {
    if (aqi > 150) {
      return 'Wear N95 mask if going outside. Limit outdoor activities.';
    } else if (pm25 > 35) {
      return 'Consider using an air purifier. Keep windows closed.';
    } else if (temp > 30) {
      return 'Stay hydrated and avoid direct sun exposure.';
    } else if (humidity > 80) {
      return 'High humidity can promote mold growth. Use a dehumidifier if needed.';
    } else {
      return 'Ideal conditions for outdoor activities. Enjoy the fresh air!';
    }
  }

  IconData _getAirQualityIcon(double aqi) {
    if (aqi <= 50) return Icons.air_outlined;
    if (aqi <= 100) return Icons.air_outlined;
    if (aqi <= 150) return Icons.air_outlined;
    if (aqi <= 200) return Icons.air_outlined;
    return Icons.air_outlined;
  }

  IconData _getVentilationIcon(double aqi, bool isDaytime) {
    if (aqi > 100) return Icons.door_front_door;
    return isDaytime ? Icons.window : Icons.nightlight_round;
  }

  Color _getAirQualityColor(double aqi) {
    if (aqi <= 50) return const Color(0xFF10B981); // Green
    if (aqi <= 100) return const Color(0xFF3B82F6); // Blue
    if (aqi <= 150) return const Color(0xFFF59E0B); // Yellow
    if (aqi <= 200) return const Color(0xFFEF4444); // Red
    if (aqi <= 300) return const Color(0xFF8B5CF6); // Purple
    return const Color(0xFF7F1D1D); // Dark Red
  }

  Color _getVentilationColor(double aqi) {
    return aqi > 100 ? const Color(0xFFEF4444) : const Color(0xFF10B981);
  }

  Widget _buildRecommendationItem(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    bool isHighPriority,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.08), color.withOpacity(0.03)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isHighPriority ? color.withOpacity(0.3) : color.withOpacity(0.15),
          width: isHighPriority ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color, color.withOpacity(0.8)],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    if (isHighPriority) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          'Priority',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: color.withOpacity(0.5), size: 24),
        ],
      ),
    );
  }
}