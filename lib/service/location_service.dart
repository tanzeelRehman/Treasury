// import 'package:workmanager/workmanager.dart';

// class WorkManagerLocationService {
//   static Future<void> initializeWork() async {
//     await Workmanager().initialize(
//         callbackDispatcher, // The callback function to handle background tasks
//         isInDebugMode: false // Set to true if running in debug mode
//         );
//   }

//   static void callbackDispatcher() {
//     Workmanager().executeTask((task, inputData) {
//       print("EXCUTING");
//       return Future.value(true);
//     });
//   }

//   static void startTask() {
//     Workmanager().registerPeriodicTask(
//         "1", // A unique task name
//         "locationTask", // The task identifier

//         frequency: const Duration(seconds: 5), // Task frequency
//         tag: "bgloc");
//   }

//   static void cancelTask() {
//     Workmanager().cancelByTag("bgloc");
//   }
// }
