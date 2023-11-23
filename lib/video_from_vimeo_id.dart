// // ignore_for_file: public_member_api_docs, sort_constructors_first
// import 'package:flutter/material.dart';
// import 'package:pod_player/pod_player.dart';

// class PlayVideoFromVimeoId extends StatefulWidget {
//   final String vimeo_id;
//   final Function(bool) videoPlayerState;
//   Color? backgroundColor = Colors.black;
//   Color? prograssBarColor = Colors.blue;
//   PlayVideoFromVimeoId(
//       {Key? key,
//       required this.vimeo_id,
//       required this.videoPlayerState,
//       this.backgroundColor = Colors.black,
//       this.prograssBarColor = Colors.blue})
//       : super(key: key);

//   @override
//   State<PlayVideoFromVimeoId> createState() => _PlayVideoFromVimeoIdState();
// }

// class _PlayVideoFromVimeoIdState extends State<PlayVideoFromVimeoId> {
//   // videpPlayerState(vidoIsPlaying) {
//   //   print(vidoIsPlaying);
//   // }

//   late final PodPlayerController controller;

//   bool videoLoaded = true;

//   @override
//   void initState() {
//     controller = PodPlayerController(
//       playVideoFrom: PlayVideoFrom.vimeo(widget.vimeo_id),
//     )
//       ..initialise()
//       ..addListener(() {
//         widget.videoPlayerState(controller.isVideoPlaying);
//       });
//     // try {

//     // } catch (e) {
//     //   setState(() {
//     //     videoLoaded = false;
//     //   });
//     // }

//     super.initState();
//   }

//   @override
//   void dispose() {
//     controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return ListView(
//       shrinkWrap: true,
//       children: [
//         videoLoaded
//             ? PodVideoPlayer(
//                 podProgressBarConfig: PodProgressBarConfig(
//                     circleHandlerColor: widget.prograssBarColor!,
//                     playingBarColor: widget.prograssBarColor!),
//                 backgroundColor: widget.prograssBarColor!,
//                 controller: controller)
//             : Container(
//                 child: const Text("Something went wrong"),
//               ),
//         const SizedBox(height: 40),
//       ],
//     );
//   }

//   void snackBar(String text) {
//     ScaffoldMessenger.of(context)
//       ..hideCurrentSnackBar()
//       ..showSnackBar(
//         SnackBar(
//           content: Text(text),
//         ),
//       );
//   }
// }
