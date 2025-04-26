// Flutter imports
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';

// Local imports
import 'package:fooocus/generate_base.dart';
import 'package:fooocus/configs.dart';

class TextToImagePage extends GeneratorBase {
  const TextToImagePage({super.key});

  @override
  _TextToImagePageState createState() => _TextToImagePageState();
}

class _TextToImagePageState extends GeneratorBaseState {
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
    final url = Uri.parse(
      'http://${AppConfig.ip}:${AppConfig.port}/v2/generation/text-to-image-with-ip',
    );

    // Headers for the request
    final headers = {'Content-Type': 'application/json'};

    // Body of the request
    final body = jsonEncode({
      "prompt": prompt,
      "negative_prompt": AppConfig.negativePrompts,
      "style_selections": AppConfig.selectedStyles,
      "performance_selection": AppConfig.performanceSelection,
      "aspect_ratios_selection": '$imageWidth*$imageHeight',
      "image_number": AppConfig.imageNumber,
      "sharpness": AppConfig.sharpness,
      "guidance_scale": AppConfig.guidanceScale,
      "base_model_name": AppConfig.selectedModel,
      "refiner_model_name": AppConfig.selectedRefiner,
      "refiner_switch": AppConfig.refinerStrength,
      "async_process": true,
    });

    // Add the prompt to the history and avoid duplicates
    AppConfig.promptHistory.add(prompt);
    AppConfig.promptHistory = AppConfig.promptHistory.toSet().toList();

    // Send the request
    setState(() => isGenerating = true);
    final response = await http.post(url, headers: headers, body: body);

    // Extract job ID from response
    final data = jsonDecode(response.body);
    String jobID = data['job_id'];

    // Start progress tracking
    await followJobProgress(jobID);
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
        imageWidget(),
    
        // Thumbnail display area
        if (outputImages.isNotEmpty) imageCarousel(),
    
        // Download button and reset button
        if (!isShowingInputImage)
          Column(
            children: [
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [downloadButton(), resetButton()],
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
