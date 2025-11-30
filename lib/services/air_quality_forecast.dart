import 'dart:math';
import 'package:zygreen_air_purifier/models/air_quality_data.dart';

class AirQualityForecast {
  static const int predictionSteps = 6;
  final Random _rand = Random();

  // Convert AQI to PM2.5 (using EPA's formula)
  double _aqiToPm25(double aqi) {
    if (aqi <= 50) return (aqi / 50.0) * 12.0;
    if (aqi <= 100) return ((aqi - 50) / 50.0) * (35.4 - 12.1) + 12.1;
    if (aqi <= 150) return ((aqi - 100) / 50.0) * (55.4 - 35.5) + 35.5;
    if (aqi <= 200) return ((aqi - 150) / 50.0) * (150.4 - 55.5) + 55.5;
    if (aqi <= 300) return ((aqi - 200) / 100.0) * (250.4 - 150.5) + 150.5;
    if (aqi <= 400) return ((aqi - 300) / 100.0) * (350.4 - 250.5) + 250.5;
    return ((aqi - 400) / 100.0) * (500.4 - 350.5) + 350.5;
  }

  List<AirQualityData> generateForecast(List<AirQualityData> history) {
  if (history.isEmpty) return [];

  final last = history.last;
  final double currentAqi = (last.aqi ?? 0.0).toDouble();

  List<AirQualityData> predictions = [];

  for (int i = 1; i <= predictionSteps; i++) {
    // Generate a random change between 20 and 60 points
    final double change = 20.0 + (_rand.nextDouble() * 40.0);
    
    // Randomly choose to add or subtract the change
    final bool shouldIncrease = _rand.nextBool();
    
    // Calculate new AQI within ±20 to ±60 of the current AQI
    double predictedAqi = shouldIncrease 
        ? (currentAqi + change).clamp(0.0, 500.0)
        : (currentAqi - change).clamp(0.0, 500.0);
    
    // Ensure the change is at least 20 points and at most 60 points
    final double actualChange = (predictedAqi - currentAqi).abs();
    if (actualChange < 20.0) {
      predictedAqi = shouldIncrease 
          ? (currentAqi + 20.0).clamp(0.0, 500.0)
          : (currentAqi - 20.0).clamp(0.0, 500.0);
    } else if (actualChange > 60.0) {
      predictedAqi = shouldIncrease
          ? (currentAqi + 60.0).clamp(0.0, 500.0)
          : (currentAqi - 60.0).clamp(0.0, 500.0);
    }

    // Convert AQI to PM2.5 before storing
    double predictedPm25 = _aqiToPm25(predictedAqi);

    predictions.add(
      AirQualityData(
        timestamp: last.timestamp.add(Duration(hours: i)),
        pm25: predictedPm25,
        isPrediction: true,
        confidence: 0.8,
      ),
    );
  }

  return predictions;
} 
}