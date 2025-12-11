import 'dart:math';
import 'package:flutter/material.dart';
import '../models/models.dart';
import 'radar_painter.dart';

/// Widget del radar amb animació de sweep
class RadarWidget extends StatefulWidget {
  final List<PolarTarget> targets;
  final double size;
  final bool isHighZoom;

  const RadarWidget({
    super.key,
    required this.targets,
    this.size = 300,
    this.isHighZoom = false,
  });

  @override
  State<RadarWidget> createState() => _RadarWidgetState();
}

class _RadarWidgetState extends State<RadarWidget>
    with TickerProviderStateMixin {
  late AnimationController _sweepController;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _sweepController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
    
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _sweepController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_sweepController, _pulseController]),
      builder: (context, child) {
        return CustomPaint(
          size: Size(widget.size, widget.size),
          painter: RadarPainter(
            sweepAngle: _sweepController.value * 2 * pi,
            pulseValue: _pulseController.value,
            targets: widget.targets,
            isHighZoom: widget.isHighZoom,
          ),
        );
      },
    );
  }
}
