
class AirQualityData {
  final DateTime timestamp;
  final double? pm25;
  final double? pm10;
  final double? co2;
  final double? voc;
  final bool isPrediction;

  AirQualityData({
    required this.timestamp,
    this.pm25,
    this.pm10,
    this.co2,
    this.voc,
    this.isPrediction = false,
  });

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'pm25': pm25,
      'pm10': pm10,
      'co2': co2,
      'voc': voc,
      'isPrediction': isPrediction,
    };
  }

  // Create from JSON
  factory AirQualityData.fromJson(Map<String, dynamic> json) {
    return AirQualityData(
      timestamp: DateTime.parse(json['timestamp']),
      pm25: json['pm25']?.toDouble(),
      pm10: json['pm10']?.toDouble(),
      co2: json['co2']?.toDouble(),
      voc: json['voc']?.toDouble(),
      isPrediction: json['isPrediction'] ?? false,
    );
  }

  // Create a copy with some fields updated
  AirQualityData copyWith({
    DateTime? timestamp,
    double? pm25,
    double? pm10,
    double? co2,
    double? voc,
    bool? isPrediction,
  }) {
    return AirQualityData(
      timestamp: timestamp ?? this.timestamp,
      pm25: pm25 ?? this.pm25,
      pm10: pm10 ?? this.pm10,
      co2: co2 ?? this.co2,
      voc: voc ?? this.voc,
      isPrediction: isPrediction ?? this.isPrediction,
    );
  }

  // Calculate AQI based on PM2.5 (simplified version)
  int? get aqi {
    if (pm25 == null) return null;
    
    final pm = pm25!;
    if (pm <= 12) {
      return ((50 / 12) * pm).round();
    } else if (pm <= 35.4) {
      return 51 + ((49 / 23.4) * (pm - 12)).round();
    } else if (pm <= 55.4) {
      return 101 + ((49 / 19.9) * (pm - 35.5)).round();
    } else if (pm <= 150.4) {
      return 151 + ((49 / 94.9) * (pm - 55.5)).round();
    } else if (pm <= 250.4) {
      return 201 + ((99 / 99.9) * (pm - 150.5)).round();
    } else {
      return 301 + ((199 / 149.6) * (pm - 250.5)).round();
    }
  }

  // Get air quality status
  String? get status {
    final aqiValue = aqi;
    if (aqiValue == null) return null;
    
    if (aqiValue <= 50) return 'Good';
    if (aqiValue <= 100) return 'Moderate';
    if (aqiValue <= 150) return 'Unhealthy for Sensitive Groups';
    if (aqiValue <= 200) return 'Unhealthy';
    if (aqiValue <= 300) return 'Very Unhealthy';
    return 'Hazardous';
  }
}
