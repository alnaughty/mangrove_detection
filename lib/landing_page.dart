import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mangrove_classification/global.dart';
import 'package:mangrove_classification/services/firebase_getter.dart';
import 'package:tflite/tflite.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({Key? key}) : super(key: key);

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  final FirebaseLocationService _service = FirebaseLocationService.instance;
  @override
  void initState() {
    super.initState();
    loadModel();
    _service.subscribe();
    checkPerm();
  }

  checkPerm() async {
    LocationPermission currentPerm = await Geolocator.checkPermission();
    if (currentPerm == LocationPermission.unableToDetermine ||
        currentPerm == LocationPermission.denied ||
        currentPerm == LocationPermission.deniedForever) {
      LocationPermission perm = await Geolocator.requestPermission();
      if (currentPerm == LocationPermission.unableToDetermine ||
          currentPerm == LocationPermission.denied ||
          currentPerm == LocationPermission.deniedForever) {
      } else {
        listenPosition();
      }
    } else {
      listenPosition();
    }
  }

  void listenPosition() {
    positionStream = Geolocator.getPositionStream().listen((Position pos) {
      print("LOCATION $pos");
      if (mounted) {
        setState(() {
          currentPosition = pos;
        });
      } else {
        currentPosition = pos;
      }
    });
  }

  predictImage(String path) async {
    var res = await Tflite.runModelOnImage(
      path: path,
      numResults: 2,
      threshold: .5,
      imageMean: 127.5,
      imageStd: 127.5,
    );
    setState(() {
      _recognitions = res!;
    });
    print("PREDICTIONS : $res");
  }

  File? chosenFile;
  List _recognitions = [];

  loadModel() async {
    var result = await Tflite.loadModel(
      model: "assets/newmodelmangrove.tflite",
      labels: "assets/labels.txt",
    );
    print("RESULT LOADING : $result");
  }

  Future<void> getImage({required ImageSource source}) async {
    await ImagePicker().pickImage(source: source).then((value) async {
      if (value != null) {
        setState(() {
          chosenFile = File(value.path);
        });
        await predictImage(value.path);
      } else {
        setState(() {
          chosenFile = null;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mangrove Detection App"),
        actions: [
          if (currentPosition != null) ...{
            IconButton(
              onPressed: () {
                Navigator.pushNamed(context, "/map_page");
              },
              icon: const Icon(
                Icons.map,
                color: Colors.black,
              ),
            ),
          }
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          FloatingActionButton(
            backgroundColor: Colors.red,
            onPressed: () async {
              setState(() {
                _recognitions = [];
                chosenFile = null;
              });
            },
            child: const Center(
              child: Icon(
                Icons.clear,
                color: Colors.white,
              ),
            ),
          ),
          FloatingActionButton(
            onPressed: () async {
              await getImage(source: ImageSource.camera);
            },
            child: const Center(
              child: Icon(
                Icons.camera_alt_rounded,
                color: Colors.white,
              ),
            ),
          ),
          FloatingActionButton(
            onPressed: () async {
              await getImage(source: ImageSource.gallery);
            },
            child: const Center(
              child: Icon(
                Icons.photo,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
      body: chosenFile == null
          ? const Center(
              child: Text("Upload an image"),
            )
          : SingleChildScrollView(
              child: Column(
                children: [
                  if (chosenFile != null) ...{
                    Image.file(chosenFile!),
                  },
                  if (_recognitions.isNotEmpty) ...{
                    const SizedBox(
                      height: 10,
                    ),
                    for (int x = 0; x < _recognitions.length; x++) ...{
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                        ),
                        child: LayoutBuilder(builder: (context, constraint) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _recognitions[x]['label']
                                    .toString()
                                    .substring(2),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              Container(
                                width: constraint.maxWidth,
                                height: 20,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Colors.grey.shade400,
                                ),
                                child: Stack(
                                  children: [
                                    Positioned(
                                      left: 0,
                                      top: 0,
                                      bottom: 0,
                                      child: Container(
                                        width: constraint.maxWidth *
                                            (double.parse(_recognitions[x]
                                                    ['confidence']
                                                .toString())),
                                        height: 20,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          color: Colors.blue,
                                        ),
                                      ),
                                    ),
                                    Positioned.fill(
                                      child: Center(
                                        child: Text(
                                          "${double.parse((_recognitions[x]['confidence'] * 100).toString()).toStringAsFixed(2)}%",
                                          style: const TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ],
                          );
                        }),
                      ),
                    },
                    if (currentPosition != null) ...{
                      const SizedBox(
                        height: 20,
                      ),
                      SizedBox(
                        width: double.maxFinite,
                        height: 55,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: ElevatedButton(
                            onPressed: () {
                              if (_recognitions.isNotEmpty) {
                                for (int x = 0; x < _recognitions.length; x++) {
                                  FirebaseFirestore.instance
                                      .collection('location_data')
                                      .add({
                                    "name": _recognitions[x]['label']
                                        .toString()
                                        .substring(2),
                                    "percentage": double.parse((_recognitions[x]
                                                    ['confidence'] *
                                                100)
                                            .toString())
                                        .toStringAsFixed(2),
                                    "latitude": currentPosition!.latitude,
                                    "longitude": currentPosition!.longitude,
                                  });
                                }
                              }
                              setState(() {
                                _recognitions = [];
                                chosenFile = null;
                              });
                            },
                            child: const Text("SAVE DATA"),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 40,
                      ),
                    }
                  }
                ],
              ),
            ),
    );
  }
}
