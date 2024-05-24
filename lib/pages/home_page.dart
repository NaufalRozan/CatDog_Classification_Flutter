import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite_v2/tflite_v2.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _loading = false;
  File? _image;
  List<dynamic>? _output;
  String label = '';

  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    loadModel().then((value) {
      setState(() {});
    });
  }

  classifyImage(File image) async {
    setState(() {
      _loading = true;
    });
    var output = await Tflite.runModelOnImage(
        path: image.path, // required
        imageMean: 0.0, // defaults to 117.0
        imageStd: 255.0, // defaults to 1.0
        numResults: 2, // defaults to 5
        threshold: 0.2, // defaults to 0.1
        asynch: true // defaults to true
        );

    if (output != null && output.isNotEmpty) {
      setState(() {
        _output = output;
        label = _output![0]['label'];
        _loading = false;
      });
    } else {
      setState(() {
        _loading = false;
      });

      classifyImage(_image!);
    }
  }

  loadModel() async {
    await Tflite.loadModel(
        model: 'assets/modelcatdog.tflite', labels: 'assets/labelscatdog.txt');
  }

  pickGalleryImage() async {
    var image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) return null;

    setState(() {
      _image = File(image.path);
    });

    classifyImage(_image!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cat Dog Classifier'),
      ),
      backgroundColor: Colors.grey[200],
      body: Center(
        child: Column(
          children: [
            Text("Cat Dog Classifier", style: TextStyle(fontSize: 20)),
            SizedBox(height: 20),
            Container(
              child: _image == null
                  ? Text('No image selected')
                  : Image.file(_image!, height: 200, width: 200),
            ),
            SizedBox(height: 20),
            _loading
                ? CircularProgressIndicator()
                : _output != null
                    ? Text(
                        'Prediction is ${label}',
                        style: TextStyle(fontSize: 20),
                      )
                    : Container(),
            SizedBox(height: 20),
            GestureDetector(
              onTap: pickGalleryImage,
              child: Container(
                width: MediaQuery.of(context).size.width - 100,
                alignment: Alignment.center,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 17),
                decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(6)),
                child: Text(
                  'Pick an image',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
