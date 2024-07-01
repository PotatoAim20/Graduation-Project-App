import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test_1/pages/chatbot.dart';
import 'package:http/http.dart' as http;
import 'package:custom_button_builder/custom_button_builder.dart';
import 'package:zhi_starry_sky/starry_sky.dart';
// import 'package:image/image.dart' as img;
import 'dart:io';

class UploadedImagePage extends StatefulWidget {
  final String imagePath;

  const UploadedImagePage({
    super.key,
    required this.imagePath,
    required Map detectionResult,
  });

  @override
  _UploadedImagePageState createState() => _UploadedImagePageState();
}

class _UploadedImagePageState extends State<UploadedImagePage> {
  String _serverText = ''; // Text to display after loading
  String _predictedClass = ''; // To hold the predicted class
  double _confidence = 0.0; // To hold the confidence score
  Uint8List? _originalImage; // To hold the original image data
  List<double>? _boundingBox; // To hold the bounding box coordinates
  bool _isLoading = true; // To track loading state

  Future<void> uploadImage() async {
    final url = Uri.parse(
        'http://20.54.112.25/predict-image/'); // Replace with your server URL

    try {
      var request = http.MultipartRequest('POST', url);

      // Add the image file to the request
      request.files
          .add(await http.MultipartFile.fromPath('file', widget.imagePath));

      // Send the request
      var response = await request.send();

      // Read the response
      final responseBody = await response.stream.bytesToString();

      // Print the response for debugging
      print('Response Body: $responseBody');

      if (response.statusCode == 200) {
        final tmp = json.decode(responseBody);
        final data = json.decode(tmp) as Map<String, dynamic>;

        setState(() {
          _predictedClass = data['predicted_class'] ?? 'Prediction failed';
          _confidence =
              data['Yolo result']['conf'][0] ?? 0.0; // Extract confidence
          _serverText = _predictedClass;
          _boundingBox = List<double>.from(data['Yolo result']['xyxy'][0]);
          _isLoading = false; // Set loading state to false when done
        });

        print('Predicted Class: ${data['predicted_class']}');
        print('Confidence: ${data['Yolo result']['conf'][0]}');
        print('YOLO Result: ${data['Yolo result']}');
      } else {
        print('Failed to upload image. Status Code: ${response.statusCode}');
        setState(() {
          _serverText = 'Failed to upload image'; // Handle server error
          _isLoading =
              false; // Set loading state to false even if there's an error
        });
      }
    } catch (e) {
      print('Exception occurred: $e');
      setState(() {
        _serverText = 'Failed to connect to server'; // Handle connection error
        _isLoading =
            false; // Set loading state to false if there's an exception
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _originalImage =
        File(widget.imagePath).readAsBytesSync(); // Load the original image
    uploadImage(); // Upload image when the page initializes
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white24,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 10,
                blurRadius: 50,
                offset: const Offset(0, 40),
              ),
            ],
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(50),
            ),
          ),
          padding: const EdgeInsets.only(top: 20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon:
                    const Icon(Icons.arrow_back_ios_new, color: Colors.black54),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Center(
                  child: Text(
                    'Uploaded Image',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 50),
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          const Center(
            child: StarrySkyView(), // Background widget
          ),
          Positioned.fill(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 20, left: 0),
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.blue, width: 2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Stack(
                      children: [
                        _originalImage != null
                            ? Image.memory(
                                _originalImage!,
                                fit: BoxFit.cover,
                                width: 300,
                                height: 300,
                              )
                            : const Center(
                                child: Text(
                                  'No image available', // Fallback text if no image is available
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.black54,
                                  ),
                                ),
                              ),
                        if (_boundingBox != null)
                          Stack(
                            children: [
                              Positioned(
                                left: _boundingBox![0] * 300 / 900,
                                top: _boundingBox![1] * 300 / 692,
                                width: (_boundingBox![2] - _boundingBox![0]) *
                                    300 /
                                    900,
                                height: (_boundingBox![3] - _boundingBox![1]) *
                                    300 /
                                    692,
                                child: Container(
                                  decoration: BoxDecoration(
                                    border:
                                        Border.all(color: Colors.red, width: 2),
                                  ),
                                ),
                              ),
                              Positioned(
                                left: _boundingBox![0] * 300 / 900,
                                top: (_boundingBox![1] * 300 / 692) -
                                    20, // Adjust as needed
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  color: Colors.red,
                                  child: Text(
                                    'Confidence: ${(_confidence * 100).toStringAsFixed(2)}%',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 50),
                if (_isLoading)
                  const Center(
                    child: CircularProgressIndicator(), // Show loading spinner
                  )
                else if (_serverText.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.all(20),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.blue, width: 2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Text(
                          _predictedClass,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Confidence: ${(_confidence * 100).toStringAsFixed(2)}%', // Display confidence
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 40),
              ],
            ),
          ),
          if (_predictedClass.isNotEmpty &&
              !_isLoading) // Show button only if disease is detected and not loading
            Positioned(
              bottom: 130,
              right: 125,
              child: CustomButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            // const ChatPage()), // Pass the predicted disease
                            ChatPage(disease: _predictedClass)),
                  );
                },
                gradient:
                    const LinearGradient(colors: [Colors.blue, Colors.red]),
                width: 160,
                height: 60,
                borderRadius: 20,
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(width: 10),
                    Text(
                      'Get Cure',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
