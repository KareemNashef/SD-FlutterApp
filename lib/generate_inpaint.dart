// Flutter imports
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:convert';
import 'dart:async';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_exif_rotation/flutter_exif_rotation.dart';
import 'dart:ui' as ui;
import 'package:image/image.dart' as img;

// Local imports
import 'package:fooocus/utils.dart';
import 'package:fooocus/generate_base.dart';
import 'package:fooocus/configs.dart';

class InpaintImagePage extends GeneratorBase {
  const InpaintImagePage({super.key});

  @override
  InpaintImagePageState createState() => InpaintImagePageState();
}

class InpaintImagePageState extends GeneratorBaseState {
  // ===== Class Variables =====

  // Drawing variables
  List<DrawPoint?> points = [];
  bool isErasing = false;
  double strokeWidth = 10.0;
  GlobalKey repaintBoundaryKey = GlobalKey();
  double _imageWidth = 300;
  double _imageHeight = 300;
  double get imageAspectRatio =>
      _imageWidth / _imageHeight; // Aspect ratio of the image

  // ===== Helper Methods =====

  // Method to generate image from prompt
  @override
  Future<void> generateImage(String prompt) async {
    // Check if an image is selected
    if (inputImage == null) return;

    // URL for the image generation API
    final url = Uri.parse(getImageToImageUrl());

    // Headers for the request
    final headers = {'Content-Type': 'application/json'};

    // Convert the selected image to base64 and get the mask
    final base64Image = base64Encode(await inputImage!.readAsBytes());
    final base64Mask = await _getMask();

    // Body of the request
    final body = jsonEncode({
      "prompt": prompt,
      "negative_prompt": AppConfig.negativePrompts,
      "sampler_name": AppConfig.selectedSampler,
      "batch_size": AppConfig.imageNumber,
      "steps": AppConfig.stepsNumber,
      "cfg_scale": AppConfig.guidanceScale,
      "denoising_strength": AppConfig.denoiseStrength,

      "init_images": [base64Image],
      "mask": base64Mask,
      "save_images": true,
      "send_images": true,

      "scheduler": "karras",

      "mask_blur": 4, // Mask blur
      "inpainting_fill":
          3, // 0 - Fill, 1 - Original, 2 - Latent Noise, 3 - Latent Nothing
      // "inpaint_full_res": true, // False - ???, True - Inpaint only masked
      "inpaint_full_res_padding": 32,
      "inpaint_full_res": 1,
      "inpainting_mask_invert": 0, // 0 - Inpaint masked, 1 - Inpaint unmasked
      "mask_round": true,

      "resize_mode": 0,
      "image_cfg_scale": 1.5,
    });
    // Add the prompt to the history and avoid duplicates
    AppConfig.promptHistory.add(prompt);
    AppConfig.promptHistory = AppConfig.promptHistory.toSet().toList();

    // Start progress tracking
    await followJobProgress(url, headers, body);
  }

  // Method to load an image from the gallery
  @override
  Future<void> pickImage() async {
    // Show image picker to select an image from the gallery
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);

    // If no image is picked, return
    if (picked == null) return;

    // Correct the image orientation using EXIF data
    final correctedImage = await FlutterExifRotation.rotateImage(
      path: picked.path,
    );

    // Get the image dimensions
    final image = img.decodeImage(correctedImage.readAsBytesSync())!;

    // Save the image to the inputImage variable and update the state
    setState(() {
      inputImage = File(correctedImage.path);
      _imageWidth = image.width.toDouble();
      _imageHeight = image.height.toDouble();
    });
  }

  // Method to get the drawn mask
  Future<String?> _getMask() async {
    RenderRepaintBoundary boundary =
        repaintBoundaryKey.currentContext!.findRenderObject()
            as RenderRepaintBoundary;
    ui.Image image = await boundary.toImage();

    ByteData? byteData = await image.toByteData(
      format: ui.ImageByteFormat.rawRgba,
    );
    if (byteData == null) return null;
    Uint8List buffer = byteData.buffer.asUint8List();

    img.Image imgImage = img.Image.fromBytes(image.width, image.height, buffer);

    // Resize first to avoid introducing gray pixels
    imgImage = img.copyResize(
      imgImage,
      width: _imageWidth.toInt(),
      height: _imageHeight.toInt(),
      interpolation: img.Interpolation.nearest,
    );

    // Then pure black or white
    for (int i = 0; i < imgImage.length; i++) {
      int pixel = imgImage[i];
      int r = img.getRed(pixel);
      int g = img.getGreen(pixel);
      int b = img.getBlue(pixel);

      bool isBlack = (r == 0 && g == 0 && b == 0);
      imgImage[i] =
          isBlack ? img.getColor(0, 0, 0) : img.getColor(255, 255, 255);
    }

    List<int> pngBytes = img.encodePng(imgImage);
    return base64Encode(pngBytes);
  }

  // ===== Helper Widgets =====

  // Drawing tools widget
  Widget drawingTools() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Draw & Erase buttons
          SegmentedButton<bool>(
            segments: const [
              ButtonSegment(value: false, label: Icon(Icons.brush)),
              ButtonSegment(value: true, label: Icon(Icons.delete)),
            ],
            selected: {isErasing},
            showSelectedIcon: false,
            onSelectionChanged: (values) {
              setState(() {
                isErasing = values.first;
              });
            },
          ),

          // Stroke width slider
          Expanded(
            child: Slider(
              value: strokeWidth,
              min: 1.0,
              max: 100.0,
              divisions: 19,
              onChanged: (value) {
                setState(() {
                  strokeWidth = value;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  // Image drawing widget
  Widget imageDrawingWidget() {
    return GestureDetector(
      onTap: pickImage,
      child: Container(
        margin: const EdgeInsets.all(16),
        // Set a max height to prevent overflow
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.5,
          maxWidth: MediaQuery.of(context).size.width - 32,
        ),
        child: AspectRatio(
          aspectRatio: imageAspectRatio,
          child: ClipRect(
            child: Stack(
              fit:
                  StackFit.expand, // Make all children expand to fill the stack
              children: [
                // Background image that fills the space
                Positioned.fill(child: imageWidget()),

                // RepaintBoundary that fills the same space
                if (isShowingInputImage)
                  Positioned.fill(
                    child: RepaintBoundary(
                      key: repaintBoundaryKey,
                      child: GestureDetector(
                        onPanUpdate: (details) {
                          final renderBox =
                              repaintBoundaryKey.currentContext!
                                      .findRenderObject()
                                  as RenderBox;
                          final localPos = renderBox.globalToLocal(
                            details.globalPosition,
                          );
                          setState(() {
                            points.add(
                              DrawPoint(
                                offset: localPos,
                                isErase: isErasing,
                                width: strokeWidth,
                              ),
                            );
                          });
                        },
                        onPanEnd: (_) => setState(() => points.add(null)),
                        child: CustomPaint(
                          size: Size.infinite, // Will fill the parent
                          painter: MaskPainter(points),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Replace input image button widget
  Widget replaceInputImageButtonAndResetCanvas() {
    return ElevatedButton.icon(
      // Button style
      style: ElevatedButton.styleFrom(
        shape: const StadiumBorder(),
        padding: const EdgeInsets.all(12),
      ),

      // Button action
      onPressed: () {
        replaceInputImage();
        setState(() {
          points.clear();
        });
      },

      // Button icon
      icon: const Icon(Icons.sync, color: Colors.white),

      // Button label
      label: const Text('Use as New Base'),
    );
  }

  //  ===== Build Method =====

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Image display area
          imageDrawingWidget(),

          // Thumbnail display area
          if (outputImages.isNotEmpty) imageCarousel(),

          // Erase and stroke width controls
          if (isShowingInputImage) drawingTools(),

          // Download button and reset and new base button
          if (!isShowingInputImage)
            Column(
              children: [
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    downloadButton(context),
                    replaceInputImageButtonAndResetCanvas(),
                    resetButton(),
                  ],
                ),
                SizedBox(height: 8),
              ],
            ),

          // Input field for prompt
          if (isShowingInputImage) inputField(),

          // Progress indicator
          if (isGenerating) progressBar(),
        ],
      ),
    );
  }
}

// Class to represent a point on the mask
class DrawPoint {
  final Offset offset;
  final bool isErase;
  final double width; // Default stroke width

  DrawPoint({required this.offset, required this.isErase, required this.width});
}

// CustomPainter to draw the mask
class MaskPainter extends CustomPainter {
  // List of points to draw
  final List<DrawPoint?> points;

  // Constructor
  MaskPainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    // Paint object to define the style of the mask
    final paint = Paint()..strokeCap = StrokeCap.round;

    // Save the current canvas state
    canvas.saveLayer(Offset.zero & size, Paint()); // Enable transparency

    // Draw the points on the canvas
    for (int i = 0; i < points.length - 1; i++) {
      // Get the current and next points
      final p1 = points[i];
      final p2 = points[i + 1];

      // If both points are not null and have the same erase state, draw the line
      if (p1 != null && p2 != null && p1.isErase == p2.isErase) {
        // Set the paint color based on the erase state
        paint
          ..strokeWidth = p1.width
          ..isAntiAlias = false
          ..color =
              p1.isErase ? Colors.transparent : Colors.white.withOpacity(0.5)
          ..blendMode = p1.isErase ? BlendMode.clear : BlendMode.src;

        // Draw the line between the two points
        canvas.drawLine(p1.offset, p2.offset, paint);
      }
    }

    // Restore the canvas to its previous state
    canvas.restore();
  }

  @override
  // This method is called when the CustomPainter needs to be repainted
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
