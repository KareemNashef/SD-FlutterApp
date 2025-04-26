// Flutter imports
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Configuration class for the app
class AppConfig {

  // App configuration
  static ValueNotifier<Color> seedColor = ValueNotifier(Colors.blue);
  static ThemeMode appTheme = ThemeMode.system;
  static List<String> promptHistory = [];

  // Server configuration
  static String ip = '10.0.0.73';
  static String port = '9090';

  // Model and refiner configuration
  static String selectedModel = 'None';
  static String selectedRefiner = 'None';
  static double refinerStrength = 0.5;

  // Image generation configuration
  static List<String> selectedStyles = [];
  static String performanceSelection = 'Quality';
  static int imageNumber = 1;
  static double sharpness = 3.0;
  static double guidanceScale = 3;

  // Default negative prompts
  static String negativePrompts = '';

  // Save the configuration to a file
  static Future<void> saveConfig() async {
    
    // Get the instance of SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // App configuration
    prefs.setString('seedColor', seedColor.value.value.toRadixString(16));
    prefs.setString('appTheme', appTheme.toString());
    prefs.setStringList('promptHistory', promptHistory);

    // Server configuration
    prefs.setString('ip', ip);
    prefs.setString('port', port);

    // Model and refiner configuration
    prefs.setString('selectedModel', selectedModel);
    prefs.setString('selectedRefiner', selectedRefiner);
    prefs.setDouble('refinerStrength', refinerStrength);

    // Image generation configuration
    prefs.setStringList('selectedStyles', selectedStyles);
    prefs.setString('performanceSelection', performanceSelection);
    prefs.setInt('imageNumber', imageNumber);
    prefs.setDouble('sharpness', sharpness);
    prefs.setDouble('guidanceScale', guidanceScale);

    // Default negative prompts
    prefs.setString('negativePrompts', negativePrompts);
    
  }

  // Load the configuration from a file
  static Future<void> loadConfig() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // App configuration
    String? seedColorHex = prefs.getString('seedColor');
    if (seedColorHex != null) {
      seedColor.value = Color(int.parse(seedColorHex, radix: 16)).withOpacity(1.0);
    }
    promptHistory = prefs.getStringList('promptHistory') ?? [];
    
    // Server configuration
    ip = prefs.getString('ip') ?? '10.0.0.73';
    port = prefs.getString('port') ?? '9090';

    // Model and refiner configuration
    selectedModel = prefs.getString('selectedModel') ?? 'None';
    selectedRefiner = prefs.getString('selectedRefiner') ?? 'None';
    refinerStrength = prefs.getDouble('refinerStrength') ?? 0.5;

    // Image generation configuration
    selectedStyles = prefs.getStringList('selectedStyles') ?? [];
    performanceSelection = prefs.getString('performanceSelection') ?? 'Quality';
    imageNumber = prefs.getInt('imageNumber') ?? 1;
    sharpness = prefs.getDouble('sharpness') ?? 3.0;
    guidanceScale = prefs.getDouble('guidanceScale') ?? 3;

    // Default negative prompts
    negativePrompts = prefs.getString('negativePrompts') ?? '';

  }
}
