import 'package:flutter/material.dart';
import 'dart:math' as math;

class AirQualityGauge extends StatelessWidget {
  final double value;
  final double minValue;
  final double maxValue;
  final String label;
  final String unit;
  final Color color;
  final double size;
  final double strokeWidth;
  final bool showValue;
  final bool showLabel;
  final bool showUnit;

  const AirQualityGauge({
    super.key,
    required this.value,
    this.minValue = 0,
    this.maxValue = 500,
    required this.label,
    this.unit = '',
    required this.color,
    this.size = 200,
    this.strokeWidth = 12,
    this.showValue = true,
    this.showLabel = true,
    this.showUnit = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final percentage = (maxValue == minValue) 
        ? 0.0 // or 1.0 depending on desired behavior when min == max
        : ((value - minValue) / (maxValue - minValue)).clamp(0.0, 1.0);
    final angle = (percentage * 180 * math.pi / 180) - math.pi / 2;
    
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background circle
          CustomPaint(
            size: Size(size, size),
            painter: _GaugeBackgroundPainter(
              strokeWidth: strokeWidth,
              color: Colors.grey[200]!,
            ),
          ),
          
          // Value arc
          CustomPaint(
            size: Size(size, size),
            painter: _GaugeValuePainter(
              strokeWidth: strokeWidth,
              color: color,
              sweepAngle: percentage * 180,
            ),
          ),
          
          // Center content
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showValue) ...[
                Text(
                  value.toStringAsFixed(value.truncateToDouble() == value ? 0 : 1),
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                if (showUnit) ...[
                  const SizedBox(height: 4),
                  Text(
                    unit,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ],
              if (showLabel) ...[
                const SizedBox(height: 8),
                Text(
                  label,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
          
          // Indicator
          Transform.rotate(
            angle: angle,
            child: Align(
              alignment: Alignment.topCenter,
              child: Container(
                width: strokeWidth * 1.5,
                height: strokeWidth * 1.5,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.5),
                      blurRadius: 6,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GaugeBackgroundPainter extends CustomPainter {
  final double strokeWidth;
  final Color color;

  _GaugeBackgroundPainter({
    required this.strokeWidth,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final rect = Rect.fromCircle(
      center: size.center(Offset.zero),
      radius: (size.width - strokeWidth) / 2,
    );

    canvas.drawArc(
      rect,
      -math.pi / 2,
      math.pi,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _GaugeValuePainter extends CustomPainter {
  final double strokeWidth;
  final Color color;
  final double sweepAngle;

  _GaugeValuePainter({
    required this.strokeWidth,
    required this.color,
    required this.sweepAngle,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final rect = Rect.fromCircle(
      center: size.center(Offset.zero),
      radius: (size.width - strokeWidth) / 2,
    );

    canvas.drawArc(
      rect,
      -math.pi / 2,
      (sweepAngle * math.pi) / 180,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _GaugeValuePainter oldDelegate) {
    return oldDelegate.sweepAngle != sweepAngle ||
        oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
