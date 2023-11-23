// // ignore_for_file: public_member_api_docs, sort_constructors_first
// // Automatic FlutterFlow imports

// // Begin custom widget code
// // DO NOT REMOVE OR MODIFY THE CODE ABOVE!

// // Set your widget name, define your parameter, and then add the
// // boilerplate code using the button on the right!

// import 'package:flutter/material.dart';
// import 'package:syncfusion_flutter_calendar/calendar.dart';

// class SuncFusionCalendar extends StatefulWidget {
//   const SuncFusionCalendar({
//     Key? key,
//     this.width,
//     this.height,
//     this.responseAPI,
//   }) : super(key: key);

//   final double? width;
//   final double? height;
//   final List<dynamic>? responseAPI;

//   @override
//   _SuncFusionCalendarState createState() => _SuncFusionCalendarState();
// }

// class _SuncFusionCalendarState extends State<SuncFusionCalendar> {
//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       height: 500,
//       child: SfCalendar(
//         view: CalendarView.month,
//         dataSource: MeetingDataSource(_getDataSource()),
//         monthViewSettings: const MonthViewSettings(
//             showAgenda: true,
//             appointmentDisplayMode: MonthAppointmentDisplayMode.appointment),
//       ),
//     );
//   }

//   List<Meeting> _getDataSource() {
//     final List<Meeting> meetings = <Meeting>[];

//     widget.responseAPI!.map((schedule) {
//       String startTimeStr =
//           '${schedule["Blocks"][0]["ISO8601StartTime"].substring(0, 10)} ${schedule["Blocks"][0]["StartTime"]}';
//       String endTimeStr =
//           '${schedule["Blocks"][0]["ISO8601EndTime"].substring(0, 10)} ${schedule["Blocks"][0]["EndTime"]}';
//       DateTime startTime = DateTime.parse(startTimeStr);
//       DateTime endTime = DateTime.parse(endTimeStr);
//       String name = '${schedule["Staff"]["Name"]}';

//       meetings.add(
//           Meeting(name, startTime, endTime, const Color(0xFF0F8644), false));
//     }).toList();

//     return meetings;
//   }
// }

// class MeetingDataSource extends CalendarDataSource {
//   MeetingDataSource(List<Meeting> source) {
//     appointments = source;
//   }

//   @override
//   DateTime getStartTime(int index) {
//     return appointments![index].from;
//   }

//   @override
//   DateTime getEndTime(int index) {
//     return appointments![index].to;
//   }

//   @override
//   String getSubject(int index) {
//     return appointments![index].eventName;
//   }

//   @override
//   Color getColor(int index) {
//     return appointments![index].background;
//   }

//   @override
//   bool isAllDay(int index) {
//     return appointments![index].isAllDay;
//   }
// }

// class Meeting {
//   Meeting(this.eventName, this.from, this.to, this.background, this.isAllDay);

//   String eventName;
//   DateTime from;
//   DateTime to;
//   Color background;
//   bool isAllDay;
// }
