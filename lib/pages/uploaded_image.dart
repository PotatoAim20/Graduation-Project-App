import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:zhi_starry_sky/starry_sky.dart';
import 'package:flutter_test_1/pages/prediction.dart';
import 'package:custom_button_builder/custom_button_builder.dart';

class UploadedImagePage extends StatefulWidget {
  final String imagePath;

  const UploadedImagePage({
    super.key,
    required this.imagePath,
    required Map detectionResult,
  });

  @override
  // ignore: library_private_types_in_public_api
  _UploadedImagePageState createState() => _UploadedImagePageState();
}

class _UploadedImagePageState extends State<UploadedImagePage> {
  String? _selectedItem;
  String _serverText = 'Loading...'; // Default text while loading

  Future<void> fetchTextFromServer() async {
    final url = Uri.parse(
        'https://yourserver.com/api/text'); // Replace with your server URL
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        setState(() {
          _serverText = json.decode(response.body)['text'];
        });
      } else {
        setState(() {
          _serverText = 'Server Error'; // Handle server error
        });
      }
    } catch (e) {
      setState(() {
        _serverText = 'Failed to connect to server'; // Handle connection error
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchTextFromServer(); // Fetch text from server when the page initializes
  }

  void _showErrorDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: const Text('Please select an item from the dropdown list.'),
          contentTextStyle:
              const TextStyle(color: Colors.black87, fontSize: 17),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> sendSelectedItemToServer() async {
    final url =
        Uri.parse('https://yourserver.com/api'); // Replace with your server URL
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'selectedItem': _selectedItem}),
    );

    if (response.statusCode == 200) {
      print('Selected item: $_selectedItem, sent to server successfully');
      // Optionally handle the response from the server
    } else {
      print('Failed to send selected item: $_selectedItem, to server');
    }
  }

  @override
  Widget build(BuildContext context) {
    bool showDropdown = _serverText == "Plant leaf Detected";
    bool showRetakeButton = _serverText != "Plant leaf Detected";

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
            child: StarrySkyView(), // Your background widget
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
                    child: Image.file(
                      File(widget.imagePath),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 380, // Adjust this value to position the text
            child: Center(
              child: Column(
                children: [
                  Text(
                    _serverText, // Display fetched text from server
                    style: TextStyle(
                      color: _serverText == "Loading..."
                          ? Colors.black87
                          : // Change loading color here
                          _serverText == "Plant leaf Detected"
                              ? Colors.green
                              : Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  if (showDropdown)
                    Column(
                      children: [
                        const SizedBox(height: 30),
                        Container(
                          padding: const EdgeInsets.only(left: 20, bottom: 3),
                          width: 200,
                          height: 50,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.blue, width: 1),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: DropdownButton<String>(
                            value: _selectedItem,
                            hint: const Text(
                              'Select Plant Type',
                              style: TextStyle(
                                color: Colors.black87,
                                fontSize: 18,
                              ),
                            ),
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedItem = newValue!;
                              });
                              print('Selected item: $_selectedItem');
                            },
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                            ),
                            icon: const Icon(
                              Icons.arrow_drop_down_rounded,
                              color: Colors.blue,
                            ),
                            iconSize: 36,
                            underline: Container(),
                            isExpanded: true,
                            dropdownColor: Colors.white,
                            elevation: 8,
                            items: <String>[
                              'Apple',
                              'cassava',
                              'cherry',
                              'chili',
                              'coffee',
                              'corn',
                              'cucumber',
                              'guava',
                              'grape',
                              'jamun',
                              'lemon',
                              'mango',
                              'peach',
                              'peper bell',
                              'pomegranate',
                              'potato',
                              'rice',
                              'soybean',
                              'strawberry',
                              'sugarcane',
                              'tea',
                              'tomato',
                              'wheat'
                            ].map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(
                                  value,
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 20,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 130,
            right: 125,
            child: showRetakeButton
                ? CustomButton(
                    onPressed: () {
                      Navigator.pop(
                          context); // Navigate back to previous screen to retake image
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
                          'Retake',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  )
                : CustomButton(
                    onPressed: () async {
                      if (_selectedItem == null) {
                        _showErrorDialog();
                      } else {
                        await sendSelectedItemToServer();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                PredictionPage(imagePath: widget.imagePath),
                          ),
                        );
                      }
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
                          'Predict',
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
