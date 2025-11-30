import 'package:flutter/material.dart';
import 'package:zygreen_air_purifier/utils/air_quality_utils.dart';

enum AlertLevel {
  info,
  warning,
  critical,
}

class AirQualityAlert {
  final String id;
  final String title;
  final String message;
  final DateTime timestamp;
  final AlertLevel level;
  bool isRead;

  AirQualityAlert({
    String? id,
    required this.title,
    required this.message,
    DateTime? timestamp,
    required this.level,
    this.isRead = false,
  })  : id = id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        timestamp = timestamp ?? DateTime.now();

  Color get color {
    switch (level) {
      case AlertLevel.critical:
        return Colors.red;
      case AlertLevel.warning:
        return Colors.orange;
      case AlertLevel.info:
        return Colors.blue;
    }
  }

  IconData get icon {
    switch (level) {
      case AlertLevel.critical:
        return Icons.error_outline;
      case AlertLevel.warning:
        return Icons.warning_amber_rounded;
      case AlertLevel.info:
        return Icons.info_outline;
    }
  }

  factory AirQualityAlert.fromAirQualityData({
    required double humidity,
    required double pm25,
    required double pm10,
    required double tvoc,
    required double co2,
  }) {
    final alerts = <String>[];
    AlertLevel maxLevel = AlertLevel.info;

    // Check each parameter
    final humidityStatus = AirQualityUtils.checkHumidityStatus(humidity);
    if (humidityStatus != 'Safe') {
      final level = humidityStatus == 'Bad' ? AlertLevel.critical : AlertLevel.warning;
      maxLevel = _getHigherLevel(maxLevel, level);
      alerts.add('Humidity: $humidity% ($humidityStatus)');
    }

    final pm25Status = AirQualityUtils.checkPm25Status(pm25);
    if (pm25Status != 'Safe') {
      final level = pm25Status == 'Bad' ? AlertLevel.critical : AlertLevel.warning;
      maxLevel = _getHigherLevel(maxLevel, level);
      alerts.add('PM2.5: ${pm25.toStringAsFixed(1)} µg/m³ ($pm25Status)');
    }

    final pm10Status = AirQualityUtils.checkPm10Status(pm10);
    if (pm10Status != 'Safe') {
      final level = pm10Status == 'Bad' ? AlertLevel.critical : AlertLevel.warning;
      maxLevel = _getHigherLevel(maxLevel, level);
      alerts.add('PM10: ${pm10.toStringAsFixed(1)} µg/m³ ($pm10Status)');
    }

    final tvocStatus = AirQualityUtils.checkTvocStatus(tvoc);
    if (tvocStatus != 'Safe') {
      final level = tvocStatus == 'Bad' ? AlertLevel.critical : AlertLevel.warning;
      maxLevel = _getHigherLevel(maxLevel, level);
      alerts.add('TVOC: ${tvoc.toStringAsFixed(2)} mg/m³ ($tvocStatus)');
    }

    final co2Status = AirQualityUtils.checkCo2Status(co2);
    if (co2Status != 'Safe') {
      final level = co2Status == 'Bad' ? AlertLevel.critical : AlertLevel.warning;
      maxLevel = _getHigherLevel(maxLevel, level);
      alerts.add('CO₂: ${co2.toInt()} ppm ($co2Status)');
    }

    final title = _getAlertTitle(maxLevel);
    final message = alerts.join('\n');

    return AirQualityAlert(
      title: title,
      message: message,
      level: maxLevel,
    );
  }

  static AlertLevel _getHigherLevel(AlertLevel a, AlertLevel b) {
    return a.index > b.index ? a : b;
  }

  static String _getAlertTitle(AlertLevel level) {
    switch (level) {
      case AlertLevel.critical:
        return 'Critical Air Quality Alert';
      case AlertLevel.warning:
        return 'Air Quality Warning';
      case AlertLevel.info:
        return 'Air Quality Update';
    }
  }
}
