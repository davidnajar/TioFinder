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
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          size: Size(widget.size, widget.size),
          painter: RadarPainter(
            sweepAngle: _controller.value * 2 * pi,
            targets: widget.targets,
            isHighZoom: widget.isHighZoom,
          ),
        );
      },
    );
  }
}
