import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_signature_pad/flutter_signature_pad.dart';
import 'package:path_provider/path_provider.dart';

class CustomSignatureTextfield extends StatefulWidget {
  const CustomSignatureTextfield({super.key});

  @override
  _CustomSignatureTextfieldState createState() =>
      _CustomSignatureTextfieldState();
}

class _CustomSignatureTextfieldState extends State<CustomSignatureTextfield> {
  late ConnectivityResult _connectivityResult = ConnectivityResult.none;
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;
  final GlobalKey<SignatureState> _signatureKey = GlobalKey<SignatureState>();
  bool _hasSignature = false;
  late List<ByteData> reterivedBytedata;
  @override
  void initState() {
    super.initState();
    _checkConnection();
    getAllFilesAsByteData('signaturefile');
    _connectivitySubscription =
        Connectivity().onConnectivityChanged.listen((result) {
      setState(() {
        _connectivityResult = result;
      });
    });
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  Future<void> _checkConnection() async {
    var result = await Connectivity().checkConnectivity();
    setState(() {
      _connectivityResult = result;
    });
  }

  Future<String?> uploadImage(ByteData? data) async {
    if (data != null) {
      Reference ref = FirebaseStorage.instance.ref().child('signatures/');

      ref = ref.child(DateTime.now().toIso8601String());

      UploadTask uploadTask = ref.putData(
        data.buffer.asUint8List(),
        SettableMetadata(contentType: 'image/png'),
      );

      TaskSnapshot snapshot = await uploadTask;

      String downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    }

    return null;
  }

  //! Upload and delate files ---
  void getAllFilesAsByteData(String filenamePattern) async {
    // Get a list of all files in the local storage directory
    final files = await getFilesFromLocalDirectory(filenamePattern);
    // If there are files in app local directory, It will upload file one by one and then delete it from local storage
    if (files.isNotEmpty) {
      for (var file in files) {
        deleteLocalFile(file.path);
        final bytes = await file.readAsBytes();
        // Convert the bytes to a ByteData object
        final byteData = ByteData.view(Uint8List.fromList(bytes).buffer);

        uploadImage(byteData).then((value) => {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${file.path} uploaded'),
                  duration: const Duration(seconds: 2),
                ),
              )
            });
      }
    }
  }

  //! Delete method ----
  Future<void> deleteLocalFile(String fileName) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File(fileName);
      if (await file.exists()) {
        await file.delete();
        print('File deleted: $fileName');
      } else {
        print('File not found: $fileName');
      }
    } catch (e) {
      print('Error deleting file: $e');
    }
  }

  //! get all files from app local directory whose include that pattern in their file path ---
  Future<List<File>> getFilesFromLocalDirectory(String filenamePattern) async {
    // Get the local documents directory
    final directory = await getApplicationDocumentsDirectory();

    print(directory.path);

    // Get a list of all files in the directory
    final files = await directory
        .list()
        .where((file) => file.path.contains(filenamePattern))
        .toList();

    // Cast the files to File objects and return the list
    return files.map((file) => File(file.path)).toList();
  }

  //! It will save file in local app storage ----
  Future<bool> saveByteDataToLocalFile(
      ByteData? byteData, String filename) async {
    // Convert the ByteData to a List<int>
    final bytes = byteData!.buffer.asUint8List();

    // Get the local documents directory
    final directory = await getApplicationDocumentsDirectory();

    // Create the file path
    final filePath = '${directory.path}/$filename';

    // Write the bytes to the file
    try {
      await File(filePath).writeAsBytes(bytes);
      print("file saved");
      return true;
    } catch (e) {
      print("file dosent saved");
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    var connectionStatus = 'Checking...';
    var color = Colors.grey;
    if (_connectivityResult == ConnectivityResult.mobile ||
        _connectivityResult == ConnectivityResult.wifi) {
      connectionStatus = 'Online';
      setState(() {
        getAllFilesAsByteData('signaturefile');
      });
      color = Colors.green;
    } else if (_connectivityResult == ConnectivityResult.none) {
      connectionStatus = 'Offline';
      color = Colors.red;
    }

    return Column(
      children: [
        const SizedBox(
          height: 15,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Device Status"),
            const SizedBox(
              width: 10,
            ),
            Text(
              connectionStatus,
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 20,
        ),
        Container(
          decoration: BoxDecoration(
              border: Border.all(color: Colors.black54, width: 1),
              color: Colors.grey.withOpacity(.5),
              borderRadius: BorderRadius.circular(15)),
          height: 200,
          child: Signature(
            key: _signatureKey,
            strokeWidth: 5.0,
            color: Colors.black,
            onSign: () {
              setState(() {
                _hasSignature = true;
              });
            },
          ),
        ),
        const SizedBox(
          height: 50,
        ),
        // _img.buffer.lengthInBytes == 0
        //     ? Container()
        //     : LimitedBox(
        //         maxHeight: 200.0,
        //         child: Image.memory(_img.buffer.asUint8List())),
        ElevatedButton(
          onPressed: () async {
            final sign = _signatureKey.currentState;
            //retrieve image data, do whatever you want with it (send to server, save locally...)
            final image = await sign?.getData();
            var data = await image!.toByteData(format: ImageByteFormat.png);
            String filename = 'signaturefile${DateTime.now()}.png';

            if (!_hasSignature) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Please draw a signature first.'),
                  duration: Duration(seconds: 2),
                ),
              );
              return;
            }
            if (_connectivityResult == ConnectivityResult.none) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Device offline, $filename saved locally'),
                  duration: const Duration(seconds: 2),
                ),
              );

              await saveByteDataToLocalFile(data, filename);
              setState(() {
                _signatureKey.currentState!.clear();
                _hasSignature = false;
              });
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Uploading file. $filename'),
                  duration: const Duration(seconds: 2),
                ),
              );
              await uploadImage(data);

              setState(() {
                _signatureKey.currentState!.clear();
                _hasSignature = false;
              });
            }
          },
          child: const Text('Save Signature'),
        ),
      ],
    );
  }
}
