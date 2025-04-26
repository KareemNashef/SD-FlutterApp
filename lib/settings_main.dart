// Flutter imports
import 'package:flutter/material.dart';

// Local imports
import 'package:fooocus/configs.dart';
import 'package:fooocus/utils.dart';

// Settings page main
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

// State class for the settings page
class _SettingsPageState extends State<SettingsPage> {
  // Class variables
  final ipController = TextEditingController(text: AppConfig.ip);
  final portController = TextEditingController(text: AppConfig.port);
  final negativePromptsController = TextEditingController(
    text: AppConfig.negativePrompts,
  );
  List<String> _models = [];
  String? _selectedModel;
  String? _selectedRefiner;
  List<String> _styles = [];
  int _selectedIndex = 0;

  // Class functions

  // Check if the server is reachable
  Future<bool> _isServerReachable() async {
    return await isServerRunning();
  }

  // Fetch models from the server
  void _fetchModels() async {
    final models = await fetchModels();
    setState(() {
      _models = models;
    });
  }

  // Fetch styles from the server
  void _fetchStyles() async {
    final styles = await fetchStyles();
    setState(() {
      _styles = styles;
    });
  }

  // Initialize the state
  @override
  void initState() {
    super.initState();

    // Fetch settings when the page is initialized
    _fetchModels();
    _fetchStyles();
    _selectedIndex = ['Quality', 'Speed', 'Extreme Speed']
        .indexOf(AppConfig.performanceSelection);
    _selectedModel = AppConfig.selectedModel;
    _selectedRefiner = AppConfig.selectedRefiner;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // App Settings title
          const SizedBox(height: 24),
          Text(
            "App Settings",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),

          // App color selection
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Indigo
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  shape: const CircleBorder(),
                  side: const BorderSide(width: 8, color: Color(0xFF3f51b5)),
                  fixedSize: const Size(60, 60),
                  backgroundColor:
                      AppConfig.seedColor.value == Color(0xFF3f51b5)
                          ? Color(0xFF3f51b5)
                          : Colors.transparent,
                ),
                onPressed: () {
                  AppConfig.seedColor.value = Color(0xFF3f51b5);
                },
                child: const SizedBox.shrink(),
              ),

              // Teal
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  shape: const CircleBorder(),
                  side: const BorderSide(width: 8, color: Color(0xFF019285)),
                  fixedSize: const Size(60, 60),
                  backgroundColor:
                      AppConfig.seedColor.value == Color(0xFF019285)
                          ? Color(0xFF019285)
                          : Colors.transparent,
                ),
                onPressed: () {
                  AppConfig.seedColor.value = Color(0xFF019285);
                },
                child: const SizedBox.shrink(),
              ),

              // Yellow
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  shape: const CircleBorder(),
                  side: const BorderSide(width: 8, color: Color(0xFFffeb3b)),
                  fixedSize: const Size(60, 60),
                  backgroundColor:
                      AppConfig.seedColor.value == Color(0xFFffeb3b)
                          ? Color(0xFFffeb3b)
                          : Colors.transparent,
                ),
                onPressed: () {
                  AppConfig.seedColor.value = Color(0xFFffeb3b);
                },
                child: const SizedBox.shrink(),
              ),

              // Deep Orange
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  shape: const CircleBorder(),
                  side: const BorderSide(width: 8, color: Color(0xFFff5722)),
                  fixedSize: const Size(60, 60),
                  backgroundColor:
                      AppConfig.seedColor.value == Color(0xFFff5722)
                          ? Color(0xFFff5722)
                          : Colors.transparent,
                ),
                onPressed: () {
                  AppConfig.seedColor.value = Color(0xFFff5722);
                },
                child: const SizedBox.shrink(),
              ),

              // Pink
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  shape: const CircleBorder(),
                  side: const BorderSide(width: 8, color: Colors.pink),
                  fixedSize: const Size(60, 60),
                  backgroundColor:
                      AppConfig.seedColor.value == Colors.pink
                          ? Colors.pink
                          : Colors.transparent,
                ),
                onPressed: () {
                  AppConfig.seedColor.value = Colors.pink;
                },
                child: const SizedBox.shrink(),
              ),
            ],
          ),

          // ===== Divider =====
          const SizedBox(height: 24),
          Divider(thickness: 2, color: Theme.of(context).colorScheme.primary),
          // ===== Divider =====

          // Server Settings title
          const SizedBox(height: 24),
          Text(
            "Server Settings",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),

          // Server IP
          const SizedBox(height: 24),
          const Text("IP Address", style: TextStyle(fontSize: 16)),
          TextField(controller: ipController),

          // Server Port
          const SizedBox(height: 24),
          const Text("Port", style: TextStyle(fontSize: 16)),
          TextField(
            controller: portController,
            keyboardType: TextInputType.number,
          ),

          // Apply button
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                // Update the Config with the current values from controllers
                AppConfig.ip = ipController.text.trim();
                AppConfig.port = portController.text.trim();

                // Check if the IP and port are valid
                if (AppConfig.ip.isEmpty || AppConfig.port.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Please enter valid IP and port"),
                      duration: Duration(seconds: 2),
                    ),
                  );
                  return;
                }

                // Check if the server is reachable
                if (await _isServerReachable()) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Connected to server successfully"),
                      duration: Duration(seconds: 2),
                    ),
                  );
                  return;
                }

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Server is not reachable"),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              child: const Text("Apply"),
            ),
          ),

          // ===== Divider =====
          const SizedBox(height: 24),
          Divider(thickness: 2, color: Theme.of(context).colorScheme.primary),
          // ===== Divider =====

          // Model Settings title
          const SizedBox(height: 24),
          Text(
            "Model Settings",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),

          // Model selection
          const SizedBox(height: 24),
          const Text("Models", style: TextStyle(fontSize: 16)),
          const SizedBox(height: 8),

          // Model dropdown
          Row(
            children: [
              Expanded(
                child: DropdownButton<String>(
                  value: _selectedModel,
                  hint: const Text("Select a model"),
                  isExpanded: true,
                  itemHeight: 64,
                  items:
                      [
                        if (_selectedModel != null &&
                            !_models.contains(_selectedModel))
                          _selectedModel!,
                        ..._models,
                      ].map((model) {
                        return DropdownMenuItem(
                          value: model,
                          child: Text(
                            model,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedModel = value;
                      AppConfig.selectedModel = value ?? "None";
                    });
                  },
                ),
              ),
            ],
          ),
          // Refiner selection
          const SizedBox(height: 24),
          const Text("Refiner", style: TextStyle(fontSize: 16)),
          const SizedBox(height: 8),

          // Refiner dropdown
          Row(
            children: [
              Expanded(
                child: DropdownButton<String>(
                  value: _selectedRefiner,
                  hint: const Text("Select a model"),
                  isExpanded: true,
                  itemHeight: 64,
                  items:
                      ['None', ..._models].map((model) {
                        return DropdownMenuItem(
                          value: model,
                          child: Text(
                            model,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedRefiner = value;
                      AppConfig.selectedRefiner = value ?? "None";
                    });
                  },
                ),
              ),
            ],
          ),

          // Refiner Strength Slider
          const SizedBox(height: 24),
          const Text("Refiner Strength"),
          Slider(
            value: AppConfig.refinerStrength,
            min: 0,
            max: 1,
            divisions: 10,
            label: AppConfig.refinerStrength.toString(),
            onChanged: (value) {
              setState(() {
                AppConfig.refinerStrength = value;
              });
            },
          ),

          // Refresh button
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _fetchModels,
              child: const Text("Refresh Models"),
            ),
          ),

          // ===== Divider =====
          const SizedBox(height: 24),
          Divider(thickness: 2, color: Theme.of(context).colorScheme.primary),
          // ===== Divider =====

          // Image Generation Settings title
          const SizedBox(height: 24),
          Text(
            "Image Generation Settings",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),

          // Performance selection
          const SizedBox(height: 24),
          ToggleButtons(
            isSelected: List.generate(3, (index) => index == _selectedIndex),
            onPressed: (int index) {
              setState(() {
                _selectedIndex = index;
                AppConfig.performanceSelection =
                    ['Quality', 'Speed', 'Extreme Speed'][index];
              });
            },
            borderRadius: BorderRadius.circular(30), // Make them round

            children: const [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text('Quality'),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text('Speed'),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text('Extreme Speed'),
              ),
            ],
          ),

          // Number of Images
          const SizedBox(height: 24),
          const Text("Number of Images"),
          Slider(
            value: AppConfig.imageNumber.toDouble(),
            min: 1,
            max: 5,
            divisions: 4,
            label: AppConfig.imageNumber.toString(),
            onChanged: (value) {
              setState(() {
                AppConfig.imageNumber = value.toInt();
              });
            },
          ),

          // Sharpness
          const SizedBox(height: 24),
          const Text("Sharpness"),
          Slider(
            value: AppConfig.sharpness,
            min: 1,
            max: 10,
            divisions: 18,
            label: AppConfig.sharpness.toStringAsFixed(1),
            onChanged: (value) {
              setState(() {
                AppConfig.sharpness = value;
              });
            },
          ),

          // Guidance Scale
          const SizedBox(height: 24),
          const Text("Guidance Scale"),
          Slider(
            value: AppConfig.guidanceScale,
            min: 1,
            max: 10,
            divisions: 18,
            label: AppConfig.guidanceScale.toStringAsFixed(1),
            onChanged: (value) {
              setState(() {
                AppConfig.guidanceScale = value;
              });
            },
          ),

          // Style selection
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                _fetchStyles();
                showDialog(
                  context: context,
                  builder: (context) {
                    return StatefulBuilder(
                      builder: (context, setState) {
                        return AlertDialog(
                          title: const Text('Select Styles'),
                          content: SingleChildScrollView(
                            child: Column(
                              children:
                                  _styles.map((style) {
                                    final isSelected = AppConfig.selectedStyles
                                        .contains(style);
                                    return CheckboxListTile(
                                      title: Text(style),
                                      value: isSelected,
                                      onChanged: (checked) {
                                        setState(() {
                                          if (checked == true) {
                                            AppConfig.selectedStyles.add(style);
                                          } else {
                                            AppConfig.selectedStyles.remove(style);
                                          }
                                        });
                                      },
                                    );
                                  }).toList(),
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Close'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                );
              },
              child: const Text("Select Styles"),
            ),
          ),

          // Negative Prompts
          const SizedBox(height: 24),
          Text(
            "Negative Prompts",
            style: TextStyle(
              fontSize: 18, // Larger font size
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary, // Main theme color
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: negativePromptsController,
            decoration: const InputDecoration(
              hintText: "Enter negative prompts (e.g., blurry, bad quality)",
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),

          // Save Button
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                // Update the Config with the current values from controllers
                AppConfig.ip = ipController.text.trim();
                AppConfig.port = portController.text.trim();
                AppConfig.negativePrompts = negativePromptsController.text.trim();

                await AppConfig.saveConfig();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Config saved successfully!")),
                );
              },
              child: const Text("Save"),
            ),
          ),
        ],
      ),
    );
  }
}
