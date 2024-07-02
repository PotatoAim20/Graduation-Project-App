import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image/image.dart' as img;

import 'uploaded_image.dart';

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
    final cameras = await availableCameras();
    final camera = cameras.first;

    _controller = CameraController(camera, ResolutionPreset.medium);
    await _controller?.initialize();

    _controller?.startImageStream((CameraImage image) {
      if (!_isProcessing) {
        _isProcessing = true;
        _processImage(image).then((_) {
          _isProcessing = false;
        });
      }
    });

    setState(() {});
  }

  Future<void> _processImage(CameraImage image) async {
    try {
      // Convert CameraImage to img.Image
      final imgImage = img.Image.fromBytes(
        image.width,
        image.height,
        image.planes[0].bytes,
        format: img.Format.rgb, // Adjust format based on your image data
      );

      // Encode image as JPEG
      final jpegBytes = img.encodeJpg(imgImage);

      // Create a multipart request
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('http://20.54.112.25/live-detection/'),
      );

      // Add the image file to the request with filename and content type
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          jpegBytes,
          filename: 'upload.jpg',
          contentType: MediaType('image', 'jpeg'),
        ),
      );

      // Send the request
      final response = await request.send();
      final responseString = await response.stream.bytesToString();

      // Print response status code and body for debugging
      print('Response status: ${response.statusCode}');
      print('Response body: $responseString');

      if (response.statusCode == 200) {
        final tmp = json.decode(responseString);
        final result = json.decode(tmp) as Map<String, dynamic>;

        // Print YOLO result to the console
        print('YOLO Result: $result');

        setState(() {
          _boundingBoxes = result['Yolo result']['xyxy'];
        });
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error processing image: $e');
    }
  }

  Future<void> _captureAndNavigate() async {
    if (_controller == null || !_controller!.value.isInitialized) {
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      // Stop the image stream
      await _controller!.stopImageStream();

      // Capture a single image
      final xFile = await _controller!.takePicture();

      // Optionally, you can also process the image here if needed
      final imageBytes = await File(xFile.path).readAsBytes();

      // Navigate to UploadedImagePage with the captured image path and detection result
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => UploadedImagePage(
            imagePath: xFile.path,
            detectionResult: const {}, // Pass an empty detection result
          ),
        ),
      );
    } catch (e) {
      print('Error capturing image: $e');
    } finally {
      setState(() {
        _isProcessing = false;
      });
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
      appBar: AppBar(
        title: const Padding(
          padding: EdgeInsets.fromLTRB(33, 5, 0, 0),
          child: Text('Live Object Detection'),
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: CameraPreview(_controller!),
          ),
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
      floatingActionButton: FloatingActionButton(
        onPressed: _isProcessing ? null : _captureAndNavigate,
        child: const Icon(Icons.camera),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
