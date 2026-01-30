import 'dart:io';
import 'dart:ui' as ui;

import 'package:auto_route/auto_route.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:design_system/design_system.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:gap/gap.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../../../core/constants/draw_mode.dart';
import '../../../core/navigation/app_router.dart';
import '../../../gen/locale_keys.g.dart';
import '../../../shared/widgets/color_palette_widget/color_palette_widget.dart';
import '../../../shared/widgets/custom_scaffold/custom_scaffold.dart';
import '../../../shared/widgets/custom_snack_bar/snack_bar_method.dart';
import '../../../shared/widgets/painter_widget/painter_widget.dart';
import '../../../shared/widgets/tool_button/tool_button.dart';
import '../mobx/draw_page_state.dart';

@RoutePage()
class DrawPage extends StatefulWidget {
  const DrawPage({super.key});

  @override
  State<DrawPage> createState() => _DrawPageState();
}

class _DrawPageState extends State<DrawPage> {
  final _repaintKey = GlobalKey();
  final _canvasKey = GlobalKey();
  final drawState = DrawPageState();
  OverlayEntry? _colorPickerOverlay;
  final LayerLink _colorPickerLink = LayerLink();
  static const double _paletteWidth = 11 * 22;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery);
    if (file == null) {
      return;
    }

    final bytes = await File(file.path).readAsBytes();
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();

    drawState.setBackground(frame.image);
  }

  Future<void> _saveToGallery(BuildContext context) async {
    final boundary = _repaintKey.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: 3);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final pngBytes = byteData!.buffer.asUint8List();
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/drawing.png');
    await file.writeAsBytes(pngBytes);
    await ImageGallerySaver.saveFile(file.path);
    await HapticFeedback.selectionClick();
  }

  void _toggleColorPicker() {
    if (_colorPickerOverlay != null) {
      _closeColorPicker();
    } else {
      _openColorPickerOverlay();
    }
  }

  void _openColorPickerOverlay() {
    final overlay = Overlay.of(context, rootOverlay: true);
    _colorPickerOverlay = OverlayEntry(
      builder: (_) {
        return Stack(
          children: [
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: _closeColorPicker,
              child: const SizedBox.expand(),
            ),
            CompositedTransformFollower(
              link: _colorPickerLink,
              showWhenUnlinked: false,
              offset: const Offset(-(_paletteWidth / 2) - 90, 48),
              child: ColorPalette(
                selectedColor: drawState.selectedColor,
                onSelect: (color) {
                  drawState.setColor(color);
                  _closeColorPicker();
                  HapticFeedback.selectionClick();
                },
              ),
            ),
          ],
        );
      },
    );

    overlay.insert(_colorPickerOverlay!);
  }

  Future<void> _saveDrawing(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return;
    }
    final boundary =
    _repaintKey.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: 3);
    final byteData =
    await image.toByteData(format: ui.ImageByteFormat.png);
    final bytes = byteData!.buffer.asUint8List();
    final imageId = DateTime.now().millisecondsSinceEpoch.toString();
    final storageRef = FirebaseStorage.instance
        .ref()
        .child('users/${user.uid}/drawings/$imageId.png');

    await storageRef.putData(
      bytes,
      SettableMetadata(contentType: 'image/png'),
    );
    final downloadUrl = await storageRef.getDownloadURL();
    final dir = await getApplicationDocumentsDirectory();
    final drawingsDir = Directory('${dir.path}/drawings');
    if (!drawingsDir.existsSync()) {
      drawingsDir.createSync(recursive: true);
    }
    final localPath = '${drawingsDir.path}/$imageId.png';
    await File(localPath).writeAsBytes(bytes);
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('images')
        .doc(imageId)
        .set({
      'url': downloadUrl,
      'localPath': localPath,
      'createdAt': FieldValue.serverTimestamp(),
    });
    await showCustomSnackBar(
      context: context,
      message: 'Image saved',
    );
    await HapticFeedback.selectionClick();
    await router.pop();
  }

  void _closeColorPicker() {
    _colorPickerOverlay?.remove();
    _colorPickerOverlay = null;
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        systemOverlayStyle: const SystemUiOverlayStyle(statusBarBrightness: Brightness.light),
        centerTitle: true,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(onPressed: router.pop, icon: const Icon(Icons.arrow_back_ios)),
            Text(LocaleKeys.gallery_new_image.tr(), style: TextStyles.primaryButtonTextStyle),
            IconButton(
              onPressed: () {
                _saveDrawing(context);
              },
              icon: Assets.icons.doneIcon.image(height: 24),
            ),
          ],
        ),
        backgroundColor: Colors.grey.withValues(alpha: 0.2),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(bottom: Radius.circular(8))),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                spacing: 12,
                children: [
                  ToolButton(
                    icon: Assets.icons.downloadIcon.image(),
                    onPressed: () {
                      _saveToGallery(context);
                    },
                  ),
                  ToolButton(icon: Assets.icons.addImageIcon.image(), onPressed: _pickImage),
                  ToolButton(
                    icon: Assets.icons.editIcon.image(),
                    onPressed: () {
                      drawState.setMode(DrawMode.DRAW);
                    },
                  ),
                  ToolButton(
                    icon: Assets.icons.eraserIcon.image(),
                    onPressed: () {
                      drawState.setMode(DrawMode.ERASE);
                    },
                  ),
                  CompositedTransformTarget(
                    link: _colorPickerLink,
                    child: ToolButton(icon: Assets.icons.colorPickerIcon.image(), onPressed: _toggleColorPicker),
                  ),
                ],
              ),
              const Gap(24),
              Expanded(
                child: Observer(
                  builder: (_) {
                    return RepaintBoundary(
                      key: _repaintKey,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: ColoredBox(
                          key: _canvasKey,
                          color: Colors.white,
                          child: GestureDetector(
                            onPanUpdate: (details) {
                              final box = _canvasKey.currentContext!.findRenderObject()! as RenderBox;
                              drawState.addPoint(box.globalToLocal(details.globalPosition));
                            },
                            onPanEnd: (_) => drawState.endStroke(),
                            child: CustomPaint(
                              painter: Painter(
                                points: drawState.points,
                                backgroundImage: drawState.backgroundImage,
                                repaint: drawState.repaintNotifier,
                              ),
                              child: const SizedBox.expand(),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const Gap(116),
            ],
          ),
        ),
      ),
    );
  }
}
