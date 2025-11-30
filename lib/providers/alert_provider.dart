import 'package:flutter/material.dart';
import 'package:zygreen_air_purifier/models/air_quality_alert.dart';

class AlertProvider with ChangeNotifier {
  final List<AirQualityAlert> _alerts = [];
  bool _hasUnread = false;

  List<AirQualityAlert> get alerts => List.unmodifiable(_alerts);
  bool get hasUnread => _hasUnread;
  int get unreadCount => _alerts.where((alert) => !alert.isRead).length;

  void addAlert(AirQualityAlert alert) {
    _alerts.insert(0, alert);
    _hasUnread = true;
    _showNotification(alert);
    notifyListeners();
  }

  void markAsRead(String alertId) {
    final index = _alerts.indexWhere((alert) => alert.id == alertId);
    if (index != -1) {
      _alerts[index].isRead = true;
      _hasUnread = _alerts.any((alert) => !alert.isRead);
      notifyListeners();
    }
  }

  void markAllAsRead() {
    bool updated = false;
    for (var alert in _alerts) {
      if (!alert.isRead) {
        alert.isRead = true;
        updated = true;
      }
    }
    if (updated) {
      _hasUnread = false;
      notifyListeners();
    }
  }

  void clearAll() {
    _alerts.clear();
    _hasUnread = false;
    notifyListeners();
  }

  void _showNotification(AirQualityAlert alert) {
    // TODO: Implement local notifications
    // This is where you would integrate with a notification plugin
    // like flutter_local_notifications
  }
}
