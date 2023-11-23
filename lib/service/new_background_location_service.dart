// import 'dart:async';
// import 'dart:io';
// import 'dart:ui';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_background_service/flutter_background_service.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// import 'package:geolocator/geolocator.dart';

// ///To take owner's location even when user is using or the application
// class NewBackgroundLocationService {
//   static final CollectionReference _location =
//       FirebaseFirestore.instance.collection('Location');
//   static final service = FlutterBackgroundService();

//   static late ServiceInstance myserviceInstance;
//   // static late StreamSubscription<Position> _positionStreamSubscription;
//   // static late Position _currentPosition;

//   static Future<void> initializeService() async {
//     final service = FlutterBackgroundService();

//     /// OPTIONAL, using custom notification channel id
//     const AndroidNotificationChannel channel = AndroidNotificationChannel(
//       'my_foreground', // id
//       'Rahper', // title
//       description:
//           'Your loc+ation will be live once you start a ride..', // description
//       importance: Importance.low, // importance must be at low or higher level
//     );

//     final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//         FlutterLocalNotificationsPlugin();

//     if (Platform.isIOS) {
//       await flutterLocalNotificationsPlugin.initialize(
//         const InitializationSettings(iOS: IOSInitializationSettings()),
//       );
//     }

//     await flutterLocalNotificationsPlugin
//         .resolvePlatformSpecificImplementation<
//             AndroidFlutterLocalNotificationsPlugin>()
//         ?.createNotificationChannel(channel);

//     await service.configure(
//       androidConfiguration: AndroidConfiguration(
//         // this will be executed when app is in foreground or background in separated isolate
//         onStart: onStart,
//         autoStartOnBoot: false,
//         // auto start service
//         autoStart: false,
//         isForegroundMode: true,

//         notificationChannelId: 'my_foreground',
//         initialNotificationTitle: 'Location Tracker',
//         initialNotificationContent: 'Your location is being monitored',
//         foregroundServiceNotificationId: 888,
//       ),
//       iosConfiguration: IosConfiguration(
//         // auto start service
//         autoStart: false,

//         // this will be executed when app is in foreground in separated isolate
//         onForeground: onStart,

//         // you have to enable background fetch capability on xcode project
//         onBackground: onIosBackground,
//       ),
//     );
//   }

//   @pragma('vm:entry-point')
//   static void onStart(ServiceInstance service) async {
//     // Only available for flutter 3.0.0 and later
//     DartPluginRegistrant.ensureInitialized();
//     Firebase.initializeApp();

//     const LocationSettings locationSettings = LocationSettings(
//       accuracy: LocationAccuracy.medium,
//       distanceFilter: 0,
//     );
//     // _positionStreamSubscription =
//     //     Geolocator.getPositionStream(locationSettings: locationSettings)
//     //         .listen((Position? position) {
//     //   _currentPosition = position!;
//     //   print("something is fishy");
//     //   print(_currentPosition == null
//     //       ? 'Unknown'
//     //       : '${_currentPosition.latitude.toString()}, ${_currentPosition.longitude.toString()}');
//     //   //  uploadLocation();
//     // });
//     StreamSubscription<Position> positionStream =
//         Geolocator.getPositionStream(locationSettings: locationSettings)
//             .listen((Position? position) {
//       print(position == null
//           ? 'Unknown'
//           : '${position.latitude.toString()}, ${position.longitude.toString()}');
//       print("something is fishy");
//       //  uploadLocation(position);
//     });

//     /// OPTIONAL when use custom notification
//     final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//         FlutterLocalNotificationsPlugin();

//     if (service is AndroidServiceInstance) {
//       service.on('setAsForeground').listen((event) {
//         service.setAsForegroundService();
//       });

//       service.on('setAsBackground').listen((event) {
//         service.setAsBackgroundService();
//       });
//       service.on("routeId").listen((event) {});
//     }

//     service.on('stopService').listen((event) {
//       service.stopSelf();
//       positionStream.cancel();
//     });

//     // bring to foreground
//   }

//   static void stopService() {
//     print("Iam stopping");
//     service.invoke("stopService");
//   }

//   @pragma('vm:entry-point')
//   static Future<bool> onIosBackground(ServiceInstance service) async {
//     WidgetsFlutterBinding.ensureInitialized();
//     DartPluginRegistrant.ensureInitialized();
//     return true;
//   }

//   static void uploadLocation(Position? position) {
//     print("Calling here");
//     if (position != null) {
//       _location.doc().set({
//         'latitude': position.latitude,
//         'longitude': position.longitude,
//         'timestamp': DateTime.now(),
//       });
//     }
//   }
// }

// class AndroidServiceInstance extends ServiceInstance {
//   static const MethodChannel _channel = MethodChannel(
//     'id.flutter/background_service_android_bg',
//     JSONMethodCodec(),
//   );

//   AndroidServiceInstance._() {
//     _channel.setMethodCallHandler(_handleMethodCall);
//   }

//   final _controller = StreamController.broadcast(sync: true);
//   Future<void> _handleMethodCall(MethodCall call) async {
//     switch (call.method) {
//       case "onReceiveData":
//         _controller.sink.add(call.arguments);
//         break;
//       default:
//     }
//   }

//   @override
//   void invoke(String method, [Map<String, dynamic>? args]) {
//     _channel.invokeMethod('sendData', {
//       'method': method,
//       'args': args,
//     });
//   }

//   @override
//   Future<void> stopSelf() async {
//     await _channel.invokeMethod("stopService");
//   }

//   @override
//   Stream<Map<String, dynamic>?> on(String method) {
//     return _controller.stream.transform(
//       StreamTransformer.fromHandlers(
//         handleData: (data, sink) {
//           if (data['method'] == method) {
//             sink.add(data['args']);
//           }
//         },
//       ),
//     );
//   }

//   Future<void> setForegroundNotificationInfo({
//     required String title,
//     required String content,
//   }) async {
//     await _channel.invokeMethod("setNotificationInfo", {
//       "title": title,
//       "content": content,
//     });
//   }

//   Future<void> setAsForegroundService() async {
//     await _channel.invokeMethod("setForegroundMode", {
//       'value': true,
//     });
//   }

//   Future<void> setAsBackgroundService() async {
//     print("AM I DOING SOMETHINg");
//     await _channel.invokeMethod("setBackgroundMode", {
//       'value': false,
//     });
//   }

//   /// returns true when the current Service instance is in foreground mode.
//   Future<bool> isForegroundService() async {
//     final result = await _channel.invokeMethod<bool>('isForegroundMode');
//     return result ?? false;
//   }

//   Future<void> setAutoStartOnBootMode(bool value) async {
//     await _channel.invokeMethod("setAutoStartOnBootMode", {
//       "value": value,
//     });
//   }
// }
