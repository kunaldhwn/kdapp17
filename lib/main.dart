import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Using DynamicColorBuilder to support Material You theming
    return DynamicColorBuilder(
      builder: (lightColorScheme, darkColorScheme) {
        return MaterialApp(
          title: 'AI Caption Generator',
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: lightColorScheme ?? ColorScheme.fromSeed(seedColor: Colors.blueAccent),
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            colorScheme: darkColorScheme ?? ColorScheme.fromSeed(seedColor: Colors.blueAccent, brightness: Brightness.dark),
          ),
          themeMode: ThemeMode.system, // Automatically switch between light and dark theme
          home: const MyHomePage(title: 'AI Instagram Caption Generator'),
        );
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // State variables to hold the selected image, the generated caption, and loading status
  XFile? _imageFile;
  String _caption = 'Select an image and generate a caption!';
  bool _isLoading = false;

  // Instance of ImagePicker to handle image selection
  final ImagePicker _picker = ImagePicker();

  // --- Function to pick an image from the gallery ---
  Future<void> _pickImage() async {
    try {
      // Use the image picker to select an image from the gallery
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

      setState(() {
        if (pickedFile != null) {
          _imageFile = pickedFile;
          _caption = 'Image selected! Ready to generate a caption.'; // Reset caption
        }
      });
    } catch (e) {
      // Handle any potential errors, e.g., permissions denied
      setState(() {
        _caption = "Error picking image: $e";
      });
    }
  }

  // --- Function to generate a caption using the Gemini API ---
  Future<void> _generateCaption() async {
    // Ensure an image has been selected
    if (_imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an image first.')),
      );
      return;
    }

    // Set loading state to true to show a progress indicator
    setState(() {
      _isLoading = true;
      _caption = 'Generating your caption...';
    });

    // The API key is left empty; the environment will provide it.
    const apiKey = "";
    final url = Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$apiKey');

    try {
      // Read the image file as bytes and encode it to base64
      final imageBytes = await _imageFile!.readAsBytes();
      final base64Image = base64Encode(imageBytes);

      // The prompt for the AI model
      const prompt = "Write a witty and engaging Instagram caption for this image. Include relevant hashtags.";

      // Construct the request body for the Gemini API
      final requestBody = jsonEncode({
        "contents": [
          {
            "parts": [
              {"text": prompt},
              {
                "inline_data": {
                  "mime_type": "image/jpeg", // Assuming JPEG, change if necessary
                  "data": base64Image
                }
              }
            ]
          }
        ]
      });

      // Make the POST request
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: requestBody,
      );

      // Handle the response
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Extract the text from the API response
        final generatedText = data['candidates'][0]['content']['parts'][0]['text'];
        setState(() {
          _caption = generatedText;
        });
      } else {
        // If the server did not return a 200 OK response, throw an exception.
        final errorData = jsonDecode(response.body);
        setState(() {
          _caption = "Error from API: ${errorData['error']['message']}";
        });
      }
    } catch (e) {
      // Handle any other errors during the API call
      setState(() {
        _caption = "Failed to generate caption: $e";
      });
    } finally {
      // Set loading state to false once the process is complete
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Use a color from the theme for the AppBar
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                // --- Image Display Area ---
                Container(
                  height: 300,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400, width: 2),
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.grey.shade200,
                  ),
                  child: _imageFile == null
                      ? const Center(child: Text('No Image Selected'))
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.file(
                            File(_imageFile!.path),
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                        ),
                ),
                const SizedBox(height: 24),

                // --- Caption Display Area ---
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : Text(
                            _caption,
                            style: Theme.of(context).textTheme.bodyLarge,
                            textAlign: TextAlign.center,
                          ),
                  ),
                ),
                const SizedBox(height: 24),

                // --- Action Buttons ---
                ElevatedButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Pick Image from Gallery'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  // Disable button while loading
                  onPressed: _isLoading || _imageFile == null ? null : _generateCaption,
                  icon: const Icon(Icons.auto_awesome),
                  label: const Text('Generate Caption'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
