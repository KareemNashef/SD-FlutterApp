// Flutter imports
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';

// Local imports
import 'package:fooocus/configs.dart';

// ========== Helper Functions ==========

// Function to save a FILE image to local storage
Future<void> saveFile(File image) async {
  // Request storage permission
  await Permission.manageExternalStorage.request();

  // Get the path to save the image
  final dir = Directory('/storage/emulated/0/Pictures/Fooocus');
  if (!await dir.exists()) await dir.create(recursive: true);

  // Save to Pictures/Fooocus
  final newPath =
      '${dir.path}/image_${DateTime.now().millisecondsSinceEpoch}.png';
  await image.copy(newPath);
}

// Function to get model preview image
Future<File> getModelPreview(String hash) async {
  // Construct the cache directory and the image file path
  final directory = await getTemporaryDirectory();
  final cacheFile = File('${directory.path}/$hash.jpg');

  // Check if the image already exists in the cache
  if (await cacheFile.exists()) {
    // Return the cached file if it exists
    return cacheFile;
  } else {
    // Image doesn't exist, so fetch it from Civitai API
    final modelData = await http.get(
      Uri.parse('https://civitai.com/api/v1/model-versions/by-hash/$hash'),
    );

    if (modelData.statusCode == 200) {
      // Parse the JSON response to get the image URL
      final data = jsonDecode(modelData.body);
      final imageUrl = data['images'][0]['url'];

      // Now, download the image
      final response = await http.get(Uri.parse(imageUrl));

      if (response.statusCode == 200) {
        // Save the image to the cache directory
        await cacheFile.writeAsBytes(response.bodyBytes);
        // Return the newly downloaded file
        return cacheFile;
      } else {
        throw Exception("Failed to download image");
      }
    } else {
      throw Exception("Failed to fetch model data");
    }
  }
}

// ========== Server URLs ==========

// Models URL
String getModelsUrl() {
  return 'http://${AppConfig.ip}:${AppConfig.port}/sdapi/v1/sd-models';
}

// Samplers URL
String getSamplersUrl() {
  return 'http://${AppConfig.ip}:${AppConfig.port}/sdapi/v1/samplers';
}

// Options URL
String getOptionsUrl() {
  return 'http://${AppConfig.ip}:${AppConfig.port}/sdapi/v1/options';
}

// Text to Image URL
String getTextToImageUrl() {
  return 'http://${AppConfig.ip}:${AppConfig.port}/sdapi/v1/txt2img';
}

// Image to Image URL
String getImageToImageUrl() {
  return 'http://${AppConfig.ip}:${AppConfig.port}/sdapi/v1/img2img';
}

// Progress URL
String getProgressUrl() {
  return 'http://${AppConfig.ip}:${AppConfig.port}/sdapi/v1/progress?skip_current_image=false';
}

// ========== Server Calls ==========

// Function to check if the server is running
Future<bool> isServerRunning() async {
  // Send a GET request to the server
  final response = await http.get(Uri.parse(getOptionsUrl()));

  // Check if the response status code is 200 (OK)
  return response.statusCode == 200;
}

// Function to fetch models from the server
Future<void> fetchModels() async {
  // Fetch models from the server
  final response = await http.get(Uri.parse(getModelsUrl()));

  // Parse the response body as JSON
  final data = jsonDecode(response.body);

  print(data);

  // Save the models to the config
  AppConfig.modelTitles = (data as List).map((item) => item['title'] as String).toList();
  AppConfig.modelNames = (data).map((item) => item['model_name'] as String).toList();
  AppConfig.modelHashes = (data).map((item) => item['hash'] as String).toList();

  // Populate the model previews
  for (int i = 0; i < AppConfig.modelHashes.length; i++) {
    AppConfig.modelPreviews.add(
      await getModelPreview(AppConfig.modelHashes[i]),
    );
  }
}

// Function to set model
Future<void> setModel() async {
  // Send a POST request to the server
  
  await http.post(
    Uri.parse(getOptionsUrl()),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      "sd_model_checkpoint": AppConfig.modelTitles[AppConfig.selectedModel],
    }),
  );
}

// Function to fetch samplers from the server
Future<void> fetchSamplers() async {
  // Fetch samplers from the server
  final response = await http.get(Uri.parse(getSamplersUrl()));

  // Parse the response body as JSON
  final data = jsonDecode(response.body);

  // Save the samplers to the config
  AppConfig.samplersNames = (data as List).map((item) => item['name'] as String).toList();

}
