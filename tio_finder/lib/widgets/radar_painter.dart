import 'dart:math';
import 'package:flutter/material.dart';
import '../models/models.dart';

/// CustomPainter per dibuixar el radar amb sweep animat
class RadarPainter extends CustomPainter {
  final double sweepAngle; // Angle actual del sweep (0-2π)
  final List<PolarTarget> targets;
  final double maxRadius;
  final bool isHighZoom;

  RadarPainter({
    required this.sweepAngle,
    required this.targets,
    this.maxRadius = 300.0,
    this.isHighZoom = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2 - 20;

    // Fons del radar
    _drawBackground(canvas, center, radius);
    
    // Cercles concèntrics
    _drawConcentricCircles(canvas, center, radius);
    
    // Línies de referència
    _drawCrossLines(canvas, center, radius);
    
    // Sweep animat
    _drawSweep(canvas, center, radius);
    
    // Targets
    _drawTargets(canvas, center, radius);
    
    // Punt central (usuari)
    _drawCenterPoint(canvas, center);
  }

  void _drawBackground(Canvas canvas, Offset center, double radius) {
    final paint = Paint()
      ..color = const Color(0xFF0A1A0A)
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(center, radius, paint);
    
    // Vora del radar (més brillant en high zoom mode)
    final borderPaint = Paint()
      ..color = isHighZoom 
          ? Colors.greenAccent.withValues(alpha: 0.8)
          : Colors.green.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = isHighZoom ? 3 : 2;
    
    canvas.drawCircle(center, radius, borderPaint);
  }

  void _drawConcentricCircles(Canvas canvas, Offset center, double radius) {
    final paint = Paint()
      ..color = Colors.green.withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // 3 cercles concèntrics
    for (int i = 1; i <= 3; i++) {
      canvas.drawCircle(center, radius * i / 4, paint);
    }
  }

  void _drawCrossLines(Canvas canvas, Offset center, double radius) {
    final paint = Paint()
      ..color = Colors.green.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // Línia vertical
    canvas.drawLine(
      Offset(center.dx, center.dy - radius),
      Offset(center.dx, center.dy + radius),
      paint,
    );

    // Línia horitzontal
    canvas.drawLine(
      Offset(center.dx - radius, center.dy),
      Offset(center.dx + radius, center.dy),
      paint,
    );

    // Diagonals
    final diag = radius * cos(pi / 4);
    canvas.drawLine(
      Offset(center.dx - diag, center.dy - diag),
      Offset(center.dx + diag, center.dy + diag),
      paint,
    );
    canvas.drawLine(
      Offset(center.dx + diag, center.dy - diag),
      Offset(center.dx - diag, center.dy + diag),
      paint,
    );
  }

  void _drawSweep(Canvas canvas, Offset center, double radius) {
    // Gradient sweep
    final sweepPaint = Paint()
      ..shader = SweepGradient(
        startAngle: sweepAngle - pi / 6,
        endAngle: sweepAngle,
        colors: [
          Colors.transparent,
          Colors.greenAccent.withValues(alpha: 0.0),
          Colors.greenAccent.withValues(alpha: 0.3),
          Colors.greenAccent.withValues(alpha: 0.5),
        ],
        stops: const [0.0, 0.3, 0.7, 1.0],
        transform: GradientRotation(sweepAngle - pi / 2),
      ).createShader(
        Rect.fromCircle(center: center, radius: radius),
      );

    canvas.drawCircle(center, radius, sweepPaint);

    // Línia del sweep
    final linePaint = Paint()
      ..color = Colors.greenAccent.withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final endX = center.dx + radius * sin(sweepAngle);
    final endY = center.dy - radius * cos(sweepAngle);
    canvas.drawLine(center, Offset(endX, endY), linePaint);
  }

  void _drawTargets(Canvas canvas, Offset center, double radius) {
    for (final target in targets) {
      // Posició al radar
      final distance = radius * target.factor;
      // angle: 0 = nord (amunt), positiu = sentit horari
      final x = center.dx + distance * sin(target.angle);
      final y = center.dy - distance * cos(target.angle);

      // Color segons tipus
      Color color;
      double size;
      
      if (target.found) {
        color = Colors.grey;
        size = 4;
      } else {
        switch (target.type) {
          case TargetType.realTio:
            color = Colors.greenAccent;
            size = 8;
          case TargetType.fakePersistent:
            color = Colors.yellowAccent;
            size = 6;
          case TargetType.fakeVanish:
            color = Colors.redAccent;
            size = 6;
        }
      }

      // Dibuixar punt
      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(x, y), size, paint);

      // Halo per als tiós reals
      if (target.type == TargetType.realTio && !target.found) {
        final haloPaint = Paint()
          ..color = color.withValues(alpha: 0.3)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(Offset(x, y), size * 2, haloPaint);
      }
    }
  }

  void _drawCenterPoint(Canvas canvas, Offset center) {
    // Punt central (usuari)
    final userPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, 6, userPaint);

    // Triangle indicant direcció (nord)
    final path = Path();
    path.moveTo(center.dx, center.dy - 15);
    path.lineTo(center.dx - 5, center.dy - 8);
    path.lineTo(center.dx + 5, center.dy - 8);
    path.close();

    final trianglePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    canvas.drawPath(path, trianglePaint);
  }

  @override
  bool shouldRepaint(RadarPainter oldDelegate) {
    return oldDelegate.sweepAngle != sweepAngle ||
        oldDelegate.targets != targets ||
        oldDelegate.isHighZoom != isHighZoom;
  }
}
