// Flutter imports
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';

// Local imports
import 'package:fooocus/configs.dart';

// Function to check if the server is running
Future<bool> isServerRunning() async {
  try {
    // Send a GET request to the server
    final response = await http.get(
      Uri.parse(
        'http://${AppConfig.ip}:${AppConfig.port}/v1/engines/all-models',
      ),
    );

    // Check if the response status code is 200 (OK)
    return response.statusCode == 200;
  } catch (e) {
    // If an error occurs, return false
    return false;
  }
}

// Function to fetch models from the server
Future<List<String>> fetchModels() async {
  // Fetch models from the server
  final response = await http.get(
    Uri.parse('http://${AppConfig.ip}:${AppConfig.port}/v1/engines/all-models'),
  );

  // Parse the response body as JSON
  final data = jsonDecode(response.body);
  return List<String>.from(data["model_filenames"]);
}

// Function to fetch styles from the server
Future<List<String>> fetchStyles() async {
  // Fetch styles from the server
  final response = await http.get(
    Uri.parse('http://${AppConfig.ip}:${AppConfig.port}/v1/engines/styles'),
  );

  // Parse the response body as JSON
  final List<dynamic> data = jsonDecode(response.body);
  return data.cast<String>();
}

// Function to save a FILE image to local storage
Future<void> saveFile(File image) async {
  // Request storage permission
  await Permission.manageExternalStorage.request();

  // Get the path to save the image
  final dir = Directory('/storage/emulated/0/Pictures/Fooocus');
  if (!await dir.exists()) await dir.create(recursive: true);

  // Save to Pictures/Fooocus
  final newPath = '${dir.path}/image_${DateTime.now().millisecondsSinceEpoch}.png';
  await image.copy(newPath);
}
