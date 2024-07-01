// import 'package:flutter/material.dart';
// import 'package:camera/camera.dart';
// import 'package:tflite/tflite.dart';

// class DetectionResult {
//   final String detectedClass;
//   final double confidenceInClass;
//   final Rect rect;

//   DetectionResult({
//     required this.detectedClass,
//     required this.confidenceInClass,
//     required this.rect,
//   });
// }

// class RealTimeDetectionPage extends StatefulWidget {
//   const RealTimeDetectionPage({super.key});

//   @override
//   _RealTimeDetectionPageState createState() => _RealTimeDetectionPageState();
// }

// class _RealTimeDetectionPageState extends State<RealTimeDetectionPage> {
//   CameraController? cameraController;
//   bool isDetecting = false;
//   List<DetectionResult> _detectionResults = [];

//   @override
//   void initState() {
//     super.initState();
//     _initializeCamera();
//     _loadModel();
//   }

//   Future<void> _initializeCamera() async {
//     final cameras = await availableCameras();
//     final camera = cameras.first;

//     cameraController = CameraController(camera, ResolutionPreset.high);
//     await cameraController?.initialize();

//     if (!mounted) return;

//     cameraController?.startImageStream((image) {
//       if (!isDetecting) {
//         isDetecting = true;
//         _runModelOnFrame(image);
//       }
//     });

//     setState(() {});
//   }

//   Future<void> _loadModel() async {
//     try {
//       String? res = await Tflite.loadModel(
//         model: "assets/detect.tflite",
//         labels: "assets/labelmap.txt",
//         numThreads: 1,
//         isAsset: true,
//         useGpuDelegate: false,
//       );
//       print("Model loaded: $res");
//     } catch (e) {
//       print("Error loading model: $e");
//     }
//   }

//   Future<void> _runModelOnFrame(CameraImage image) async {
//     try {
//       var recognitions = await Tflite.runModelOnFrame(
//         bytesList: image.planes.map((plane) {
//           return plane.bytes;
//         }).toList(),
//         imageHeight: image.height,
//         imageWidth: image.width,
//         imageMean: 127.5,
//         imageStd: 127.5,
//         rotation: 90,
//         numResults: 2,
//         threshold: 0.1,
//         asynch: true,
//       );

//       List<DetectionResult> results =
//           recognitions?.map<DetectionResult>((recog) {
//                 return DetectionResult(
//                   detectedClass: recog["detectedClass"],
//                   confidenceInClass: recog["confidenceInClass"],
//                   rect: Rect.fromLTWH(
//                     recog["rect"]["x"] * image.width,
//                     recog["rect"]["y"] * image.height,
//                     recog["rect"]["w"] * image.width,
//                     recog["rect"]["h"] * image.height,
//                   ),
//                 );
//               }).toList() ??
//               [];

//       setState(() {
//         isDetecting = false;
//         _detectionResults = results;
//       });
//     } catch (e) {
//       print("Error during detection: $e");
//       setState(() {
//         isDetecting = false;
//       });
//     }
//   }

//   @override
//   void dispose() {
//     cameraController?.dispose();
//     Tflite.close();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (cameraController == null || !cameraController!.value.isInitialized) {
//       return const Center(child: CircularProgressIndicator());
//     }

//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Real-Time Detection'),
//       ),
//       body: Stack(
//         children: [
//           CameraPreview(cameraController!),
//           ..._detectionResults.map((result) {
//             return Positioned(
//               left: result.rect.left,
//               top: result.rect.top,
//               width: result.rect.width,
//               height: result.rect.height,
//               child: Container(
//                 decoration: BoxDecoration(
//                   border: Border.all(
//                     color: Colors.red,
//                     width: 2,
//                   ),
//                 ),
//                 child: Text(
//                   '${result.detectedClass} ${(result.confidenceInClass * 100).toStringAsFixed(0)}%',
//                   style: TextStyle(
//                     backgroundColor: Colors.red,
//                     color: Colors.white,
//                     fontSize: 12,
//                   ),
//                 ),
//               ),
//             );
//           }).toList(),
//         ],
//       ),
//     );
//   }
// }
