import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zygreen_air_purifier/providers/sensor_provider.dart';
import 'package:intl/intl.dart';

class SensorDisplay extends StatefulWidget {
  const SensorDisplay({super.key});

  @override
  State<SensorDisplay> createState() => _SensorDisplayState();
}

class _SensorDisplayState extends State<SensorDisplay> {
  @override
  void initState() {
    super.initState();
    // Initialize sensor data when the widget is first created
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final sensorProvider = context.read<SensorProvider>();
      sensorProvider.initSensorData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SensorProvider>(
      builder: (context, sensorProvider, _) {
        if (sensorProvider.isLoading && sensorProvider.timestamp == 0) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Loading sensor data...'),
              ],
            ),
          );
        }

        if (sensorProvider.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 16),
                Text(
                  sensorProvider.error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: sensorProvider.refreshSensorData,
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        final lastUpdated = sensorProvider.timestamp > 0
            ? DateFormat('MMM d, y - hh:mm a').format(
                DateTime.fromMillisecondsSinceEpoch(sensorProvider.timestamp))
            : 'Never';

        return RefreshIndicator(
          onRefresh: () => sensorProvider.refreshSensorData(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Sensor Data',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Last updated: $lastUpdated',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 16),
                _buildSensorCard(
                  context,
                  'Temperature',
                  '${sensorProvider.temperature.toStringAsFixed(1)}°C',
                  Icons.thermostat,
                  Colors.red,
                ),
                const SizedBox(height: 12),
                _buildSensorCard(
                  context,
                  'Humidity',
                  '${sensorProvider.humidity.toStringAsFixed(1)}%',
                  Icons.water_drop,
                  Colors.blue,
                ),
                const SizedBox(height: 12),
                _buildSensorCard(
                  context,
                  'Air Quality',
                  '${sensorProvider.airQuality} PPM',
                  Icons.air,
                  _getAirQualityColor(sensorProvider.airQuality),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSensorCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
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

  Color _getAirQualityColor(int airQuality) {
    if (airQuality < 30) return Colors.green;
    if (airQuality < 70) return Colors.orange;
    return Colors.red;
  }
}
