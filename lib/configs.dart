// Flutter imports
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Configuration class for the app
class AppConfig {

  // App UI Configuration
  static ValueNotifier<Color> seedColor = ValueNotifier(Colors.blue);   
  static ValueNotifier<ThemeMode> appTheme = ValueNotifier(ThemeMode.system);

  // Server configuration
  static String ip = '10.0.0.73';
  static String port = '9090';

  // Models Configuration
  static List<String> modelTitles = [];
  static List<String> modelNames = [];
  static List<String> modelHashes = [];
  static int selectedModel = 0;
  static List<File> modelPreviews = []; // Not saved to SharedPreferences

  // Generation Configuration
  static List<String> samplersNames = [];
  static String selectedSampler = 'DPM++ 2M SDE';
  static int imageNumber = 1;
  static int stepsNumber = 50;
  static double guidanceScale = 3;
  static double denoiseStrength = 0.75;

  // Prompt Configuration
  static List<String> promptHistory = [];
  static String negativePrompts = '';

  // ===== Methods =====

  /// Save the configuration to SharedPreferences
  static Future<void> saveConfig() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // App UI configuration
    prefs.setString('seedColor', seedColor.value.value.toRadixString(16));
    
    // Server configuration
    prefs.setString('ip', ip);
    prefs.setString('port', port);

    // Models configuration
    prefs.setStringList('modelTitles', modelTitles);
    prefs.setStringList('modelNames', modelNames);
    prefs.setStringList('modelHashes', modelHashes);
    prefs.setInt('selectedModel', selectedModel);

    // Generation configuration
    prefs.setStringList('samplersNames', samplersNames);
    prefs.setString('selectedSampler', selectedSampler);
    prefs.setInt('imageNumber', imageNumber);
    prefs.setInt('stepsNumber', stepsNumber);
    prefs.setDouble('guidanceScale', guidanceScale);
    prefs.setDouble('denoiseStrength', denoiseStrength);
    
    // Prompt configuration
    prefs.setStringList('promptHistory', promptHistory);
    prefs.setString('negativePrompts', negativePrompts);
  }

  /// Load the configuration from SharedPreferences
  static Future<void> loadConfig() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // App UI configuration
    String? seedColorHex = prefs.getString('seedColor');
    if (seedColorHex != null) {
      seedColor.value = Color(int.parse(seedColorHex, radix: 16)).withOpacity(1.0);
    }
    
    // Server configuration
    ip = prefs.getString('ip') ?? '10.0.0.73';
    port = prefs.getString('port') ?? '9090';

    // Models configuration
    modelTitles = prefs.getStringList('modelTitles') ?? [];
    modelNames = prefs.getStringList('modelNames') ?? [];
    modelHashes = prefs.getStringList('modelHashes') ?? [];
    //selectedModel = prefs.getInt('selectedModel') ?? 0;

    // Generation configuration
    samplersNames = prefs.getStringList('samplersNames') ?? [];
    selectedSampler = prefs.getString('selectedSampler') ?? 'DPM++ 2M SDE';
    imageNumber = prefs.getInt('imageNumber') ?? 1;
    stepsNumber = prefs.getInt('stepsNumber') ?? 50;
    guidanceScale = prefs.getDouble('guidanceScale') ?? 3.0;
    denoiseStrength = prefs.getDouble('denoiseStrength') ?? 0.75;
    
    // Prompt configuration
    promptHistory = prefs.getStringList('promptHistory') ?? [];
    negativePrompts = prefs.getString('negativePrompts') ?? '';
  }
}
