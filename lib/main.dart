// Flutter imports
import 'package:flutter/material.dart';

// Local imports
import 'package:fooocus/configs.dart';
import 'package:fooocus/generate_main.dart';
import 'package:fooocus/settings_main.dart';

// Main function of the app
void main() async {
  // Ensure that plugin services are initialized and load the configuration
  WidgetsFlutterBinding.ensureInitialized();
  await AppConfig.loadConfig();

  // Run the app
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();

    // Listen for changes in the seed color and update the app theme
    AppConfig.seedColor.addListener(() {
      setState(() {});
    });

    // Listen for changes in the app theme and update the app theme
    AppConfig.appTheme.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    // Dispose of the seed color listener
    AppConfig.seedColor.removeListener(() {});

    // Dispose of the app theme listener
    AppConfig.appTheme.removeListener(() {});
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      
      // Light theme
      theme: ThemeData.from(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppConfig.seedColor.value,
          brightness: Brightness.light,
        ),
      ),

      // Dark theme
      darkTheme: ThemeData.from(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppConfig.seedColor.value,
          brightness: Brightness.dark,
        ),
      ),

      // Theme toggle
      themeMode: AppConfig.appTheme.value,

      // Home page of the app
      home: const MainPage(),
    );
  }
}

// Main page of the app
class MainPage extends StatefulWidget {
  const MainPage({super.key});
  @override
  State<MainPage> createState() => _MainPageState();
}

// State class for the main page
class _MainPageState extends State<MainPage> {
  // Class variables
  int _currentIndex = 0;

  // Create persistent instances of both pages
  final GeneratePage _generatePage = GeneratePage();
  final SettingsPage _settingsPage = const SettingsPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Current page
      body: IndexedStack(
        index: _currentIndex,
        children: [_generatePage, _settingsPage],
      ),

      // Bottom navigation bar
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (int index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.photo), label: 'Generate'),
          NavigationDestination(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}
