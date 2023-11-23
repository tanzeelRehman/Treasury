// ignore_for_file: public_member_api_docs, sort_constructors_first
// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

/// Camera example home widget.
class VideoRecordAndUpload extends StatefulWidget {
  String question;
  int minutes;
  Future<dynamic> Function() onVideoUploaded;
  VideoRecordAndUpload({
    Key? key,
    required this.question,
    required this.minutes,
    required this.onVideoUploaded,
  }) : super(key: key);

  @override
  State<VideoRecordAndUpload> createState() {
    return _VideoRecordAndUploadState();
  }
}

void _logError(String code, String? message) {
  // ignore: avoid_print
  print('Error: $code${message == null ? '' : '\nError Message: $message'}');
}

class _VideoRecordAndUploadState extends State<VideoRecordAndUpload>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  CameraController? controller;
  late BuildContext buildContext;

  XFile? videoFile;
  VoidCallback? videoPlayerListener;

  bool enableAudio = true;
  bool isRecordingVideo = false;
  bool isUploadingVideo = false;

  int _remainingSeconds = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {});
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      var status = await Permission.camera.status;
      if (status.isDenied ||
          status.isLimited ||
          status.isPermanentlyDenied ||
          status.isRestricted) {
        await Permission.camera.request();
      }
      try {
        WidgetsFlutterBinding.ensureInitialized();
        _cameras = await availableCameras();
        controller = CameraController(
          _cameras[1],
          ResolutionPreset.medium,
        );

        //final deviceAspect = MediaQuery.of(context).size.aspectRatio;

        await controller!.initialize();

        setState(() {});
      } on CameraException {
        print("Shit happens");
      }
    });
  }

  setCameraPreviewSize(context, double deviceAspect) {
    (controller as CameraController).value.copyWith(
          deviceOrientation: DeviceOrientation.portraitUp,
          previewSize: MediaQuery.of(context).size,
        );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    super.dispose();
  }

  // #docregion AppLifecycle
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = controller;

    // App state changed before we got the chance to initialize.
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      onNewCameraSelected(cameraController.description);
    }
  }
  // #enddocregion AppLifecycle

  @override
  Widget build(BuildContext context) {
    buildContext = context;

    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.black,
              ),
              child: Padding(
                padding: const EdgeInsets.all(1.0),
                child: Center(
                  child: _cameraPreviewWidget(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _startCountdown(int minutes) {
    _remainingSeconds = minutes * 60;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          _timer?.cancel();
          onStopButtonPressed();
        }
      });
    });
  }

  /// Display the preview from the camera (or a message if the preview is not available).
  Widget _cameraPreviewWidget() {
    // final CameraController? cameraController = controller;

    const yScale = 1.0;

    if (controller == null || !controller!.value.isInitialized) {
      return const Text(
        'Tap a camera',
        style: TextStyle(
          color: Colors.white,
          fontSize: 24.0,
          fontWeight: FontWeight.w900,
        ),
      );
    } else {
      final size = MediaQuery.of(context).size;
      final deviceRatio = size.width / size.height;
      final xScale = controller!.value.aspectRatio;
      return Stack(
        children: [
          AspectRatio(
            aspectRatio: deviceRatio,
            child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.diagonal3Values(xScale, yScale, 1),
              child: CameraPreview(
                controller!,
                child: LayoutBuilder(builder:
                    (BuildContext context, BoxConstraints constraints) {
                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                  );
                }),
              ),
            ),
          ),
          isUploadingVideo ? loadingDialogWidget() : const SizedBox.shrink(),
          _captureVideoWidget(),
          !isUploadingVideo
              ? isRecordingVideo
                  ? questionWidget(widget.question)
                  : const SizedBox.shrink()
              : const SizedBox.shrink(),
          timerWidget(),
        ],
      );
    }
  }

  Widget timerWidget() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        margin: const EdgeInsets.only(right: 120, bottom: 65),
        child: Text(
          '${_remainingSeconds ~/ 60}:${(_remainingSeconds % 60).toString().padLeft(2, '0')}',
          style: const TextStyle(fontSize: 15, color: Colors.white),
        ),
      ),
    );
  }

  Widget questionWidget(String question) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        height: 80,
        margin: const EdgeInsets.only(bottom: 150),
        width: MediaQuery.of(context).size.width * 0.8,
        decoration: BoxDecoration(
            border: Border.all(color: Colors.black, width: 2),
            borderRadius: BorderRadius.circular(15),
            color: Colors.black.withOpacity(.4)),
        child: Center(
          child: Text(
            question,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget loadingDialogWidget() {
    return Align(
      alignment: Alignment.center,
      child: Container(
        height: 80,
        margin: const EdgeInsets.only(bottom: 150),
        width: MediaQuery.of(context).size.width * 0.8,
        decoration: BoxDecoration(
            border: Border.all(color: Colors.black, width: 2),
            borderRadius: BorderRadius.circular(15),
            color: Colors.black.withOpacity(.4)),
        child: const Center(
          child: Text(
            "Video uploading, Please wait..",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  /// Display the control bar with buttons to take pictures and record videos.
  /// ! ----------------------------------------------------------------------------------------------------------------------------------
  /// ?=======================================================================================================================================
  Widget _captureVideoWidget() {
    final CameraController? cameraController = controller;

    return Align(
      alignment: Alignment.bottomCenter,
      child: isUploadingVideo
          ? Container(
              alignment: Alignment.center,
              margin: const EdgeInsets.only(bottom: 50),
              height: 50,
              width: 50,
              child: const CircularProgressIndicator(
                color: Colors.white,
              ))
          : Container(
              alignment: Alignment.center,
              margin: const EdgeInsets.only(bottom: 50),
              height: 50,
              width: 50,
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 2),
                  borderRadius: BorderRadius.circular(50),
                  color: Colors.white.withOpacity(.4)),
              child: !isRecordingVideo
                  ? GestureDetector(
                      onTap: cameraController!.value.isInitialized &&
                              !cameraController.value.isRecordingVideo
                          ? onVideoRecordButtonPressed
                          : null,
                      child: Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(50)),
                      ),
                    )
                  : GestureDetector(
                      onTap: cameraController!.value.isInitialized &&
                              cameraController.value.isRecordingVideo
                          ? onStopButtonPressed
                          : null,
                      child: Container(
                        height: 28,
                        width: 28,
                        decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(0)),
                      ),
                    ),
            ),
    );
  }

  String timestamp() => DateTime.now().millisecondsSinceEpoch.toString();

  void showInSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> onNewCameraSelected(CameraDescription cameraDescription) async {
    final CameraController? oldController = controller;
    if (oldController != null) {
      // `controller` needs to be set to null before getting disposed,
      // to avoid a race condition when we use the controller that is being
      // disposed. This happens when camera permission dialog shows up,
      // which triggers `didChangeAppLifecycleState`, which disposes and
      // re-creates the controller.
      controller = null;
      await oldController.dispose();
    }

    final CameraController cameraController = CameraController(
      cameraDescription,
      kIsWeb ? ResolutionPreset.max : ResolutionPreset.medium,
      enableAudio: enableAudio,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    controller = cameraController;

    // If the controller is updated then update the UI.
    cameraController.addListener(() {
      if (mounted) {
        setState(() {});
      }
      if (cameraController.value.hasError) {
        showInSnackBar(
            'Camera error ${cameraController.value.errorDescription}');
      }
    });

    try {
      await cameraController.initialize();
      await Future.wait(<Future<Object?>>[
        // The exposure mode is currently not supported on the web.
        ...!kIsWeb ? <Future<Object?>>[] : <Future<Object?>>[],
      ]);
    } on CameraException catch (e) {
      switch (e.code) {
        case 'CameraAccessDenied':
          showInSnackBar('You have denied camera access.');
          break;
        case 'CameraAccessDeniedWithoutPrompt':
          // iOS only
          showInSnackBar('Please go to Settings app to enable camera access.');
          break;
        case 'CameraAccessRestricted':
          // iOS only
          showInSnackBar('Camera access is restricted.');
          break;
        case 'AudioAccessDenied':
          showInSnackBar('You have denied audio access.');
          break;
        case 'AudioAccessDeniedWithoutPrompt':
          // iOS only
          showInSnackBar('Please go to Settings app to enable audio access.');
          break;
        case 'AudioAccessRestricted':
          // iOS only
          showInSnackBar('Audio access is restricted.');
          break;
        default:
          _showCameraException(e);
          break;
      }
    }

    if (mounted) {
      setState(() {});
    }
  }

  void onAudioModeButtonPressed() {
    enableAudio = !enableAudio;
    if (controller != null) {
      onNewCameraSelected(controller!.description);
    }
  }

  Future<void> onCaptureOrientationLockButtonPressed() async {
    try {
      if (controller != null) {
        final CameraController cameraController = controller!;
        if (cameraController.value.isCaptureOrientationLocked) {
          await cameraController.unlockCaptureOrientation();
          showInSnackBar('Capture orientation unlocked');
        } else {
          await cameraController.lockCaptureOrientation();
          showInSnackBar(
              'Capture orientation locked to ${cameraController.value.lockedCaptureOrientation.toString().split('.').last}');
        }
      }
    } on CameraException catch (e) {
      _showCameraException(e);
    }
  }

  void onVideoRecordButtonPressed() {
    startVideoRecording().then((_) {
      if (mounted) {
        setState(() {
          isRecordingVideo = true;
          _startCountdown(widget.minutes);
        });
      }
    });
  }

  void _stopCountdown() {
    _timer?.cancel();
    setState(() {
      _remainingSeconds = 0;
    });
  }

  void onStopButtonPressed() {
    stopVideoRecording().then((XFile? file) {
      if (mounted) {
        setState(() {
          isRecordingVideo = false;
          _stopCountdown();
        });
      }
      if (file != null) {
        setState(() {
          isUploadingVideo = true;
        });

        uploadFile(File(file.path), 'videos/',
                '${DateTime.now().toIso8601String()}.mp4')
            .then((value) {
          if (value) {
            widget.onVideoUploaded();
          }
        });
      }
    });
  }

  Future<bool> uploadFile(
      File file, String storagePath, String fileName) async {
    try {
      final FirebaseStorage storage = FirebaseStorage.instance;
      late String downloadUrl;

      final Reference firebaseStorageRef =
          storage.ref().child("/$storagePath/$fileName");
      await firebaseStorageRef.putFile(file).then((snapshot) async {
        downloadUrl = await snapshot.ref.getDownloadURL();
        downloadUrl = downloadUrl.toString();
      });
      setState(() {
        isUploadingVideo = false;
      });
      deleteFile(file);

      showInSnackBar("Video uploaded sucessfully");

      return true;
    } catch (e) {
      setState(() {
        isUploadingVideo = false;
      });
      showInSnackBar("Some error has occured");
      deleteFile(file);
      return false;
    }
  }

  Future<void> deleteFile(File file) async {
    try {
      if (await file.exists()) {
        print('deleting file');
        print(file.path);
        await file.delete();
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> startVideoRecording() async {
    final CameraController? cameraController = controller;

    if (cameraController == null || !cameraController.value.isInitialized) {
      showInSnackBar('Error: select a camera first.');
      return;
    }

    if (cameraController.value.isRecordingVideo) {
      // A recording is already started, do nothing.
      return;
    }

    try {
      await cameraController.startVideoRecording();
    } on CameraException catch (e) {
      _showCameraException(e);
      return;
    }
  }

  Future<XFile?> stopVideoRecording() async {
    final CameraController? cameraController = controller;

    if (cameraController == null || !cameraController.value.isRecordingVideo) {
      return null;
    }

    try {
      return cameraController.stopVideoRecording();
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

/// CameraApp is the Main Application.

List<CameraDescription> _cameras = <CameraDescription>[];

class UploadResult {
  final String fileName;
  final String downloadUrl;

  UploadResult(this.fileName, this.downloadUrl);
}
