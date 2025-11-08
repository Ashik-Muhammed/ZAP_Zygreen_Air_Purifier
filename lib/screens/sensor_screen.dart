import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zygreen_air_purifier/providers/sensor_provider.dart';
import 'package:zygreen_air_purifier/widgets/sensor_display.dart';

class SensorScreen extends StatelessWidget {
  const SensorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Air Quality Monitor'),
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: Theme.of(context).primaryColor,
      ),
      body: const SensorDisplay(),
      floatingActionButton: Builder(
        builder: (context) => FloatingActionButton(
          onPressed: () {
            // Refresh data
            final sensorProvider = Provider.of<SensorProvider>(context, listen: false);
            sensorProvider.refreshSensorData();
          },
          child: const Icon(Icons.refresh),
        ),
      ),
    );
  }
}
