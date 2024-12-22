import 'package:flutter/material.dart';
import 'dart:math';

class VisualizerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final random = Random();
    final waveHeight = size.height / 2;

    for (int i = 0; i < size.width; i += 15) {
      final amplitude = random.nextDouble() * waveHeight;
      canvas.drawLine(
        Offset(i.toDouble(), waveHeight - amplitude),
        Offset(i.toDouble(), waveHeight + amplitude),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
