// Flutter imports
import 'package:flutter/material.dart';

// Local imports
import 'package:fooocus/configs.dart';
import 'package:fooocus/utils.dart';
import 'package:fooocus/settings_theme.dart';
import 'package:fooocus/settings_model.dart';
import 'package:fooocus/settings_generation.dart';
import 'package:fooocus/settings_config.dart';

// Settings page main
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

// State class for the settings page
class _SettingsPageState extends State<SettingsPage> {
  // ===== Class Variables =====

  // Text controllers
  final ipController = TextEditingController(text: AppConfig.ip);
  final portController = TextEditingController(text: AppConfig.port);

  // ===== Helper Methods =====

  // Initialize the state
  @override
  void initState() {
    super.initState();

    // Fetch settings when the page is initialized
    fetchModels();
    fetchSamplers();
  }

  // ===== Helper Widgets =====

  // Big title widget
  Widget bigTitle(String title) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
      ),
    );
  }

  // Small title widget
  Widget smallTitle(String title) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  // Settings entry widget with icon
  Widget settingsEntry(IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          // Icon on the left
          Icon(icon, size: 24, color: Colors.grey),
          SizedBox(width: 12), // Space between icon and title
          // Column for title and description
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title with font size 18
              Text(
                title,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              // Description with smaller font size
              SizedBox(height: 4), // Adds space between title and description
              // Wrap description in a Text widget with overflow handling
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: 200,
                ), // Set max width for the description
                child: Text(
                  description,
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                  softWrap: true, // Allow wrapping
                  overflow:
                      TextOverflow.ellipsis, // Truncate with ellipsis if needed
                  maxLines: 2, // Limit to two lines
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // List tile entry widget
  Widget listTileEntry(
    IconData icon,
    String title,
    String description,
    Widget page,
  ) {
    return ListTile(
      tileColor: Theme.of(context).colorScheme.surfaceBright,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      title: settingsEntry(icon, title, description),
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => page));
      },
    );
  }

  // Save configuration button
  Widget saveButton(context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          // Button style
          
          style: ElevatedButton.styleFrom(
            shape: const StadiumBorder(),
            padding: const EdgeInsets.all(12),
          ),
          // Button action
          onPressed: () async {await AppConfig.saveConfig();
          
          // Show a snackbar message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Configuration saved')),
          );
          },
          // Button label
          child: const Text('Save configuration'),
        ),
      ),
    );
  }

  //  ===== Build Method =====

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(8, 80, 8, 0),
      children: [
        // Settings title
        bigTitle("Settings"),

        // Theme settings
        smallTitle("App Settings"),

        // List entry - Theme settings page
        listTileEntry(
          Icons.color_lens,
          "Theme",
          "Change the theme of the app",
          ThemeSettingsPage(),
        ),

        // Generation settings
        smallTitle("Server Settings"),

        // List entry - Server settings page
        listTileEntry(
          Icons.settings,
          "Server",
          "Change the server settings",
          ServerSettingsPage(),
        ),
        SizedBox(height: 8),
        // List entry - Model settings page
        listTileEntry(
          Icons.image,
          "Model",
          "Change the used model",
          ModelsSettingsPage(),
        ),

        SizedBox(height: 8),

        // List entry - Generation settings page
        listTileEntry(
          Icons.image,
          "Generation",
          "Change the used image generation settings",
          GenerationSettingsPage(),
        ),

        // Save configuration button
        saveButton(context),
      
      ],
    );
  }
}
