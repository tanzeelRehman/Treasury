// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

/// Camera example home widget.
class CameraPage extends StatefulWidget {
  /// Default Constructor
  const CameraPage({Key? key}) : super(key: key);

  @override
  State<CameraPage> createState() {
    return _CameraPageState();
  }
}

void _logError(String code, String? message) {
  // ignore: avoid_print
  print('Error: $code${message == null ? '' : '\nError Message: $message'}');
}

class _CameraPageState extends State<CameraPage>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  CameraController? controller;
  XFile? imageFile;
  bool isImageProcessing = false;

  List<CameraDescription> _cameras = <CameraDescription>[];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      try {
        WidgetsFlutterBinding.ensureInitialized();
        _cameras = await availableCameras();
        controller = CameraController(_cameras[1], ResolutionPreset.medium);
        await controller!.initialize();
        setState(() {});
      } on CameraException {
        print("Shit happens");
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 600,
      width: MediaQuery.of(context).size.width * 0.8,
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      child: Padding(
        padding: const EdgeInsets.all(1.0),
        child: Center(
          child: _cameraPreviewWidget(),
        ),
      ),
    );
  }

  /// Display the preview from the camera (or a message if the preview is not available).
  Widget _cameraPreviewWidget() {
    final CameraController? cameraController = controller;

    if (cameraController == null || !cameraController.value.isInitialized) {
      return const Text(
        'Tap a camera',
        style: TextStyle(
          color: Colors.white,
          fontSize: 24.0,
          fontWeight: FontWeight.w900,
        ),
      );
    } else {
      return Stack(
        children: [
          Align(
              alignment: Alignment.bottomCenter,
              child: isImageProcessing
                  ? const Padding(
                      padding: EdgeInsets.only(bottom: 40),
                      child: CircularProgressIndicator(
                        color: Colors.white,
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.only(bottom: 40),
                      child: IconButton(
                        icon: const Icon(
                          Icons.camera_alt,
                          size: 50,
                          color: Colors.red,
                        ),
                        color: Colors.white,
                        onPressed: cameraController.value.isInitialized &&
                                !cameraController.value.isRecordingVideo
                            ? onTakePictureButtonPressed
                            : null,
                      ),
                    )),
          Align(
            alignment: Alignment.topCenter,
            child: CameraPreview(
              controller!,
            ),
          ),
          isImageProcessing
              ? Align(
                  alignment: Alignment.center,
                  child: Container(
                    height: 120,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(.3),
                    ),
                    width: 230,
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Please wait",
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 25,
                              fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          "Your image is being processed",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : const SizedBox.shrink()
        ],
      );
    }
  }

  void showInSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

//!------------------------------------------------------------------------------------------------------------------
//*===================================================================================================================
  void onTakePictureButtonPressed() {
    takePicture().then((XFile? file) {
      if (mounted) {
        setState(() {
          isImageProcessing = true;
          imageFile = file;
        });
        if (file != null) {
          File imageFile = File(file.path);
          //showInSnackBar('Picture saved to ${file.path}');
          sendPostRequest(imageFile);
        }
      }
    });
  }
  //! SEND POST +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  void sendPostRequest(File imageFile) async {
    final dio = Dio();
    dio.options.headers = {
      'AccessToken':
          'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ1bmlxdWVfbmFtZSI6IlBFRFJPQERJUkVDVFdJUkVCQU5LLkNPTSIsIm5iZiI6MTY4NTU2MjcwOSwiZXhwIjoxNjg2MTY3NTA5LCJpYXQiOjE2ODU1NjI3MDksImlzcyI6IkJpZyBEYXRhIENvcnAuIiwicHJvZHVjdHMiOlsiQklHQk9PU1QiLCJCSUdJRCJdLCJkb21haW4iOiJESVJFQ1QgV0lSRSBCQU5LIn0.UR8cWO8QYSwKAx7CGw4qlycm8QV23hctPTGoAa32Rfg',
      'TokenId': '6477a5553fd79b0008507b6a',
      'accept': 'application/json',
      'content-type': 'application/json',
    };

    try {
      final response = await dio.post(
        'https://app.bigdatacorp.com.br/bigid/biometrias/facematch',
        data: {
          'Parameters': [
            'BASE_FACE_IMG_URL=https://firebasestorage.googleapis.com/v0/b/k2signature-bd93f.appspot.com/o/signatures%2FWIN_20230601_15_03_24_Pro.jpg?alt=media&token=f932ff54-46bd-492a-8a9a-77158bf32bb1&_gl=1*llqtdl*_ga*ODAxOTEwNzYyLjE2ODM2NDk5OTE.*_ga_CW55HF8NVT*MTY4NTYzNjE1NS4xLjEuMTY4NTYzNjIyNC4wLjAuMA..',
            'MATCH_IMG=${imageToBase64(imageFile)}', // Replace 'base64' with your actual base64 image
          ],
        },
      );

      // Handle the response
      if (response.statusCode == 200) {
        // Request was successful
        final resultMessage = response.data['ResultMessage'];
        setState(() {
          isImageProcessing = false;
        });

        print('Result Message: $resultMessage');
        showInSnackBar('Result is $resultMessage');
      } else {
        // Request was not successful
        print('Request failed with status: ${response.statusCode}');
        setState(() {
          isImageProcessing = false;
        });
        showDialog(
          context: context,
          builder: (context) {
            return const AlertDialog(
              title: Text(
                "Request Failed",
              ),
              content: Text("Something went wrong"),
            );
          },
        );
      }
    } catch (error) {
      // Handle the error
      print('Error: $error');
      setState(() {
        isImageProcessing = false;
      });
      showDialog(
        context: context,
        builder: (context) {
          return const AlertDialog(
            title: Text(
              "Request Failed",
            ),
            content: Text("Something went wrong"),
          );
        },
      );
    }
  }

  String imageToBase64(File imageFile) {
    List<int> imageBytes = imageFile.readAsBytesSync();
    String base64Image = base64Encode(imageBytes);
    return base64Image;
  }

  Future<XFile?> takePicture() async {
    final CameraController? cameraController = controller;
    if (cameraController == null || !cameraController.value.isInitialized) {
      showInSnackBar('Error: select a camera first.');
      return null;
    }

    if (cameraController.value.isTakingPicture) {
      // A capture is already pending, do nothing.
      return null;
    }

    try {
      final XFile file = await cameraController.takePicture();
      return file;
    } on CameraException catch (e) {
      _showCameraException(e);
      return null;
    }
  }

  void _showCameraException(CameraException e) {
    _logError(e.code, e.description);
    showInSnackBar('Error: ${e.code}\n${e.description}');
  }
}
