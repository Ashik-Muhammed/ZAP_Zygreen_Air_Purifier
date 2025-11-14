import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zygreen_air_purifier/models/air_quality_data.dart';
import 'package:zygreen_air_purifier/services/air_quality_forecast.dart';

class AirQualityProvider with ChangeNotifier {
  final AirQualityForecast _forecastService = AirQualityForecast();
  static const String _storageKey = 'air_quality_history';
  
  List<AirQualityData> _historicalData = [];
  List<AirQualityData> _forecastData = [];
  bool _isLoading = false;
  String? _error;
  
  AirQualityProvider() {
    _loadHistoricalData();
  }
  
  // Getters
  List<AirQualityData> get historicalData => _historicalData;
  List<AirQualityData> get forecastData => _forecastData;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // Load historical data from local storage
  Future<void> _loadHistoricalData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_storageKey);
      
      if (jsonString != null) {
        final List<dynamic> jsonList = jsonDecode(jsonString);
        _historicalData = jsonList
            .map((item) => AirQualityData.fromJson(Map<String, dynamic>.from(item)))
            .toList();
        _generateForecast();
      }
    } catch (e) {
      debugPrint('Error loading historical data: $e');
    }
  }
  
  // Save historical data to local storage
  Future<void> _saveHistoricalData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = _historicalData.map((data) => data.toJson()).toList();
      await prefs.setString(_storageKey, jsonEncode(jsonList));
    } catch (e) {
      debugPrint('Error saving historical data: $e');
    }
  }
  
  // Add new data point and save to storage
  Future<void> addDataPoint(AirQualityData newData) async {
    _historicalData.add(newData);
    
    // Keep only the last 7 days of data to prevent storage bloat
    final weekAgo = DateTime.now().subtract(const Duration(days: 7));
    _historicalData.removeWhere((data) => data.timestamp.isBefore(weekAgo));
    
    await _saveHistoricalData();
    await _generateForecast();
  }
  
  // Update historical data and generate forecast
  Future<void> updateData(List<AirQualityData> newData) async {
    if (listEquals(_historicalData, newData)) return;
    
    _historicalData = newData;
    await _saveHistoricalData();
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    await _generateForecast();
  }
  
  // Generate forecast based on historical data
  Future<void> _generateForecast() async {
    try {
      if (_historicalData.length >= 3) {
        // Use combined prediction if we have enough data
        _forecastData = _forecastService.predictCombined(_historicalData);
      } else if (_historicalData.isNotEmpty) {
        // Use simple prediction for small datasets
        _forecastData = _forecastService.predictSimpleMovingAverage(_historicalData);
      } else {
        _forecastData = [];
      }
    } catch (e) {
      _error = 'Failed to generate forecast: $e';
      _forecastData = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Get trend direction (-1 to 1)
  double getTrendDirection() {
    if (_historicalData.length < 2) return 0;
    return _forecastService.getTrendDirection(_historicalData);
  }
  
  // Get air quality status based on current data
  String? getCurrentStatus() {
    if (_historicalData.isEmpty) return null;
    return _historicalData.last.status;
  }
  
  // Get forecast summary
  String? getForecastSummary() {
    if (_forecastData.isEmpty || _historicalData.isEmpty) return null;
    
    final currentAqi = _historicalData.last.aqi;
    final forecastAqi = _forecastData.last.aqi;
    
    if (currentAqi == null || forecastAqi == null) return null;
    
    final difference = forecastAqi - currentAqi;
    
    if (difference < -10) {
      return 'Significant improvement expected';
    } else if (difference < 0) {
      return 'Slight improvement expected';
    } else if (difference < 10) {
      return 'Air quality will remain stable';
    } else if (difference < 30) {
      return 'Slight deterioration expected';
    } else {
      return 'Significant deterioration expected';
    }
  }
}
