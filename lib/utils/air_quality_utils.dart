class AirQualityUtils {
  // Humidity thresholds (%)
  static const double minSafeHumidity = 30.0;
  static const double maxSafeHumidity = 50.0;
  static const double minModerateHumidity = 50.0;
  static const double maxModerateHumidity = 60.0;
  static const double minBadHumidity = 0.0;
  static const double maxBadHumidity = 100.0;

  // PM2.5 thresholds (µg/m³)
  static const double maxSafePm25 = 15.0;
  static const double maxModeratePm25 = 35.0;

  // PM10 thresholds (µg/m³)
  static const double maxSafePm10 = 45.0;
  static const double maxModeratePm10 = 50.0;

  // TVOC thresholds (mg/m³)
  static const double maxSafeTvoc = 0.3;
  static const double maxModerateTvoc = 0.5;

  // CO2 thresholds (ppm)
  static const double minSafeCo2 = 350.0;
  static const double maxSafeCo2 = 1000.0;
  static const double maxModerateCo2 = 1500.0;

  static String checkHumidityStatus(double value) {
    if (value >= minSafeHumidity && value <= maxSafeHumidity) {
      return 'Safe';
    } else if ((value > maxSafeHumidity && value <= maxModerateHumidity) ||
        (value >= minModerateHumidity - 5 && value < minSafeHumidity)) {
      return 'Moderate';
    } else {
      return 'Bad';
    }
  }

  static String checkPm25Status(double value) {
    if (value <= maxSafePm25) return 'Safe';
    if (value <= maxModeratePm25) return 'Moderate';
    return 'Bad';
  }

  static String checkPm10Status(double value) {
    if (value < maxSafePm10) return 'Safe';
    if (value <= maxModeratePm10) return 'Moderate';
    return 'Bad';
  }

  static String checkTvocStatus(double value) {
    if (value < maxSafeTvoc) return 'Safe';
    if (value <= maxModerateTvoc) return 'Moderate';
    return 'Bad';
  }

  static String checkCo2Status(double value) {
    if (value >= minSafeCo2 && value <= maxSafeCo2) return 'Safe';
    if (value <= maxModerateCo2) return 'Moderate';
    return 'Bad';
  }

  static String generateAlert({
    required double humidity,
    required double pm25,
    required double pm10,
    required double tvoc,
    required double co2,
  }) {
    final alerts = <String>[];

    // Check each parameter and add alerts for unsafe levels
    final humidityStatus = checkHumidityStatus(humidity);
    if (humidityStatus != 'Safe') {
      alerts.add('Humidity is $humidity% ($humidityStatus)');
    }

    final pm25Status = checkPm25Status(pm25);
    if (pm25Status != 'Safe') {
      alerts.add('PM2.5 is ${pm25.toStringAsFixed(1)} µg/m³ ($pm25Status)');
    }

    final pm10Status = checkPm10Status(pm10);
    if (pm10Status != 'Safe') {
      alerts.add('PM10 is ${pm10.toStringAsFixed(1)} µg/m³ ($pm10Status)');
    }

    final tvocStatus = checkTvocStatus(tvoc);
    if (tvocStatus != 'Safe') {
      alerts.add('TVOC is ${tvoc.toStringAsFixed(2)} mg/m³ ($tvocStatus)');
    }

    final co2Status = checkCo2Status(co2);
    if (co2Status != 'Safe') {
      alerts.add('CO₂ is ${co2.toInt()} ppm ($co2Status)');
    }

    if (alerts.isEmpty) {
      return 'All air quality parameters are within safe limits';
    }

    return alerts.join('\n');
  }

  static bool isAirQualityCritical({
    required double humidity,
    required double pm25,
    required double pm10,
    required double tvoc,
    required double co2,
  }) {
    return checkHumidityStatus(humidity) == 'Bad' ||
        checkPm25Status(pm25) == 'Bad' ||
        checkPm10Status(pm10) == 'Bad' ||
        checkTvocStatus(tvoc) == 'Bad' ||
        checkCo2Status(co2) == 'Bad';
  }
}
