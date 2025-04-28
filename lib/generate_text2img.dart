// Flutter imports
import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:async';

// Local imports
import 'package:fooocus/utils.dart';
import 'package:fooocus/generate_base.dart';
import 'package:fooocus/configs.dart';

class TextToImagePage extends GeneratorBase {
  const TextToImagePage({super.key});

  @override
  TextToImagePageState createState() => TextToImagePageState();
}

class TextToImagePageState extends GeneratorBaseState {
  // ===== Class Variables =====

  // Image settings
  String selectedRatio = '1:1';
  int imageWidth = 512;
  int imageHeight = 512;

  // ===== Helper Methods =====

  // Method to generate image from prompt
  @override
  Future<void> generateImage(String prompt) async {
    // URL for the image generation API
    final url = Uri.parse(getTextToImageUrl());

    // Headers for the request
    final headers = {'Content-Type': 'application/json'};

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
    });

    // Add the prompt to the history and avoid duplicates
    AppConfig.promptHistory.add(prompt);
    AppConfig.promptHistory = AppConfig.promptHistory.toSet().toList();

    // Start progress tracking
    await followJobProgress(url, headers, body);
  }

  // ===== Helper Widgets =====

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
        if (!isShowingInputImage) imageWidget(),

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
