// Flutter imports
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';

// Local imports
import 'package:fooocus/generate_base.dart';
import 'package:fooocus/configs.dart';

class OutpaintImagePage extends GeneratorBase {
  const OutpaintImagePage({super.key});

  @override
  _OutpaintImagePageState createState() => _OutpaintImagePageState();
}

class _OutpaintImagePageState extends GeneratorBaseState {
  // ===== Class Variables =====

  // Outpaint variables
  List<String> outpaintSelections = [];

  // ===== Helper Methods =====

  // Method to generate image from prompt
  @override
  Future<void> generateImage(String prompt) async {
    // Check if an image is selected
    if (inputImage == null) return;

    // Check if outpaint selections are made
    if (outpaintSelections.isEmpty) return;

    // URL for the image generation API
    final url = Uri.parse(
      'http://${AppConfig.ip}:${AppConfig.port}/v2/generation/image-inpaint-outpaint',
    );

    // Headers for the request
    final headers = {'Content-Type': 'application/json'};

    // Convert the selected image to base64
    final base64Image = base64Encode(await inputImage!.readAsBytes());

    // Body of the request
    final body = jsonEncode({
      "prompt": "",
      "negative_prompt": AppConfig.negativePrompts,
      "style_selections": AppConfig.selectedStyles,
      "performance_selection": AppConfig.performanceSelection,
      "image_number": AppConfig.imageNumber,
      "sharpness": AppConfig.sharpness,
      "guidance_scale": AppConfig.guidanceScale,
      "base_model_name": AppConfig.selectedModel,
      "refiner_model_name": AppConfig.selectedRefiner,
      "refiner_switch": AppConfig.refinerStrength,
      "async_process": true,
      "input_image": base64Image,
      "outpaint_selections": outpaintSelections,
    });

    // Send the request
    setState(() => isGenerating = true);
    final response = await http.post(url, headers: headers, body: body);

    // Extract job ID from response
    final data = jsonDecode(response.body);
    String jobID = data['job_id'];

    // Start progress tracking
    await followJobProgress(jobID);
  }

  // Method to select an outpaint option
  void toggleOutpaintDirection(String direction) {
    setState(() {
      if (outpaintSelections.contains(direction)) {
        outpaintSelections.remove(direction);
      } else {
        outpaintSelections.add(direction);
      }
    });
  }

  // ===== Helper Widgets =====

  // Directions buttons widget
  Widget directionButtons() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.arrow_upward),
              color:
                  outpaintSelections.contains('Top')
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey,
              onPressed: () => toggleOutpaintDirection('Top'),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back),
                  color:
                      outpaintSelections.contains('Left')
                          ? Theme.of(context).colorScheme.primary
                          : Colors.grey,
                  onPressed: () => toggleOutpaintDirection('Left'),
                ),
                const SizedBox(width: 32),
                IconButton(
                  icon: Icon(Icons.arrow_forward),
                  color:
                      outpaintSelections.contains('Right')
                          ? Theme.of(context).colorScheme.primary
                          : Colors.grey,
                  onPressed: () => toggleOutpaintDirection('Right'),
                ),
              ],
            ),
            IconButton(
              icon: Icon(Icons.arrow_downward),
              color:
                  outpaintSelections.contains('Bottom')
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey,
              onPressed: () => toggleOutpaintDirection('Bottom'),
            ),
          ],
        ),
      ],
    );
  }

  // Generate image button widget
  Widget generateImageButton() {
    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(horizontal: 16),
      child: SizedBox(
        width: double.infinity,
        
        
        child: ElevatedButton.icon(
          // Button style
          style: ElevatedButton.styleFrom(
          shape: const StadiumBorder(),
          padding: const EdgeInsets.all(12),
          ),
        
          // Button action
          onPressed: isGenerating ? null : () => generateImage("ass"),
        
          // Button icon
          icon:
              isGenerating
                  ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                  : const Icon(Icons.create),
        
          // Button label
          label: const Text('Generate Image'),
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
          SizedBox(
            child: GestureDetector(onTap: pickImage, child: imageWidget()),
          ),

          // Thumbnail display area
          if (outputImages.isNotEmpty) imageCarousel(),

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

          // Directions buttons
          if (isShowingInputImage) directionButtons(),

          // Generate image button
          if (isShowingInputImage) generateImageButton(),

          // Progress indicator
          if (isGenerating) progressBar(),
        ],
      ),
    );
  }
}
