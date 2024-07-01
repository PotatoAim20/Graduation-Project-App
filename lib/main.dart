import 'package:flutter/material.dart';
import 'package:flutter_test_1/pages/camera_screen.dart';
import 'package:flutter_test_1/pages/chatbot.dart';
import 'package:flutter_test_1/pages/uploaded_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:easy_dynamic_theme/easy_dynamic_theme.dart';
import 'package:zhi_starry_sky/starry_sky.dart';
import 'package:custom_button_builder/custom_button_builder.dart';

void main() {
  runApp(EasyDynamicThemeWidget(child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: EasyDynamicTheme.of(context).themeMode,
      home: const HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Future<void> _captureImage(BuildContext context) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const LiveDetectionPage(),
      ),
    );
  }

  Future<void> _selectImageFromGallery(BuildContext context) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      // Navigate to UploadedImagePage with the selected image path
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => UploadedImagePage(
            imagePath: pickedFile.path,
            detectionResult: {},
          ),
        ),
      );
    } else {
      print('No image selected.');
    }
  }

  void _toggleTheme(BuildContext context) {
    EasyDynamicTheme.of(context).changeTheme();
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
          padding: const EdgeInsets.only(
              top: 20.0), // Adjust the top padding as needed
          child: const Center(
            child: Text(
              'Home',
              style: TextStyle(
                color: Colors.black,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          const Center(
            child: StarrySkyView(), // background widget
          ),
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  top: 200,
                  child: CustomButton(
                    onPressed: () {
                      _captureImage(context);
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
                          'Capture Image',
                          style: TextStyle(color: Colors.white, fontSize: 22),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 250,
                  child: CustomButton(
                    onPressed: () {
                      _selectImageFromGallery(context);
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
                          'Upload Image',
                          style: TextStyle(color: Colors.white, fontSize: 20),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Colors.blue, Colors.red],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(30),
            ),
            child: FloatingActionButton(
              onPressed: () {
                _toggleTheme(context);
              },
              backgroundColor: Colors.transparent,
              foregroundColor: Colors.white,
              tooltip: 'Toggle Theme',
              heroTag: 'toggleTheme',
              child: const Icon(Icons.brightness_6),
            ),
          ),
          const SizedBox(height: 30), // Adjust spacing as needed
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Colors.blue, Colors.red],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(30),
            ),
            child: FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ChatPage(
                            disease: '',
                          )),
                );
              },
              backgroundColor: Colors.transparent,
              foregroundColor: Colors.white,
              tooltip: 'Chat',
              heroTag: 'chat',
              child: const Icon(Icons.chat),
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
    );
  }
}
