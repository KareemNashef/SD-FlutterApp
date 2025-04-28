// Flutter imports
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

// Local imports
import 'package:fooocus/configs.dart';

// Models settings page
class ModelsSettingsPage extends StatefulWidget {
  const ModelsSettingsPage({super.key});

  @override
  ModelsSettingsPageState createState() => ModelsSettingsPageState();
}

class ModelsSettingsPageState extends State<ModelsSettingsPage> {
  // Cache for image dimensions to prevent recalculation
  final Map<int, Size> _imageSizeCache = {};

  @override
  void initState() {
    super.initState();
    // Pre-load all image dimensions
    for (int i = 0; i < AppConfig.modelPreviews.length; i++) {
      _getImageSize(AppConfig.modelPreviews[i], i);
    }
  }

  // Load image dimensions and cache them
  Future<void> _getImageSize(File imageFile, int index) async {
    if (_imageSizeCache.containsKey(index)) return;

    // final Completer<Size> completer = Completer();
    final Image image = Image.file(imageFile);
    image.image
        .resolve(const ImageConfiguration())
        .addListener(
          ImageStreamListener((ImageInfo info, bool _) {
            final Size size = Size(
              info.image.width.toDouble(),
              info.image.height.toDouble(),
            );
            _imageSizeCache[index] = size;
            if (mounted) setState(() {});
          }),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Models')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: MasonryGridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          itemCount: AppConfig.modelNames.length,
          itemBuilder: (context, index) {
            // Determine if this is the selected model
            bool isSelected = AppConfig.selectedModel == index;

            return AnimatedContainer(
              duration: Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color:
                        isSelected
                            ? Theme.of(
                              context,
                            ).colorScheme.primary.withValues(alpha: 0.2)
                            : Colors.black.withValues(alpha: 0.1),
                    blurRadius: isSelected ? 8 : 4,
                    spreadRadius: isSelected ? 2 : 0,
                  ),
                ],
              ),
              child: ModelCard(
                index: index,
                isSelected: isSelected,
                imageSizeCache: _imageSizeCache,
                onTap: () {
                  setState(() {
                    AppConfig.selectedModel = index;
                  });
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

// Separate stateful widget for each card to isolate rebuilds
class ModelCard extends StatelessWidget {
  final int index;
  final bool isSelected;
  final Map<int, Size> imageSizeCache;
  final VoidCallback onTap;

  const ModelCard({
    super.key,
    required this.index,
    required this.isSelected,
    required this.imageSizeCache,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Card(
        margin: EdgeInsets.zero,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color:
                isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Colors.transparent,
            width: 2.0,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              child:
                  imageSizeCache.containsKey(index)
                      ? Image.file(
                        AppConfig.modelPreviews[index],
                        width: double.infinity,
                        fit: BoxFit.fitWidth,
                      )
                      : AspectRatio(
                        aspectRatio: 1.0,
                        child: Center(child: CircularProgressIndicator()),
                      ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                AppConfig.modelNames[index],
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color:
                      isSelected ? Theme.of(context).colorScheme.primary : null,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
