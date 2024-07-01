import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class LiveDetectionPage extends StatefulWidget {
  const LiveDetectionPage({super.key});

  @override
  _LiveDetectionPageState createState() => _LiveDetectionPageState();
}

class _LiveDetectionPageState extends State<LiveDetectionPage> {
  CameraController? _controller;
  List<dynamic> _boundingBoxes = [];
  bool _isProcessing = false; // Flag to check if an image is being processed

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      final camera = cameras.first;

      _controller = CameraController(camera, ResolutionPreset.medium);
      await _controller?.initialize();
      print('Camera initialized successfully.');

      _controller?.startImageStream((CameraImage image) {
        if (!_isProcessing) {
          _isProcessing = true;
          _processImage(image).then((_) {
            _isProcessing = false;
          }).catchError((e) {
            print('Error during image processing: $e');
            _isProcessing = false;
          });
        }
      });

      setState(() {});
    } catch (e) {
      print('Error initializing camera: $e');
    }
  }

  Future<void> _processImage(CameraImage image) async {
    try {
      // Reduce image resolution
      final WriteBuffer allBytes = WriteBuffer();
      for (var plane in image.planes) {
        allBytes.putUint8List(plane.bytes);
      }
      final bytes = allBytes.done().buffer.asUint8List();

      // Save the image to a temporary file
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/temp_image.jpg');
      await file.writeAsBytes(bytes);
      print('Image saved to ${file.path}');

      // Create a multipart request
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('http://20.54.112.25/predict-image/'),
      );

      // Add the image file to the request
      request.files.add(await http.MultipartFile.fromPath('file', file.path));
      print('Sending image to server...');

      // Send the request
      final response = await request.send();
      final responseString = await response.stream.bytesToString();

      // Print response status code and body for debugging
      print('Response status: ${response.statusCode}');
      // print('Response body: $responseString');

      if (response.statusCode == 200) {
        final tmp = json.decode(responseString);
        final result = json.decode(tmp) as Map<String, dynamic>;

        // Print YOLO result to the console
        print('YOLO Result: $result');

        setState(() {
          _boundingBoxes =
              result['xyxy']; // Update with your YOLO result format
        });
      } else {
        print('Error: ${response.statusCode}');
      }

      // Delete the temporary file after processing
      await file.delete();
      print('Temporary file deleted.');
    } catch (e) {
      print('Error processing image: $e');
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Live Object Detection')),
      body: Stack(
        children: [
          CameraPreview(_controller!),
          ..._boundingBoxes.map((box) {
            return Positioned(
              left: box[0].toDouble(),
              top: box[1].toDouble(),
              width: (box[2] - box[0]).toDouble(),
              height: (box[3] - box[1]).toDouble(),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.red, width: 2),
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}
