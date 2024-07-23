import 'package:flutter/material.dart';
import 'package:custom_button_builder/custom_button_builder.dart';
import 'package:zhi_starry_sky/starry_sky.dart';
import 'segmentation_page.dart';
import 'object_detection_page.dart';

class ChoicePage extends StatelessWidget {
  final String imagePath;

  const ChoicePage({super.key, required this.imagePath});

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
                    'Choose Action',
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
            child: StarrySkyView(), // background widget
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ObjectDetectionPage(
                          imagePath: imagePath,
                          detectionResult: const {},
                        ),
                      ),
                    );
                  },
                  gradient:
                      const LinearGradient(colors: [Colors.blue, Colors.red]),
                  width: 250,
                  height: 100,
                  borderRadius: 12,
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 30,
                      ),
                      SizedBox(width: 10),
                      Text(
                        'Object Detection',
                        style: TextStyle(color: Colors.white, fontSize: 22),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 100),
                CustomButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            SegmentationPage(imagePath: imagePath, detectionResult: {},),
                      ),
                    );
                  },
                  gradient:
                      const LinearGradient(colors: [Colors.blue, Colors.red]),
                  width: 250,
                  height: 100,
                  borderRadius: 12,
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.upload,
                        color: Colors.white,
                        size: 30,
                      ),
                      SizedBox(width: 10),
                      Text(
                        'Segmentation',
                        style: TextStyle(color: Colors.white, fontSize: 22),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
