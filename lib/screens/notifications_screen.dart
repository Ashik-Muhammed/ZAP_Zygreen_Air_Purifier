import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zygreen_air_purifier/providers/alert_provider.dart';
import 'package:zygreen_air_purifier/models/air_quality_alert.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Air Quality Alerts'),
        actions: [
          Consumer<AlertProvider>(
            builder: (context, alertProvider, _) {
              if (alertProvider.alerts.isNotEmpty) {
                return TextButton(
                  onPressed: alertProvider.markAllAsRead,
                  child: const Text('Mark all as read'),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: Consumer<AlertProvider>(
        builder: (context, alertProvider, _) {
          if (alertProvider.alerts.isEmpty) {
            return const Center(
              child: Text('No alerts yet'),
            );
          }

          return ListView.builder(
            itemCount: alertProvider.alerts.length,
            itemBuilder: (context, index) {
              final alert = alertProvider.alerts[index];
              return _buildAlertItem(context, alert);
            },
          );
        },
      ),
    );
  }

  Widget _buildAlertItem(BuildContext context, AirQualityAlert alert) {
    return Dismissible(
      key: Key(alert.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) {
        // Remove the alert when dismissed
        Provider.of<AlertProvider>(context, listen: false).markAsRead(alert.id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Alert dismissed')),
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        color: alert.isRead ? Colors.grey[100] : Colors.white,
        child: ListTile(
          leading: Icon(alert.icon, color: alert.color),
          title: Text(
            alert.title,
            style: TextStyle(
              fontWeight: alert.isRead ? FontWeight.normal : FontWeight.bold,
            ),
          ),
          subtitle: Text(
            alert.message,
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 12,
            ),
          ),
          trailing: Text(
            '${alert.timestamp.hour}:${alert.timestamp.minute.toString().padLeft(2, '0')}',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          onTap: () {
            if (!alert.isRead) {
              Provider.of<AlertProvider>(context, listen: false)
                  .markAsRead(alert.id);
            }
            // Show alert details
            _showAlertDetails(context, alert);
          },
        ),
      ),
    );
  }

  void _showAlertDetails(BuildContext context, AirQualityAlert alert) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(alert.icon, color: alert.color),
            const SizedBox(width: 8),
            Text(alert.title),
          ],
        ),
        content: SingleChildScrollView(
          child: Text(alert.message.replaceAll('\n', '\n\n')),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
