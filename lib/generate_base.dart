// Flutter imports
import 'dart:io';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_exif_rotation/flutter_exif_rotation.dart';

// Local imports
import 'package:fooocus/configs.dart';
import 'package:fooocus/utils.dart';

class GeneratorBase extends StatefulWidget {
  const GeneratorBase({super.key});

  @override
  GeneratorBaseState createState() => GeneratorBaseState();
}

class GeneratorBaseState extends State<GeneratorBase> {
  // ===== Class Variables =====

  // Text controllers
  final TextEditingController promptController =
      TextEditingController(); // Prompt text controller

  // Image controllers
  File? inputImage; // Input image file
  File? outputImage; // Output image file
  List<File?> outputImages = []; // List of output images
  int outputImageIndex = 0; // Index of the output image
  bool isShowingInputImage = true; // Flag to show input image

  // Progress variables
  double jobProgress = 0.0; // Job progress percentage
  String jobStatus = 'unknown'; // Job status
  bool isGenerating = false; // Flag to indicate if generation is in progress
  Timer? progressTimer; // Timer for progress updates

  // ===== Helper Methods =====

  // Method to load an image from the gallery
  Future<void> pickImage() async {
    // Show image picker to select an image from the gallery
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);

    // If no image is picked, return
    if (picked == null) return;

    // Correct the image orientation using EXIF data
    final correctedImage = await FlutterExifRotation.rotateImage(
      path: picked.path,
    );

    // Save the image to the inputImage variable and update the state
    setState(() {
      inputImage = File(correctedImage.path);
    });
  }

  // Method to follow the progress of the job
  Future<void> followJobProgress(url, headers, body) async {
    // Start the generation process
    setState(() {
      isGenerating = true;
    });

    // Send the request
    http
        .post(url, headers: headers, body: body)
        .then((generationResponse) async {
          // Handle the response when it becomes available
          if (generationResponse.statusCode == 200) {
            try {
              final generationData = jsonDecode(generationResponse.body);
              final infoText = generationData['info'];
              File logFile = File('/storage/emulated/0/Pictures/Fooocus/debug_output.txt');
              await logFile.writeAsString(infoText, mode: FileMode.append);
              List<String> base64Images = List<String>.from(
                generationData['images'],
              );

              // Process the images
              for (var base64Str in base64Images) {
                final bytes = base64Decode(base64Str);
                final tempDir = Directory.systemTemp;
                final file = await File(
                  '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.png',
                ).writeAsBytes(bytes);
                outputImages.add(file);
              }

              // Update UI after processing images
              setState(() {
                outputImageIndex = 0;
                outputImage = outputImages[0];
                isShowingInputImage = false;
                isGenerating = false;
              });
            } catch (e) {
              print('Error parsing response: $e');
            }
          } else {
            print(
              'Request failed with status: ${generationResponse.statusCode}.',
            );
          }
        })
        .catchError((e) {
          print('Error during HTTP request: $e');
          // Handle errors
        });

    // Set the query URL for the job progress
    final queryUrl = Uri.parse(getProgressUrl());

    // Start the progress timer
    progressTimer = Timer.periodic(const Duration(milliseconds: 500), (
      timer,
    ) async {
      // Get a response from the server and decode it
      final response = await http.get(queryUrl);
      final data = jsonDecode(response.body);

      // Get the progress and status of the job
      final progress = data['progress'] ?? 0;
      final job = data['state']?['job'] ?? "";
      final currentImageBase64 = data['current_image'];

      // Update sync values
      setState(() {
        jobProgress = progress;

        if (currentImageBase64 != null) {
          final bytes = base64Decode(currentImageBase64);
          final tempDir = Directory.systemTemp;
          outputImage = File(
            '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.png',
          )..writeAsBytesSync(bytes); // Save the image as a temporary file
          isShowingInputImage = false;
        }
      });

      // If the job is finished
      if (job.isEmpty) {
        // Stop the timer
        progressTimer?.cancel();
      }
    });
  }

  // Method to convert a URL to a File
  Future<File> urlToFile(String url) async {
    // Get the image data from the URL
    final response = await http.get(
      Uri.parse(url),
      headers: {'User-Agent': 'Mozilla/5.0', 'Accept': 'image/*'},
    );
    final bytes = response.bodyBytes;

    // Create a temporary file and write the bytes to it
    final tempDir = Directory.systemTemp;
    final file = File(
      '${tempDir.path}/image_${DateTime.now().millisecondsSinceEpoch}.png',
    );
    await file.writeAsBytes(bytes);

    return file;
  }

  // Method to replace input image with output image
  void replaceInputImage() {
    setState(() {
      // Set the input image to the current output image
      inputImage = outputImages[outputImageIndex];

      // Reset the state
      resetState();
    });
  }

  // Method to reset the state
  void resetState() {
    setState(() {
      // Reset all variables to their initial state
      outputImage = null;
      outputImages = [];
      jobProgress = 0;
      jobStatus = 'unknown';
      isGenerating = false;
      isShowingInputImage = true;
    });
  }

  // Method to generate an image based on the prompt | Abstract
  Future<void> generateImage(String prompt) async {}

  // ===== Helper Widgets =====

  // Download button widget
  Widget downloadButton() {
    return ElevatedButton(
      // Button style
      style: ElevatedButton.styleFrom(
        shape: const CircleBorder(),
        padding: const EdgeInsets.all(12),
      ),

      // Button action
      onPressed: () async {
        // Save the image and show a snackbar message
        await saveFile(outputImage!);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image saved to Pictures/Fooocus')),
        );
      },

      // Button icon
      child: Icon(Icons.download, color: Colors.white),
    );
  }

  // Replace input image button widget
  Widget replaceInputImageButton() {
    return ElevatedButton.icon(
      // Button style
      style: ElevatedButton.styleFrom(
        shape: const StadiumBorder(),
        padding: const EdgeInsets.all(12),
      ),

      // Button action
      onPressed: replaceInputImage,

      // Button icon
      icon: const Icon(Icons.sync, color: Colors.white),

      // Button label
      label: const Text('Use as New Base'),
    );
  }

  // Reset button widget
  Widget resetButton() {
    return ElevatedButton(
      // Button style
      style: ElevatedButton.styleFrom(
        shape: const CircleBorder(),
        padding: const EdgeInsets.all(12),
      ),

      // Button action
      onPressed: () {
        // Reset the state
        resetState();
      },

      // Button icon
      child: Icon(Icons.replay, color: Colors.white),
    );
  }

  // Input field widget
  Widget inputField() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Text field for prompt input
          Expanded(
            child: TextField(
              // Text controller
              controller: promptController,

              // Text input decoration
              decoration: InputDecoration(
                hintText: "Enter your prompt here",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),

                // History button
                suffixIcon: IconButton(
                  // Button icon
                  icon: const Icon(Icons.history),

                  // Button action
                  onPressed:
                      () => showModalBottomSheet(
                        context: context,

                        // Bottom sheet shape
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(12),
                          ),
                        ),

                        // Bottom sheet content
                        builder:
                            (_) => Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(
                                    top: 16,
                                    bottom: 8,
                                  ),
                                  width: 40,
                                  height: 4,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[400],
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                                Expanded(
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: AppConfig.promptHistory.length,
                                    itemBuilder: (context, index) {
                                      final prompt =
                                          AppConfig.promptHistory[index];
                                      return Dismissible(
                                        key: Key(prompt),
                                        onDismissed: (_) {
                                          AppConfig.promptHistory.removeAt(
                                            index,
                                          );
                                        },
                                        background: Container(
                                          color: Colors.red,
                                        ),
                                        child: ListTile(
                                          title: Text(prompt),
                                          onTap: () {
                                            promptController.text = prompt;
                                            Navigator.pop(context);
                                          },
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                      ),
                ),
              ),

              // Text input height
              maxLines: 2,
            ),
          ),

          // Generate button
          Container(
            margin: const EdgeInsets.only(left: 8),
            child: FloatingActionButton(
              onPressed:
                  isGenerating
                      ? null
                      : () => generateImage(promptController.text),
              child:
                  isGenerating
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Icon(Icons.create),
            ),
          ),
        ],
      ),
    );
  }

  // Progress bar widget
  Widget progressBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: LinearProgressIndicator(value: jobProgress / 1.0),
    );
  }

  // Image widget
  Widget imageWidget() {
    return Container(
      child:
          isShowingInputImage
              ? inputImage != null
                  ? Image.file(inputImage!)
                  : const Icon(Icons.image, size: 64, color: Colors.grey)
              : outputImage != null
              ? Image.file(outputImage!)
              : const Icon(Icons.image, size: 64, color: Colors.grey),
    );
  }

  // Image carousel widget
  Widget imageCarousel() {
    return SizedBox(
      // Thumbnail height
      height: 100,

      // Thumbnail list builder
      child: ListView.builder(
        // List view properties
        scrollDirection: Axis.horizontal,
        itemCount: outputImages.length,

        // Item builder for each thumbnail
        itemBuilder: (context, index) {
          return GestureDetector(
            // Tap action
            onTap: () {
              setState(() {
                // Update the current output image index
                outputImageIndex = index;
                outputImage = outputImages[outputImageIndex];
              });
            },

            // Thumbnail container
            child: Container(
              // Border properties
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                border: Border.all(
                  color:
                      outputImageIndex == index
                          ? Theme.of(context).colorScheme.primary
                          : Colors.transparent,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(12),
              ),

              // Thumbnail image
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  outputImages[index] ?? File(''),
                  // Thumbnail properties
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  //  ===== Build Method =====

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
