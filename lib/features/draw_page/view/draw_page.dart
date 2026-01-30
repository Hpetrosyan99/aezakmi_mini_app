import 'dart:async';
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
import '../../../core/services/local_notification_service.dart';
import '../../../gen/locale_keys.g.dart';
import '../../../shared/widgets/color_palette_widget/color_palette_widget.dart';
import '../../../shared/widgets/custom_scaffold/custom_scaffold.dart';
import '../../../shared/widgets/painter_widget/painter_widget.dart';
import '../../../shared/widgets/tool_button/tool_button.dart';
import '../mobx/draw_page_state.dart';

@RoutePage()
class DrawPage extends StatefulWidget {
  const DrawPage({super.key, this.imageId, this.imageUrl});

  final String? imageId;
  final String? imageUrl;

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

  bool get isEdit => widget.imageId != null;

  @override
  void initState() {
    super.initState();
    if (isEdit) {
      _loadImageForEdit();
    }
  }

  Future<void> _loadImageForEdit() async {
    drawState.startLoading();
    final byteData = await NetworkAssetBundle(Uri.parse(widget.imageUrl!)).load(widget.imageUrl!);
    final codec = await ui.instantiateImageCodec(byteData.buffer.asUint8List());
    final frame = await codec.getNextFrame();
    drawState
      ..setBackground(frame.image)
      ..stopLoading();
  }

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

  Future<void> _saveToGallery() async {
    final boundary = _repaintKey.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: 3);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final bytes = byteData!.buffer.asUint8List();
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/drawing.png');
    await file.writeAsBytes(bytes);
    await ImageGallerySaver.saveFile(file.path);
    await LocalNotificationService.showImageSaved();
    await HapticFeedback.selectionClick();
  }

  Future<void> _saveDrawing() async {
    router.showFullScreenLoading();
    await Future.delayed(Duration.zero);
    await WidgetsBinding.instance.endOfFrame;
    try {
      final boundary = _repaintKey.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 3);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final bytes = byteData!.buffer.asUint8List();
      final user = FirebaseAuth.instance.currentUser!;
      final id = widget.imageId ?? DateTime.now().millisecondsSinceEpoch.toString();
      final storagePath = 'users/${user.uid}/drawings/$id.png';
      final storageRef = FirebaseStorage.instance.ref(storagePath);
      await storageRef.putData(bytes, SettableMetadata(contentType: 'image/png'));
      final downloadUrl = await storageRef.getDownloadURL();
      unawaited(
        FirebaseFirestore.instance.collection('users').doc(user.uid).collection('images').doc(id).set({
          'imageId': id,
          'storagePath': storagePath,
          'downloadUrl': downloadUrl,
          'updatedAt': FieldValue.serverTimestamp(),
          if (!isEdit) 'createdAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true)),
      );
      await router.pop();
      await _saveToGallery();
    } finally {
      await router.hideFullScreenLoading();
    }
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
      builder: (_) => Stack(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: _closeColorPicker,
            child: const SizedBox.expand(),
          ),
          CompositedTransformFollower(
            link: _colorPickerLink,
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
      ),
    );

    overlay.insert(_colorPickerOverlay!);
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
        centerTitle: true,
        systemOverlayStyle:
        const SystemUiOverlayStyle(statusBarBrightness: Brightness.dark),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(onPressed: router.pop, icon: const Icon(Icons.arrow_back_ios)),
            Text(
              isEdit ? LocaleKeys.gallery_edit.tr() : LocaleKeys.gallery_new_image.tr(),
              style: TextStyles.primaryButtonTextStyle,
            ),
            IconButton(onPressed: _saveDrawing, icon: Assets.icons.doneIcon.image(height: 24)),
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
                  ToolButton(icon: Assets.icons.downloadIcon.image(), onPressed: _saveToGallery),
                  ToolButton(icon: Assets.icons.addImageIcon.image(), onPressed: _pickImage),
                  ToolButton(icon: Assets.icons.editIcon.image(), onPressed: () => drawState.setMode(DrawMode.DRAW)),
                  ToolButton(icon: Assets.icons.eraserIcon.image(), onPressed: () => drawState.setMode(DrawMode.ERASE)),
                  CompositedTransformTarget(
                    link: _colorPickerLink,
                    child: ToolButton(icon: Assets.icons.colorPickerIcon.image(), onPressed: _toggleColorPicker),
                  ),
                ],
              ),
              const Gap(24),
              Expanded(
                child: Observer(
                  builder: (_) => RepaintBoundary(
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
                          child: Stack(
                            children: [
                              CustomPaint(
                                painter: Painter(
                                  points: drawState.points,
                                  backgroundImage: drawState.backgroundImage,
                                  repaint: drawState.repaintNotifier,
                                ),
                                child: const SizedBox.expand(),
                              ),
                              if (drawState.imageLoading)
                                const Center(
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.deepPurpleAccent),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
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
