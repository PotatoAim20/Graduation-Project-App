import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:zr3ty/pages/chatbot.dart';
import 'package:http/http.dart' as http;
import 'package:custom_button_builder/custom_button_builder.dart';
import 'package:zhi_starry_sky/starry_sky.dart';
import 'package:image/image.dart' as img;
import 'dart:io';

class ObjectDetectionPage extends StatefulWidget {
  final String imagePath;

  const ObjectDetectionPage({
    super.key,
    required this.imagePath,
    required Map detectionResult,
  });

  @override
  // ignore: library_private_types_in_public_api
  _ObjectDetectionPageState createState() => _ObjectDetectionPageState();
}

class _ObjectDetectionPageState extends State<ObjectDetectionPage> {
  String _serverText = '';
  String _predictedClass = '';
  double _confidence = 0.0;
  Uint8List? _originalImage;
  Uint8List? _preprocessedImage;
  List<double>? _boundingBox;
  bool _isLoading = true;
  late int _originalHeight;
  late int _originalWidth;

  Future<void> uploadImage() async {
    final url = Uri.parse('http://20.54.112.25/model/predict-image/');

    try {
      var request = http.MultipartRequest('POST', url);

      request.files
          .add(await http.MultipartFile.fromPath('file', widget.imagePath));

      var response = await request.send();

      final responseBody = await response.stream.bytesToString();

      print('Response Body: $responseBody');

      if (response.statusCode == 200) {
        final data = json.decode(responseBody) as Map<String, dynamic>;

        setState(() {
          _predictedClass = data['predicted_class'] ?? 'No Plant Detected';
          _predictedClass = formatPredictedClass(_predictedClass);
          _serverText = _predictedClass;
          _confidence = data['Yolo result']['conf'][0] ?? 0.0;
          _serverText = _predictedClass;
          _boundingBox = List<double>.from(data['Yolo result']['xyxy'][0]);
          _originalHeight = data['orig_shape'][0];
          _originalWidth = data['orig_shape'][1];
          _isLoading = false;

          final List<dynamic> preprocessedImageList =
              data['preprocessd image'] ?? [];

          if (preprocessedImageList.isNotEmpty) {
            final int height = preprocessedImageList.length;
            final int width = preprocessedImageList.isNotEmpty
                ? preprocessedImageList[0].length
                : 0;

            final img.Image image = img.Image(width, height);

            for (int y = 0; y < height; y++) {
              for (int x = 0; x < width; x++) {
                final pixel = preprocessedImageList[y][x];
                if (pixel is List && pixel.length == 3) {
                  final r = (pixel[0] * 255).toInt();
                  final g = (pixel[1] * 255).toInt();
                  final b = (pixel[2] * 255).toInt();
                  image.setPixel(x, y, img.getColor(r, g, b));
                }
              }
            }

            final pngData = img.encodePng(image);
            _preprocessedImage = Uint8List.fromList(pngData);
          }
        });

        print('Predicted Class: ${data['predicted_class']}');
        print('Confidence: ${data['Yolo result']['conf'][0]}');
        print('YOLO Result: ${data['Yolo result']}');
      } else {
        print('Failed to upload image. Status Code: ${response.statusCode}');
        setState(() {
          _serverText = 'Failed to upload image';
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Exception occurred: $e');
      setState(() {
        _serverText = 'Failed to connect to server';
        _isLoading = false;
      });
    }
  }

  void _showPreprocessedImage() {
    if (_preprocessedImage == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Preprocessed Image'),
        content: SizedBox(
          width: 500,
          height: 400,
          child: Image.memory(
            _preprocessedImage!,
            fit: BoxFit.fill,
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  String formatPredictedClass(String predictedClass) {
    final parts = predictedClass.split(RegExp(r'_+'));
    final formattedClass = parts.join(' ');
    return formattedClass;
  }

  @override
  void initState() {
    super.initState();
    _originalImage = File(widget.imagePath).readAsBytesSync();
    uploadImage();
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
            child: StarrySkyView(),
          ),
          Positioned.fill(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 20, left: 0),
                  width: 350,
                  height: 350,
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
                                fit: BoxFit.fill,
                                width: 350,
                                height: 350,
                              )
                            : const Center(
                                child: Text(
                                  'No image available',
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
                                left: _boundingBox![0] * 350 / _originalWidth,
                                top: _boundingBox![1] * 350 / _originalHeight,
                                width: (_boundingBox![2] - _boundingBox![0]) *
                                    350 /
                                    _originalWidth,
                                height: (_boundingBox![3] - _boundingBox![1]) *
                                    350 /
                                    _originalHeight,
                                child: Container(
                                  decoration: BoxDecoration(
                                    border:
                                        Border.all(color: Colors.red, width: 2),
                                  ),
                                ),
                              ),
                              Positioned(
                                left: _boundingBox![0] * 350 / _originalWidth,
                                top:
                                    (_boundingBox![1] * 350 / _originalHeight) -
                                        20,
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
                    child: CircularProgressIndicator(),
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
                      ],
                    ),
                  ),
                const SizedBox(height: 40),
              ],
            ),
          ),
          if (_predictedClass != 'No Plant Detected' && !_isLoading)
            Positioned(
              bottom: 140,
              right: 122,
              child: CustomButton(
                onPressed: () {
                  final parts = _predictedClass.split(' ');
                  final plantName = parts.isNotEmpty ? parts[0] : '';
                  final diseaseName =
                      parts.length > 1 ? parts.sublist(1).join(' ') : '';

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatPage(
                          plantName: plantName, diseaseName: diseaseName),
                    ),
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
          if (_predictedClass != 'No Plant Detected' && !_isLoading)
            Positioned(
              bottom: 40,
              right: 20,
              child: FloatingActionButton(
                onPressed: _showPreprocessedImage,
                backgroundColor: Colors.green,
                tooltip: 'Show Preprocessed Image',
                child: const Icon(Icons.image),
              ),
            ),
        ],
      ),
    );
  }
}
