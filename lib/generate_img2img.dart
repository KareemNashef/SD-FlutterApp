// Flutter imports
import 'package:flutter/material.dart';
import 'package:fooocus/utils.dart';
import 'dart:convert';
import 'dart:async';

// Local imports
import 'package:fooocus/generate_base.dart';
import 'package:fooocus/configs.dart';

class ImageToImagePage extends GeneratorBase {
  const ImageToImagePage({super.key});

  @override
  ImageToImagePageState createState() => ImageToImagePageState();
}

class ImageToImagePageState extends GeneratorBaseState {
  // ===== Class Variables =====

  // Generation variables
  double inputWeight = 0.8;
  double promptWeight = 1;
  bool showWeights = false;

  // Image variables
  int imageWidth = 512;
  int imageHeight = 512;
  String selectedRatio = '1:1';

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

    // Convert the selected image to base64
    final base64Image = base64Encode(await inputImage!.readAsBytes());

    // Body of the request
    final body = jsonEncode({
      "prompt": prompt,
      "negative_prompt": AppConfig.negativePrompts,
      "sampler_name": AppConfig.selectedSampler,
      "batch_size": AppConfig.imageNumber,
      "steps": AppConfig.stepsNumber,
      "cfg_scale": AppConfig.guidanceScale,
      "denoising_strength": AppConfig.denoiseStrength,

      "width": imageWidth,
      "height": imageHeight,

      "init_images": [base64Image],
      "include_init_images": true,
    });

    // Add the prompt to the history and avoid duplicates
    AppConfig.promptHistory.add(prompt);
    AppConfig.promptHistory = AppConfig.promptHistory.toSet().toList();

    // Start progress tracking
    await followJobProgress(url, headers, body);
  }

  // ===== Helper Widgets =====

  // Image weights sliders widget
  Widget weightsSliders() {
    return Column(
      children: [
        // Input weight slider
        const SizedBox(height: 8),
        const Text("Input Weight"),
        Slider(
          value: inputWeight,
          min: 0,
          max: 1,
          divisions: 10,
          label: inputWeight.toStringAsFixed(1),
          onChanged: (v) => setState(() => inputWeight = v),
        ),

        // Prompt weight slider
        const SizedBox(height: 8),
        const Text("Prompt Weight"),
        Slider(
          value: promptWeight,
          min: 0,
          max: 2,
          divisions: 20,
          label: promptWeight.toStringAsFixed(1),
          onChanged: (v) => setState(() => promptWeight = v),
        ),
      ],
    );
  }

  // Ratios buttons widget
  Widget ratiosButtons() {
    return SegmentedButton<String>(
      segments: const [
        ButtonSegment(value: '1:1', label: Text('1:1')),
        ButtonSegment(value: '4:3', label: Text('4:3')),
        ButtonSegment(value: '16:9', label: Text('16:9')),
        ButtonSegment(value: '2:3', label: Text('2:3')),
      ],
      selected: {selectedRatio},
      onSelectionChanged: (values) {
        setState(() {
          selectedRatio = values.first;
          switch (selectedRatio) {
            case '1:1':
              imageWidth = imageHeight = 1080;
              break;
            case '4:3':
              imageWidth = 1440;
              imageHeight = 1080;
              break;
            case '16:9':
              imageWidth = 1920;
              imageHeight = 1080;
              break;
            case '2:3':
              imageWidth = 1080;
              imageHeight = 1620;
              break;
          }
        });
      },
    );
  }

  //  ===== Build Method =====

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Image display area
        SizedBox(
          child: GestureDetector(onTap: pickImage, child: imageWidget()),
        ),

        // Thumbnail display area
        if (outputImages.isNotEmpty) imageCarousel(),

        Spacer(),

        // Download button and reset button
        if (!isShowingInputImage)
          Column(
            children: [
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [downloadButton(context), resetButton()],
              ),
              SizedBox(height: 8),
            ],
          ),

        // Image weights sliders
        if (isShowingInputImage) weightsSliders(),

        // Ratio selection buttons
        if (isShowingInputImage) ratiosButtons(),

        // Input field for prompt
        if (isShowingInputImage) inputField(),

        // Progress indicator
        if (isGenerating) progressBar(),
      ],
    );
  }
}
