import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../../core/constants/draw_mode.dart';
import '../../../core/constants/stroke_point.dart';

class Painter extends CustomPainter {
  final List<StrokePoint?> points;
  final ui.Image? backgroundImage;

  Painter({required this.points, required this.backgroundImage, required Listenable repaint}) : super(repaint: repaint);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = Colors.white);

    if (backgroundImage != null) {
      paintImage(canvas: canvas, rect: Offset.zero & size, image: backgroundImage!, fit: BoxFit.contain);
    }

    canvas.saveLayer(Offset.zero & size, Paint());

    final drawPaint = Paint()
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;

    final erasePaint = Paint()
      ..blendMode = BlendMode.clear
      ..strokeWidth = 20
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;

    for (var i = 0; i < points.length - 1; i++) {
      final p1 = points[i];
      final p2 = points[i + 1];

      if (p1 != null && p2 != null) {
        if (p1.mode == DrawMode.ERASE) {
          canvas.drawLine(p1.offset, p2.offset, erasePaint);
        } else {
          drawPaint.color = p1.color;
          canvas.drawLine(p1.offset, p2.offset, drawPaint);
        }
      }
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant Painter oldDelegate) => true;
}
