import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';

void main() => runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyApp(),
    ));

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List _outputs;
  File _image;
  bool _loading;

  @override
  void initState() {
    super.initState();
    _loading = true;

    loadModel().then((value) {
      setState(() {
        _loading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[800],
      appBar: AppBar(
        title: const Text(
          'Plant Diseases Diagnosis',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green[900],
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(

            image: DecorationImage(

                image: AssetImage('assets/images/b.jpg'), fit: BoxFit.cover)
        ),
        child: _loading
            ? Container(
                alignment: Alignment.center,
                child: CircularProgressIndicator(),
              )
            : Container(
                width: MediaQuery.of(context).size.width,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _image == null
                        ? Container()
                        : Container(
                            width: MediaQuery.of(context).size.width,
                            height: 300.0,
                            margin: EdgeInsets.only(left: 16.0, right: 16.0),
                            child: Image.file(_image),
                          ),
                    SizedBox(
                      height: 8,
                    ),
                    _outputs != null
                        ? Card(
                            margin: EdgeInsets.all(8.0),
                            color: Colors.white,
                            child: Text(
                              "${_outputs[0]["label"]}",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        : Container(
                            child: Text(
                              'Upload an image',
                              style: TextStyle(
                                  color: Colors.white, fontSize: 16.0),
                            ),
                          ),
                  ],
                ),
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: pickImage,
        child: Image.asset('assets/images/icon1.png'),
        backgroundColor: Colors.green[400],
        splashColor: Colors.green[200],
        elevation: 1,
      ),
    );
  }

  pickImage() async {
    final image = await ImagePicker().getImage(source: ImageSource.gallery);
    if (image == null) return null;
    setState(() {
      _loading = true;
      _image = File(image.path);
    });
    classifyImage(_image);
  }

  classifyImage(File image) async {
    var output = await Tflite.runModelOnImage(
      path: image.path,
      threshold: 0.5,
      //threshold used to map probabilities to class labels.
      imageMean: 127.5,
      //127.5 Pixels are frequently represented as colors using a range from 0-255. This is exactly the middle of that range. So every pixel color is being adjusted to be between -1 and 1
      imageStd: 127.5,
    );
    setState(() {
      _loading = false;
      _outputs = output;
    });
  }

  loadModel() async {
    await Tflite.loadModel(
      model: "assets/model1.tflite",
      labels: "assets/labels.txt",
    );
  }

  @override
  void dispose() {
    Tflite.close();
    super.dispose();
  }
}
