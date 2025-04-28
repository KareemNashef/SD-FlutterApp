// Flutter imports
import 'package:flutter/material.dart';

// Local imports
import 'package:fooocus/configs.dart';
import 'package:fooocus/utils.dart';

class ServerSettingsPage extends StatefulWidget {
  @override
  _ServerSettingsPageState createState() => _ServerSettingsPageState();
}

class _ServerSettingsPageState extends State<ServerSettingsPage> {
  // ===== Class Variables =====

  // Text controllers
  final ipController = TextEditingController(text: AppConfig.ip);
  final portController = TextEditingController(text: AppConfig.port);
  
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

  // IP text field
  Widget IPField() {
    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(horizontal: 16),
      child: TextField(
        controller: ipController,
        decoration: InputDecoration(
          labelText: 'IP Address',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        onChanged: (value) => AppConfig.ip = value,
      ),
    );
  }


  // Port text field
  Widget portField() {
    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(horizontal: 16),
      child: TextField(
        controller: portController,
        decoration: InputDecoration(
          labelText: 'Port',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        onChanged: (value) => AppConfig.port = value,
      ),
    );
  }

  // Save configuration button
  Widget saveButton() {
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
          child: const Text('Save'),
        ),
      ),
    );
  }

  //  ===== Build Method =====

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Configuration')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // IP Text Field
            SizedBox(height: 16),
            IPField(),
            SizedBox(height: 16),
            portField(),
            SizedBox(height: 16),

            // Save button
            saveButton(),

          ],
        ),
      ),
    );
  }
}