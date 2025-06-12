import 'package:ai_weather_app/util/date_time_formatter.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class MyLineGraph extends StatefulWidget {
  final List<double> dataPoints;
  final double minVal;
  final double maxVal;
  final String ylabel;
  final List<Color> myGradientColors;

  const MyLineGraph({
    super.key,
    required this.dataPoints,
    required this.minVal,
    required this.maxVal,
    required this.ylabel,
    required this.myGradientColors,
  });

  @override
  State<MyLineGraph> createState() => _MyLineGraphState();
}

class _MyLineGraphState extends State<MyLineGraph> {
  // Touched attributes
  int touchedIndex = -1;

  // get bottom titles (timestamps)
  Widget getBottomTitleWidgets(double value, TitleMeta meta) {
    String time;
    DateTime currentTime = DateTime.now();
    switch (value.toInt()) {
      case 0:
        time = getTimeString(currentTime.subtract(Duration(minutes: 6)));
        break;
      case 1:
        time = getTimeString(currentTime.subtract(Duration(minutes: 5)));
        break;
      case 2:
        time = getTimeString(currentTime.subtract(Duration(minutes: 4)));
        break;
      case 3:
        time = getTimeString(currentTime.subtract(Duration(minutes: 3)));
        break;
      case 4:
        time = getTimeString(currentTime.subtract(Duration(minutes: 2)));
        break;
      case 5:
        time = getTimeString(currentTime.subtract(Duration(minutes: 1)));
        break;
      case 6:
        time = getTimeString(currentTime);
        break;
      default:
        time = '00:00';
        break;
    }
    return Text(time, style: TextStyle(fontSize: 10, color: Colors.white),);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.dataPoints.length < 7 || widget.dataPoints[6] == 0.0) {
      return Center(child: CircularProgressIndicator(color: Colors.white,));
    }
    else {
      return LineChart(
        LineChartData(
          // draw grid with solid vertical lines
          gridData: FlGridData(
            drawVerticalLine: false,
            drawHorizontalLine: true,
            getDrawingHorizontalLine: (value) => FlLine(
              dashArray: null,
              strokeWidth: 0.5,
              color: Colors.grey[700],
            ),
          ),

          // Axes of the graph
          titlesData: FlTitlesData(
            show: true,
            // y-axis for data points
            leftTitles: AxisTitles(
              axisNameWidget: Text(widget.ylabel, style: TextStyle(color: Colors.white),),
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                minIncluded: false,
                maxIncluded: false,
                getTitlesWidget: (value, meta) => Text(
                  value.toStringAsFixed(1), // Show decimal places
                  style: TextStyle(fontSize: 12, color: widget.myGradientColors[0]),
                ),
              ),
            ),
            // reserve some space
            rightTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true, 
                getTitlesWidget: (value, meta) => Text(''),
                reservedSize: 10,
              ),
            ),
            // reserve some space
            topTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true, 
                getTitlesWidget: (value, meta) => Text(''),
                reservedSize: 10,
              ),
            ),
            // x-axis for timestamps
            bottomTitles: AxisTitles(
              axisNameWidget: Text('Time', style: TextStyle(color: Colors.white),),
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 20,
                interval: 1,
                getTitlesWidget: getBottomTitleWidgets,
              ),
            ),
          ),
      
          // No need of borders
          borderData: FlBorderData(
            show: false,
          ),

          // Range of x-axis for timestamps
          minX: 0,
          maxX: 6,

          // Range of y-axis for data points
          minY: widget.minVal,
          maxY: widget.maxVal,

          lineBarsData: [
            // Actual data points
            LineChartBarData(
              spots: widget.dataPoints.asMap().entries.map(
                (entry) => FlSpot(entry.key.toDouble(), entry.value)
              ).toList(),
              isCurved: false,
              gradient: LinearGradient(
                colors: widget.myGradientColors,
              ),
              barWidth: 5,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: false,
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: widget.myGradientColors.map(
                    (color) => color.withValues(alpha: 0.3),
                  ).toList(),
                ),
              )
            ),
          ],

          // Enable touch feedback
          lineTouchData: LineTouchData(
            touchCallback: (FlTouchEvent event, LineTouchResponse? lineTouch) {
              if (!event.isInterestedForInteractions || lineTouch == null || lineTouch.lineBarSpots == null) {
                setState(() {
                  touchedIndex = -1;
                });
                return;
              }
              final value = lineTouch.lineBarSpots![0].x;
              setState(() {
                touchedIndex = value.toInt();
              });
            },
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (touchedSpot) => Colors.black,
              getTooltipItems: (touchedSpots) {
                DateTime currentTime = DateTime.now();
                return [
                  LineTooltipItem(
                    '${widget.dataPoints[touchedIndex].toStringAsFixed(1)}\n',
                    TextStyle(
                      color: widget.myGradientColors[0],
                      fontSize: 16,
                    ),
                    children: [
                      TextSpan(
                        text: getTimeString(currentTime.subtract(Duration(minutes: (6-touchedIndex)))),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        )
                      )
                    ],
                  ),
                ];
              },
            ),
          ),
        ),
      );
    }
  }
}