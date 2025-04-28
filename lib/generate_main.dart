// Flutter imports
import 'package:flutter/material.dart';

// Local imports
import 'package:fooocus/generate_text2img.dart';
import 'package:fooocus/generate_inpaint.dart';
import 'package:fooocus/generate_outpaint.dart';
import 'package:fooocus/generate_img2img.dart';

// Generate page main
class GeneratePage extends StatefulWidget {
  const GeneratePage({super.key});
  @override
  _GeneratePageState createState() => _GeneratePageState();
}

// State class for the generate page
class _GeneratePageState extends State<GeneratePage> {
  // Class variables
  int _selectedOptionIndex = -1;

  // Define the pages for each option
  final List<Widget> _generatePages = [
    TextToImagePage(),
    ImageToImagePage(),
    //OutpaintImagePage(),
    InpaintImagePage(),
  ];

  // Define the titles for each option
  final List<String> _pageTitles = [
    'Text to Image',
    'Image to Image',
    //'Outpaint Image',
    'Inpaint Image',
  ];

  @override
  Widget build(BuildContext context) {
    // Set the back button to return to the previous page
    return PopScope(
      canPop: _selectedOptionIndex == -1,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _selectedOptionIndex != -1) {
          setState(() {
            _selectedOptionIndex = -1;
          });
        }
      },
      child: Scaffold(
        // AppBar with title and back button
        appBar: AppBar(
          // Page title based on selected option
          title: Text(
            _selectedOptionIndex == -1
                ? 'Generate'
                : _pageTitles[_selectedOptionIndex],
          ),

          // Only show back button when an option is selected
          leading:
              _selectedOptionIndex != -1
                  ? IconButton(
                    icon: Icon(Icons.arrow_back),
                    onPressed: () {
                      setState(() {
                        _selectedOptionIndex = -1;
                      });
                    },
                  )
                  : null,
        ),

        // Main content of the page
        body:
            // If no option is selected, show the list of options
            _selectedOptionIndex == -1
                ? GridView.count(
                  crossAxisCount: 1,
                  childAspectRatio: 2,
                  children: [
                    // Text to Image option
                    _buildOptionItem(Icons.text_fields, 'Text to Image', 0),

                    // Image to Image option
                    _buildOptionItem(Icons.sync_alt, 'Image to Image', 1),

                    // Outpaint Image option
                    //_buildOptionItem(Icons.expand, 'Outpaint Image', 2),
                    
                    // Inpaint Image option
                    _buildOptionItem(Icons.brush, 'Inpaint Image', 2),

                  ],
                )
                // If an option is selected, show the corresponding page
                : _generatePages[_selectedOptionIndex],
      ),
    );
  }

  // Helper method to build each option item (with icon and text)
  Widget _buildOptionItem(IconData icon, String text, int index) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Center(
          child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
          Text(text, style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 24),
          Icon(icon, size: 32),
                ],
          ),
        ),
        
        onTap: () {
          setState(() {
            _selectedOptionIndex = index; // Set the selected option index
          });
        },
      ),
    );
  }
}
