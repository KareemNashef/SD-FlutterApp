// Flutter imports
import 'package:flutter/material.dart';

// Local imports
import 'package:fooocus/configs.dart';

// Theme settings page
class ThemeSettingsPage extends StatelessWidget {
  const ThemeSettingsPage({super.key});

  // App theme selection bar
  Widget themeSelectionBar(context) {
    double _size = 120;
    double _sizePic = 100;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Light Theme
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: _size, // Increased size for better interaction
          height: _size,
          decoration: BoxDecoration(
            color:
                AppConfig.appTheme.value == ThemeMode.light
                    ? Theme.of(context).colorScheme.primary
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(12), // Circular border radius
            border: Border.all(
              width: 3,
              color:
                  AppConfig.appTheme.value == ThemeMode.light
                      ? Theme.of(context).colorScheme.primary
                      : Colors.transparent,
            ),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Light mode icon
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  'assets/light_mode.png',
                  width: _sizePic,
                  height: _sizePic,
                ),
              ),

              // Blurry Text background
              Positioned(
                bottom: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.black.withOpacity(0.5), // Blurry background
                  ),
                  child: Text(
                    'Light',
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ),
              ),
              // Tap Gesture to select Light theme
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    AppConfig.appTheme.value = ThemeMode.light;
                  },
                ),
              ),
            ],
          ),
        ),

        // Dark Theme
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: _size,
          height: _size,
          decoration: BoxDecoration(
            color:
                AppConfig.appTheme.value == ThemeMode.dark
                    ? Theme.of(context).colorScheme.primary
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(12), // Circular border radius
            border: Border.all(
              width: 3,
              color:
                  AppConfig.appTheme.value == ThemeMode.dark
                      ? Theme.of(context).colorScheme.primary
                      : Colors.transparent,
            ),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Dark mode icon
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  'assets/dark_mode.png',
                  width: _sizePic,
                  height: _sizePic,
                ),
              ),

              // Blurry Text background
              Positioned(
                bottom: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.black.withOpacity(0.5), // Blurry background
                  ),
                  child: Text(
                    'Dark',
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ),
              ),
              // Tap Gesture to select Dark theme
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    AppConfig.appTheme.value = ThemeMode.dark;
                  },
                ),
              ),
            ],
          ),
        ),

        // Auto Theme
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: _size,
          height: _size,
          decoration: BoxDecoration(
            color:
                AppConfig.appTheme.value == ThemeMode.system
                    ? Theme.of(context).colorScheme.primary
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(12), // Circular border radius
            border: Border.all(
              width: 3,
              color:
                  AppConfig.appTheme.value == ThemeMode.system
                      ? Theme.of(context).colorScheme.primary
                      : Colors.transparent,
            ),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Auto mode icon
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  'assets/auto_mode.png',
                  width: _sizePic,
                  height: _sizePic,
                ),
              ),

              // Blurry Text background
              Positioned(
                bottom: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.black.withOpacity(0.5), // Blurry background
                  ),
                  child: Text(
                    'Auto',
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ),
              ),
              // Tap Gesture to select Auto theme
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    AppConfig.appTheme.value = ThemeMode.system;
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Color button
  Widget colorButton(context, Color color) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        fixedSize: const Size(350, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12), // Circular 12 border
        ),
        backgroundColor: color,
        side: BorderSide(
          color:
              AppConfig.seedColor.value == color
                  ? Theme.of(context)
                      .colorScheme
                      .primary // Use primary color for border
                  : Colors.transparent, // No border if color doesn't match
          width: 6, // Adjust the width of the border
        ),
      ),
      onPressed: () {
        AppConfig.seedColor.value = color; // Set seedColor
      },
      child:
          const SizedBox.shrink(), // Empty child since we're using the button for background only
    );
  }

  // App color selection bar
  Widget colorSelectionBar(context) {
    return Column(
      children: [
        colorButton(context, Color(0xFF3f51b5)),
        SizedBox(height: 16),
        colorButton(context, Color(0xFFff5722)),
        SizedBox(height: 16),
        colorButton(context, Color(0xFF4caf50)),
        SizedBox(height: 16),
        colorButton(context, Color(0xFF2196f3)),
        SizedBox(height: 16),
        colorButton(context, Color(0xFF795548)),
        SizedBox(height: 16),
        colorButton(context, Color(0xFF9c27b0)),
        SizedBox(height: 16),
        colorButton(context, Color(0xFF607d8b)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Theme")),
      body: SingleChildScrollView(
        child: Column(
          children: [
            themeSelectionBar(context),
            SizedBox(height: 16),
            colorSelectionBar(context),
          ],
        ),
      ),
    );
  }
}
