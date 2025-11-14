import 'dart:math';

import 'package:zygreen_air_purifier/models/air_quality_data.dart';

class AirQualityForecast {
  static const int predictionSteps = 6; // Predict next 6 hours
  
  // Simple moving average prediction
  List<AirQualityData> predictSimpleMovingAverage(List<AirQualityData> historicalData, {int steps = 6}) {
    if (historicalData.isEmpty) return [];
    
    final predictions = <AirQualityData>[];
    final window = historicalData.length > 5 ? 5 : historicalData.length;
    final lastData = historicalData.last;
    
    for (var i = 1; i <= steps; i++) {
      // Calculate weighted average with more weight on recent data
      double weightedSumPm25 = 0;
      double weightedSumPm10 = 0;
      double weightedSumCo2 = 0;
      double weightedSumVoc = 0;
      double weightSum = 0;
      
      for (var j = 0; j < window; j++) {
        final weight = (j + 1) / window; // Linear weight increase
        final data = historicalData[historicalData.length - window + j];
        
        weightedSumPm25 += (data.pm25 ?? 0) * weight;
        weightedSumPm10 += (data.pm10 ?? 0) * weight;
        weightedSumCo2 += (data.co2 ?? 0) * weight;
        weightedSumVoc += (data.voc ?? 0) * weight;
        weightSum += weight;
      }
      
      // Add some randomness to simulate real-world variations
      // Consider: pass Random instance as parameter or make predictions deterministic
      const randomFactor = 1.0; // Or remove if not needed
      
      predictions.add(AirQualityData(
        timestamp: lastData.timestamp.add(Duration(hours: i)),
        pm25: (weightedSumPm25 / weightSum) * randomFactor,
        pm10: (weightedSumPm10 / weightSum) * randomFactor,
        co2: (weightedSumCo2 / weightSum) * randomFactor,
        voc: (weightedSumVoc / weightSum) * randomFactor,
        isPrediction: true,
      ));
    }
    
    return predictions;
  }
  
  // Exponential smoothing prediction
  List<AirQualityData> predictExponentialSmoothing(List<AirQualityData> historicalData, {int steps = 6, double alpha = 0.3}) {
    if (historicalData.isEmpty) return [];
    
    final predictions = <AirQualityData>[];
    var lastPm25 = historicalData.last.pm25 ?? 0;
    var lastPm10 = historicalData.last.pm10 ?? 0;
    var lastCo2 = historicalData.last.co2 ?? 0;
    var lastVoc = historicalData.last.voc ?? 0;
    
    // Calculate initial level and trend
    double levelPm25 = lastPm25;
    double levelPm10 = lastPm10;
    double levelCo2 = lastCo2;
    double levelVoc = lastVoc;
    
    if (historicalData.length > 1) {
      levelPm25 = historicalData[historicalData.length - 2].pm25 ?? levelPm25;
      levelPm10 = historicalData[historicalData.length - 2].pm10 ?? levelPm10;
      levelCo2 = historicalData[historicalData.length - 2].co2 ?? levelCo2;
      levelVoc = historicalData[historicalData.length - 2].voc ?? levelVoc;
    }
    
    // Calculate trend (difference between last two points)
    double trendPm25 = lastPm25 - levelPm25;
    double trendPm10 = lastPm10 - levelPm10;
    double trendCo2 = lastCo2 - levelCo2;
    double trendVoc = lastVoc - levelVoc;
    
    // Generate predictions
    for (var i = 1; i <= steps; i++) {
      final randomFactor = 0.97 + Random().nextDouble() * 0.06; // 0.97 to 1.03
      
      predictions.add(AirQualityData(
        timestamp: historicalData.last.timestamp.add(Duration(hours: i)),
        pm25: (lastPm25 + trendPm25 * i) * randomFactor,
        pm10: (lastPm10 + trendPm10 * i) * randomFactor,
        co2: (lastCo2 + trendCo2 * i) * randomFactor,
        voc: (lastVoc + trendVoc * i) * randomFactor,
        isPrediction: true,
      ));
    }
    
    return predictions;
  }
  
  // Combined prediction using multiple methods
  List<AirQualityData> predictCombined(List<AirQualityData> historicalData, {int steps = 6}) {
    if (historicalData.length < 3) {
      return predictSimpleMovingAverage(historicalData, steps: steps);
    }
    
    final simple = predictSimpleMovingAverage(historicalData, steps: steps);
    final expSmoothing = predictExponentialSmoothing(historicalData, steps: steps);
    
    // Combine predictions with weights
    return List.generate(steps, (index) {
      final timestamp = historicalData.last.timestamp.add(Duration(hours: index + 1));
      
      // Weighted average of both methods
      const weight = 0.5; // Equal weight for now
      
      return AirQualityData(
        timestamp: timestamp,
        pm25: _weightedAverage([simple[index].pm25, expSmoothing[index].pm25], [weight, 1 - weight]),
        pm10: _weightedAverage([simple[index].pm10, expSmoothing[index].pm10], [weight, 1 - weight]),
        co2: _weightedAverage([simple[index].co2, expSmoothing[index].co2], [weight, 1 - weight]),
        voc: _weightedAverage([simple[index].voc, expSmoothing[index].voc], [weight, 1 - weight]),
        isPrediction: true,
      );
    });
  }
  
  double _weightedAverage(List<double?> values, List<double> weights) {
    double sum = 0;
    double weightSum = 0;
    
    for (var i = 0; i < values.length; i++) {
      if (values[i] != null) {
        sum += values[i]! * weights[i];
        weightSum += weights[i];
      }
    }
    
    return weightSum > 0 ? sum / weightSum : 0;
  }
  
  // Get trend direction based on recent data
  double getTrendDirection(List<AirQualityData> recentData, {int window = 3}) {
    if (recentData.length < 2) return 0;
    
    final start = recentData.length > window ? recentData.length - window : 0;
    final end = recentData.length - 1;
    
    if (start >= end) return 0;
    
    // Calculate average of first and last window values
    double startAvg = 0;
    double endAvg = 0;
    int count = 0;
    
    for (var i = 0; i <= end - start; i++) {
      final data = recentData[start + i];
      if (data.pm25 != null) {
        if (i < window) {
          startAvg += data.pm25!;
        } else {
          endAvg += data.pm25!;
        }
        count++;
      }
    }
    
    if (count == 0) return 0;
    
    // Normalize to -1 (decreasing) to 1 (increasing)
    final trend = (endAvg - startAvg) / (window * 50); // Normalize by a factor
    return trend.clamp(-1.0, 1.0);
  }
}
