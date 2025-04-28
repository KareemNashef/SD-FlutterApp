// Flutter imports
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
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
  _InpaintImagePageState createState() => _InpaintImagePageState();
}

class _InpaintImagePageState extends GeneratorBaseState {
  // ===== Class Variables =====

  // Drawing variables
  List<_DrawPoint?> points = [];
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


  "mask_blur": 4,  // Mask blur
  "inpainting_fill": 3,  // 0 - Fill, 1 - Original, 2 - Latent Noise, 3 - Latent Nothing
  "inpaint_full_res": true, // False - ???, True - Inpaint only masked
  "inpaint_full_res_padding": 4,
  "inpainting_mask_invert": 0,  // 0 - Inpaint masked, 1 - Inpaint unmasked
  "mask_round": false,
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
    // Get what's rendered in the repaint boundary
    RenderRepaintBoundary boundary =
        repaintBoundaryKey.currentContext!.findRenderObject()
            as RenderRepaintBoundary;
    ui.Image image = await boundary.toImage();

    // Convert the image to raw RGBA data
    ByteData? byteData = await image.toByteData(
      format: ui.ImageByteFormat.rawRgba,
    );
    if (byteData == null) return null;
    Uint8List buffer = byteData.buffer.asUint8List();

    // Convert the RGBA byte buffer into an Image from the 'image' package
    img.Image imgImage = img.Image.fromBytes(image.width, image.height, buffer);

    // Create a binary mask by converting transparency into black and opaque areas into white
    for (int y = 0; y < imgImage.height; y++) {
      for (int x = 0; x < imgImage.width; x++) {
        int pixel = imgImage.getPixel(x, y);
        int alpha = img.getAlpha(pixel);

        // If alpha is 0 (transparent), set pixel to black (mask area)
        // Else set pixel to white (non-mask area)
        if (alpha == 0) {
          imgImage.setPixel(x, y, img.getColor(0, 0, 0)); // Black (for mask)
        } else {
          imgImage.setPixel(
            x,
            y,
            img.getColor(255, 255, 255),
          ); // White (for non-mask area)
        }
      }
    }

    // Resize if needed
    imgImage = img.copyResize(
      imgImage,
      width: _imageWidth.toInt(),
      height: _imageHeight.toInt(),
    );

    // Encode the image to PNG format and convert it to base64 string
    List<int> pngBytes = img.encodePng(imgImage);

    return base64Encode(
      pngBytes,
    ); // Return the base64 encoded string of the mask
  }

  // ===== Helper Widgets =====

  // Drawing tools widget
  Widget drawingTools() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Erase button
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(12),
          ),
          onPressed: () {
            setState(() {
              isErasing = !isErasing;
            });
          },
          child: Icon(
            isErasing ? Icons.brush : Icons.delete,
            color: Colors.white,
          ),
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
                              _DrawPoint(
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
                          painter: _MaskPainter(points),
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
                    downloadButton(),
                    replaceInputImageButton(),
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
class _DrawPoint {
  final Offset offset;
  final bool isErase;
  final double width; // Default stroke width

  _DrawPoint({
    required this.offset,
    required this.isErase,
    required this.width,
  });
}

// CustomPainter to draw the mask
class _MaskPainter extends CustomPainter {
  // List of points to draw
  final List<_DrawPoint?> points;

  // Constructor
  _MaskPainter(this.points);

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
          ..color = p1.isErase ? Colors.transparent : Colors.white
          ..blendMode = p1.isErase ? BlendMode.clear : BlendMode.srcOver;

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
