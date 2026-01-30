import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:mobx/mobx.dart';
import '../../../core/constants/draw_mode.dart';
import '../../../core/constants/stroke_point.dart';

part 'draw_page_state.g.dart';

class DrawPageState = _DrawPageState with _$DrawPageState;

abstract class _DrawPageState with Store {
  final repaintNotifier = ValueNotifier<int>(0);

  @observable
  ObservableList<StrokePoint?> points = ObservableList();

  @observable
  ui.Image? backgroundImage;

  @observable
  DrawMode mode = DrawMode.DRAW;

  @observable
  Color selectedColor = Colors.black;

  @action
  void setBackground(ui.Image image) {
    backgroundImage = image;
    repaintNotifier.value++;
  }

  @action
  void addPoint(Offset offset) {
    points.add(StrokePoint(offset, mode, selectedColor));
    repaintNotifier.value++;
  }

  @action
  void endStroke() {
    points.add(null);
    repaintNotifier.value++;
  }

  @action
  void setMode(DrawMode value) {
    mode = value;
  }

  @action
  void setColor(Color color) {
    selectedColor = color;
    mode = DrawMode.DRAW;
  }

  @action
  void clear() {
    points.clear();
    backgroundImage = null;
  }
}
