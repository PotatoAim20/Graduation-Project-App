import 'dart:io';
import 'package:custom_button_builder/custom_button_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test_1/pages/chatbot.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:zhi_starry_sky/starry_sky.dart';

class PredictionPage extends StatefulWidget {
  final String imagePath;

  const PredictionPage({super.key, required this.imagePath});

  @override
  _PredictionPageState createState() => _PredictionPageState();
}

class _PredictionPageState extends State<PredictionPage> {
  String _diseaseName = 'Loading...'; // Default text while loading

  @override
  void initState() {
    super.initState();
    fetchDiseaseName();
  }

  Future<void> fetchDiseaseName() async {
    try {
      final url = Uri.parse(
          'https://yourserver.com/api'); // Replace with your server URL
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'imagePath': widget.imagePath}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _diseaseName = data['diseaseName'];
        });
      } else {
        setState(() {
          _diseaseName =
              'Error: ${response.statusCode} - ${response.reasonPhrase}';
        });
      }
    } catch (e) {
      setState(() {
        _diseaseName = 'Server Error';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize:
            const Size.fromHeight(100.0), // Adjust the height as needed
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white24,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 10,
                blurRadius: 50,
                offset: const Offset(0, 40), // changes position of shadow
              ),
            ],
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(50), // Adjust the radius as needed
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
              const SizedBox(width: 10), // Adjust spacing as needed
              const Expanded(
                child: Center(
                  child: Text(
                    'Predicted Image',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(
                  width: 50), // Adjust spacing between back button and image
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          const Center(
            child: StarrySkyView(), // Your background widget
          ),
          // Container for Image
          Center(
            child: Container(
              margin: const EdgeInsets.only(bottom: 360, left: 0),
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blue, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.file(
                  File(widget.imagePath),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),

          // Text Box for the disease name
          Positioned(
            left: 0,
            right: 0,
            bottom: 270,
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.blue, width: 1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _diseaseName,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 17,
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 130,
            right: 125,
            child: CustomButton(
              onPressed: () {
                // Navigate to ChatPage
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ChatPage(),
                  ),
                );
              },
              gradient: const LinearGradient(colors: [Colors.blue, Colors.red]),
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
                        fontWeight: FontWeight.bold),
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
