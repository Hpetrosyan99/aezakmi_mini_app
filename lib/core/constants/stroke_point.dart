import 'dart:ui';

import 'draw_mode.dart';

class StrokePoint {
  final Offset offset;
  final DrawMode mode;
  final Color color;

  StrokePoint(this.offset, this.mode, this.color);
}
