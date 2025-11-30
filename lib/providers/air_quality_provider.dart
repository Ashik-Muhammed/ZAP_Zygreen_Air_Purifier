import 'dart:collection';
import 'dart:convert';
import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:collection/collection.dart';
import 'package:archive/archive.dart';
import 'package:zygreen_air_purifier/models/air_quality_data.dart';
import 'package:zygreen_air_purifier/services/air_quality_forecast.dart';

class AirQualityProvider with ChangeNotifier {
  late final AirQualityForecast _forecastService;
  static const int _minDataPointsForForecast = 3;
  // Removed unused field
  static const String _storageKey = 'air_quality_history';
  
  List<AirQualityData> _historicalData = [];
  List<AirQualityData> _forecastData = [];
  bool _isLoading = false;
  bool _isInitialized = false;
  String? _error;
  
  AirQualityProvider() {
    _forecastService = AirQualityForecast();
  }
  
  // Getters
  UnmodifiableListView<AirQualityData> get historicalData => UnmodifiableListView(_historicalData);
  UnmodifiableListView<AirQualityData> get forecastData => UnmodifiableListView(_forecastData);
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;
  String? get error => _error;
  
  /// Initialize the provider by loading historical data.
  /// Must be called before using the provider.
  Future<void> init() async {
    if (_isInitialized) return;
    
    _isLoading = true;
    notifyListeners();
    
    try {
      await _loadHistoricalData();
      _isInitialized = true;
    } catch (e) {
      _error = 'Failed to initialize AirQualityProvider: $e';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Load historical data from local storage with decompression
  Future<void> _loadHistoricalData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final compressedData = prefs.getString(_storageKey);
      
      if (compressedData != null) {
        // Decompress and decode the data
        final decodedData = _decompressData(compressedData);
        final List<dynamic> jsonList = jsonDecode(decodedData);
        
        // Convert JSON to AirQualityData objects
        _historicalData = jsonList
            .map((item) => AirQualityData.fromJson(Map<String, dynamic>.from(item)))
            .toList();
            
        // Generate and await forecast
        await _generateForecast();
      }
    } catch (e) {
      _error = 'Error loading historical data: $e';
      rethrow;
    }
  }
  
  // Compress and save historical data to local storage
  Future<void> _saveHistoricalData() async {
    if (_historicalData.isEmpty) return;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // 1. Apply sampling to reduce data points
      final sampledData = _sampleData(_historicalData);
      
      // 2. Convert to JSON
      final jsonList = sampledData.map((data) => data.toJson()).toList();
      final jsonString = jsonEncode(jsonList);
      
      // 3. Compress the data before saving
      final compressedData = _compressData(jsonString);
      
      // 4. Save to SharedPreferences
      await prefs.setString(_storageKey, compressedData);
    } catch (_) {    }
  }
  
  // Sample data to reduce storage - keep all data from last 24h, then sample older data
  List<AirQualityData> _sampleData(List<AirQualityData> data) {
    if (data.length < 144) return List.from(data); // Keep all if less than 1 day of data (assuming 10-min intervals)
    
    final now = DateTime.now();
    final oneDayAgo = now.subtract(const Duration(days: 1));
    
    // Keep all data from last 24 hours
    final recentData = data.where((d) => d.timestamp.isAfter(oneDayAgo)).toList();
    
    // For older data, keep only one point per hour
    final olderData = data.where((d) => !d.timestamp.isAfter(oneDayAgo)).toList();
    final sampledOlderData = <AirQualityData>[];
    
    if (olderData.isNotEmpty) {
      // Sort older data by timestamp to ensure chronological order
      olderData.sort((a, b) => a.timestamp.compareTo(b.timestamp));
      
      DateTime? lastKeptTime;
      
      for (final dataPoint in olderData) {
        if (lastKeptTime == null || 
            dataPoint.timestamp.difference(lastKeptTime).inHours >= 1) {
          sampledOlderData.add(dataPoint);
          lastKeptTime = dataPoint.timestamp;
        }
      }
    }
    
    // Combine and sort by timestamp
    final result = [...recentData, ...sampledOlderData]..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    
    return result;
  }
  
  // Simple compression using gzip
  String _compressData(String data) {
    try {
      final encoder = GZipEncoder();
      final compressed = encoder.encode(utf8.encode(data));
      if (compressed == null) {
        throw Exception('Compression failed');
      }
      return base64Encode(compressed);
    } catch (e) {
      return data; // Return original if compression fails
    }
  }
  
  // Decompress data
  String _decompressData(String compressedData) {
    try {
      final decoder = GZipDecoder();
      final decoded = base64Decode(compressedData);
      final decompressed = decoder.decodeBytes(decoded);
      return utf8.decode(decompressed);
    } catch (e) {
      // If decompression fails, try to use the data as is (for backward compatibility)
      return compressedData;
    }
  }
  
  // Add new data point and save to storage
  Future<void> addDataPoint(AirQualityData newData) async {
    // Don't add duplicate timestamps
    if (_historicalData.any((d) => d.timestamp.isAtSameMomentAs(newData.timestamp))) {
      return;
    }
    
    _historicalData.add(newData);
    
    // Keep only the last 7 days of data to prevent storage bloat
    final weekAgo = DateTime.now().subtract(const Duration(days: 7));
    _historicalData.removeWhere((data) => data.timestamp.isBefore(weekAgo));
    
    // Always save when adding new data points to prevent data loss
    await _saveHistoricalData();
    
    // Only update last save time if it's an auto-save
    if (_shouldSaveNewData()) {
      _lastSaveTime = DateTime.now();
    }
    
    await _generateForecast();
  }
  
  DateTime? _lastSaveTime;
  static const _minSaveInterval = Duration(minutes: 5);
  
  bool _shouldSaveNewData() {
    if (_lastSaveTime == null) {
      _lastSaveTime = DateTime.now();
      return true;
    }
    
    final now = DateTime.now();
    final timeSinceLastSave = now.difference(_lastSaveTime!);
    
    return timeSinceLastSave >= _minSaveInterval;
  }
  
  // Update historical data and generate forecast
  Future<void> updateData(List<AirQualityData> newData) async {
    if (!_isInitialized) {
      throw StateError('AirQualityProvider must be initialized before use. Call init() first.');
    }
    
    if (listEquals(_historicalData, newData)) return;
    
    try {
      // Update data and save
      _historicalData = List<AirQualityData>.from(newData);
      await _saveHistoricalData();
      
      // Generate forecast (will handle its own loading state)
      await _generateForecast();
    } catch (e) {
      _error = 'Failed to update data: $e';
      rethrow;
    }
  }
  
  // Generate forecast based on historical data
  Future<void> _generateForecast() async {
  if (_historicalData.length < _minDataPointsForForecast) {
    _forecastData = [];
    _isLoading = false;
    notifyListeners();
    return;
  }

  _isLoading = true;
  notifyListeners();

  try {
    _forecastData = _forecastService.generateForecast(_historicalData);
  } catch (e) {
    debugPrint('Error generating forecast: $e');
    _forecastData = []; // Clear forecast on error
  } finally {
    _isLoading = false;
    notifyListeners();
  }
}
  // Get trend analysis with direction and confidence
  Map<String, dynamic> getTrendAnalysis() {
    if (_historicalData.length < 2) {
      return {'direction': 0.0, 'confidence': 0.0, 'magnitude': 0.0};
    }
    
    // Use the last 6 data points for trend analysis
    final window = min(6, _historicalData.length);
    final recentData = _historicalData.sublist(_historicalData.length - window);
    
    // Calculate simple linear regression
    double sumX = 0, sumY = 0, sumXY = 0, sumX2 = 0;
    final n = recentData.length.toDouble();
    
    for (int i = 0; i < recentData.length; i++) {
      final x = i.toDouble();
      final y = recentData[i].pm25 ?? 0.0;
      sumX += x;
      sumY += y;
      sumXY += x * y;
      sumX2 += x * x;
    }
    
    final slope = (n * sumXY - sumX * sumY) / (n * sumX2 - sumX * sumX);
    
    // Calculate R² (coefficient of determination)
    double ssTotal = 0, ssResidual = 0;
    final meanY = sumY / n;
    
    for (int i = 0; i < recentData.length; i++) {
      final y = recentData[i].pm25 ?? 0.0;
      final yPred = slope * i + (sumY - slope * sumX) / n;
      ssTotal += (y - meanY) * (y - meanY);
      ssResidual += (y - yPred) * (y - yPred);
    }
    
    final rSquared = 1 - (ssResidual / (ssTotal == 0 ? 1 : ssTotal));
    
    return {
      'direction': slope,
      'confidence': rSquared.clamp(0.0, 1.0),
      'magnitude': slope.abs(),
    };
  }
  
  // Backward compatibility method
  double getTrendDirection() {
    return getTrendAnalysis()['direction'] ?? 0.0;
  }
  
  // Get air quality status based on current data
  String? getCurrentStatus() {
    if (_historicalData.isEmpty) return null;
    return _historicalData.last.status;
  }
  
  // Get forecast summary with confidence
  Map<String, dynamic> getForecastSummary() {
    if (_forecastData.isEmpty || _historicalData.isEmpty) {
      return {
        'summary': 'Insufficient data for forecast',
        'confidence': 0.0,
        'trend': 0.0,
      };
    }
    
    final currentAqi = _historicalData.last.aqi ?? 0;
    final forecastAqi = _forecastData.first.aqi ?? currentAqi;
    final confidence = _forecastData.first.confidence ?? 0.5;
    
    final difference = forecastAqi - currentAqi;
    final trend = difference / (currentAqi > 0 ? currentAqi : 1);
    
    String summary;
    if (difference < -10) {
      summary = 'Significant improvement expected';
    } else if (difference < 0) {
      summary = 'Slight improvement expected';
    } else if (difference < 10) {
      summary = 'Air quality will remain stable';
    } else if (difference < 30) {
      summary = 'Slight deterioration expected';
    } else {
      summary = 'Significant deterioration expected';
    }
    
    return {
      'summary': summary,
      'confidence': confidence,
      'trend': trend,
      'currentAqi': currentAqi,
      'forecastAqi': forecastAqi,
      'difference': difference,
    };
  }
  
  // Get forecast for a specific time period (in hours from now)
  AirQualityData? getForecastForTime(int hoursAhead) {
    if (_forecastData.isEmpty || hoursAhead < 0) return null;
    
    final index = hoursAhead.clamp(0, _forecastData.length - 1);
    return _forecastData[index];
  }
}
