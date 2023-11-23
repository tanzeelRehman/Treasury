import 'package:flutter/material.dart';

class LoyalityPointsWidget extends StatefulWidget {
  final int startValue; // lower limit
  final int endValue; // upper limit
  final int progress; // progress completed
  final List<double>
      circlePositions; // points on interval on which circle will show
  final Color widgetBackgroundColor; // inner circle colors when not filled
  final Color
      progressBarBackgroundColor; // progressbar background color, Default is Black
  final Color progressColor; // Progress color, Default is yellow
  final Color filledCircleColor; // Default color is yellow
  final Color borderColor; //Default color is black
  final Color textColor; //Default color is black

  const LoyalityPointsWidget(
      {super.key,
      this.startValue = 0,
      this.endValue = 500,
      required this.progress,
      required this.circlePositions,
      this.widgetBackgroundColor = Colors.transparent,
      this.progressBarBackgroundColor = Colors.black,
      this.progressColor = const Color(0xffD9AD13),
      this.filledCircleColor = const Color(0xffD9AD13),
      this.borderColor = Colors.black,
      this.textColor = Colors.black});

  @override
  State<LoyalityPointsWidget> createState() => _LoyalityPointsWidgetState();
}

class _LoyalityPointsWidgetState extends State<LoyalityPointsWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(
          milliseconds:
              500), // Adjust the Animation duration as per your preference
    )..addListener(() {
        setState(() {});
      });
    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    // Calculate the current progress
    int currentProgress = widget.progress;
    if (currentProgress > widget.endValue - widget.startValue) {
      currentProgress = widget.endValue - widget.startValue;
    }

    // Calculate the width of the filled portion of the progress bar
    double filledWidth =
        (currentProgress / widget.endValue) * MediaQuery.of(context).size.width;

    // Calculate the positions of the small circles
    List<double> circlePositions = widget.circlePositions
        .map((point) =>
            (point / widget.endValue) * MediaQuery.of(context).size.width)
        .toList();

    List<int> circlePoints =
        widget.circlePositions.map((double value) => value.toInt()).toList();

    return Container(
      color: Colors.transparent,
      alignment: Alignment.center,
      height: 58,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          //! Progressbar
          Positioned(
            child: Container(
              height: 6,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                color: widget.progressBarBackgroundColor,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          //! Total progress completed
          Positioned(
            child: Container(
              height: 6,
              width: filledWidth * _animationController.value,
              decoration: BoxDecoration(
                color: widget.progressColor,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          //! This loop will calculate total circles and will show them on their positions
          for (int i = 0; i < circlePositions.length; i++)
            Positioned(
              left: circlePositions[i] - 5,
              top: -4,
              child: Column(
                children: [
                  //! Circle
                  Container(
                    height: 15,
                    width: 15,
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: widget.borderColor,
                          width: currentProgress >= (i + 1) * widget.progress
                              ? 0
                              : 1),
                      color: currentProgress >= circlePoints[i]
                          ? widget.filledCircleColor
                          : widget.widgetBackgroundColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(height: 5),
                  //! label
                  Text(
                    circlePoints[i].toString(),
                    style: TextStyle(color: widget.textColor),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
