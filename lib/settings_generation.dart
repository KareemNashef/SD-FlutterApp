// Flutter imports
import 'package:flutter/material.dart';

// Local imports
import 'package:fooocus/configs.dart';

class GenerationSettingsPage extends StatefulWidget {
  @override
  _GenerationSettingsPageState createState() => _GenerationSettingsPageState();
}

class _GenerationSettingsPageState extends State<GenerationSettingsPage> {
  // ===== Class Variables =====

  // Text controllers
  final negativePromptsController = TextEditingController(
    text: AppConfig.negativePrompts,
  );  
  
  // ===== Helper Widgets =====

  // Small title widget
  Widget smallTitle(String title) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // Sampler selection widget
  Widget samplerSelector() {
    return Padding(
  padding: const EdgeInsets.all(16),
  child: DropdownButtonFormField<String>(
    value: AppConfig.selectedSampler,
    decoration: InputDecoration(
      labelText: 'Sampler',
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),
    items: AppConfig.samplersNames.map((name) {
      return DropdownMenuItem<String>(
        value: name,
        child: Text(name),
      );
    }).toList(),
    onChanged: (newValue) {
      if (newValue != null) {
        AppConfig.selectedSampler = newValue;
      }
    },
  ),
);
  }

  // Image number slider
  Widget imageNumberSlider() {
    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(horizontal: 16),
      child: Slider(
        value: AppConfig.imageNumber.toDouble(),
        min: 1,
        max: 10,
        divisions: 9,
        label: AppConfig.imageNumber.toString(),
        onChanged: (v) => setState(() => AppConfig.imageNumber = v.toInt()),
      ),
    );
  }

  // Steps number slider
  Widget stepsNumberSlider() {
    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(horizontal: 16),
      child: Slider(
        value: AppConfig.stepsNumber.toDouble(),
        min: 1,
        max: 100,
        divisions: 99,
        label: AppConfig.stepsNumber.toString(),
        onChanged: (v) => setState(() => AppConfig.stepsNumber = v.toInt()),
      ),
    );
  }

  // Guidance scale slider
  Widget guidanceScaleSlider() {
    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(horizontal: 16),
      child: Slider(
        value: AppConfig.guidanceScale.toDouble(),
        min: 1,
        max: 10,
        divisions: 18,
        label: AppConfig.guidanceScale.toString(),
        onChanged: (v) => setState(() => AppConfig.guidanceScale = v),
      ),
    );
  }

  // Denoise strength slider
  Widget denoiseStrengthSlider() {
    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(horizontal: 16),
      child: Slider(
        value: AppConfig.denoiseStrength.toDouble(),
        min: 0,
        max: 1,
        divisions: 20,
        label: AppConfig.denoiseStrength.toString(),
        onChanged: (v) => setState(() => AppConfig.denoiseStrength = v),
      ),
    );
  }

  // Negative prompts text field
  Widget negativePromptsField() {
    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(horizontal: 16),
      child: TextField(
        maxLines: 5,
        controller: negativePromptsController,
        decoration: InputDecoration(
          labelText: 'Negative Prompts',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        onChanged: (value) => AppConfig.negativePrompts = value,
      ),
    );
  }

  //  ===== Build Method =====

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Generation')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // Sampler selection widget
            samplerSelector(),

            // Image number slider
            smallTitle('Number of images to generate:'),
            imageNumberSlider(),

            // Steps number slider
            smallTitle('Number of steps:'),
            stepsNumberSlider(),

            // Guidance scale slider
            smallTitle('Guidance scale:'),
            guidanceScaleSlider(),

            // Denoise strength slider
            smallTitle('Denoise strength:'),
            denoiseStrengthSlider(),

            // Negative prompts text field
            smallTitle('Negative prompts:'),
            negativePromptsField(),

          ],
        ),
      ),
    );
  }
}
