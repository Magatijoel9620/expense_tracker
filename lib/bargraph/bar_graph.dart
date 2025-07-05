import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'bar_data.dart'; // Assuming your BarData and IndividualBar are defined here

class MyBarGraph extends StatelessWidget {
  const MyBarGraph({
    super.key,
    required this.maxY,
    required this.sunAmount,
    required this.monAmount,
    required this.tueAmount,
    required this.wedAmount,
    required this.thurAmount,
    required this.friAmount,
    required this.satAmount,
  });

  final double? maxY; // Max Y value for the chart
  final double sunAmount;
  final double monAmount;
  final double tueAmount;
  final double wedAmount;
  final double thurAmount;
  final double friAmount;
  final double satAmount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Initialize BarData
    BarData myBarData = BarData(
      sunAmount: sunAmount,
      monAmount: monAmount,
      tueAmount: tueAmount,
      wedAmount: wedAmount,
      thurAmount: thurAmount,
      friAmount: friAmount,
      satAmount: satAmount,
    );
    myBarData.initializeBarData();

    // Determine a dynamic maxY with some padding if not explicitly provided or if it's too tight
    double calculatedMaxY = 0;
    if (maxY == null || maxY! <= 0) {
      // Calculate maxY from data if not provided
      double maxDataY = 0;
      for (var bar in myBarData.barData) {
        if (bar.y > maxDataY) {
          maxDataY = bar.y;
        }
      }
      calculatedMaxY = maxDataY * 1.2; // Add 20% padding
      if (calculatedMaxY == 0) calculatedMaxY = 10; // Default if all data is 0
    } else {
      calculatedMaxY = maxY!;
    }


    return AspectRatio( // Maintain aspect ratio for the chart
      aspectRatio: 1.5, // Adjust as needed
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: BarChart(
          BarChartData(
            maxY: calculatedMaxY,
            minY: 0,
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false, // Hide vertical grid lines
              horizontalInterval: calculatedMaxY / 5, // Adjust for number of horizontal lines
              getDrawingHorizontalLine: (value) {
                return FlLine(
                  color: colorScheme.onSurface.withOpacity(0.1),
                  strokeWidth: 1,
                );
              },
            ),
            borderData: FlBorderData(
              show: true,
              border: Border(
                bottom: BorderSide(color: colorScheme.onSurface.withOpacity(0.2), width: 1.5),
                left: BorderSide(color: colorScheme.onSurface.withOpacity(0.2), width: 1.5),
              ),
            ),
            titlesData: FlTitlesData(
              show: true,
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 38, // Increased for better spacing
                  getTitlesWidget: (value, meta) => _getBottomTitles(value, meta, theme),
                  interval: 1,
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 45, // Adjust based on your max Y value string length
                  interval: calculatedMaxY / 5, // Match with horizontalInterval
                  getTitlesWidget: (value, meta) => _getLeftTitles(value, meta, theme),
                ),
              ),
            ),
            barGroups: myBarData.barData.map((data) {
              return BarChartGroupData(
                x: data.x, // Day of the week (0 for Sun, 1 for Mon, etc.)
                barRods: [
                  BarChartRodData(
                    toY: data.y, // Amount for that day
                    gradient: LinearGradient( // Apply gradient to bars
                      colors: [
                        colorScheme.primary,
                        colorScheme.secondary,
                      ],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                    width: 22, // Adjust bar width
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(6),
                      topRight: Radius.circular(6),
                    ),
                    backDrawRodData: BackgroundBarChartRodData( // Background "empty" part of the bar
                      show: true,
                      toY: calculatedMaxY,
                      color: colorScheme.surfaceVariant, // Use a subtle theme color
                    ),
                    // rodStackItems: [], // For stacked bar charts
                  ),
                ],
                // showingTooltipIndicators: [], // For showing tooltips programmatically
              );
            }).toList(),
            barTouchData: BarTouchData( // Enable touch interactions
              enabled: true,
              touchTooltipData: BarTouchTooltipData(
                //tooltipBackgroundColor: colorScheme.secondaryContainer,
               // tooltipRoundedRadius: 8,
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  String weekDay;
                  switch (group.x.toInt()) {
                    case 0: weekDay = 'Sun'; break;
                    case 1: weekDay = 'Mon'; break;
                    case 2: weekDay = 'Tue'; break;
                    case 3: weekDay = 'Wed'; break;
                    case 4: weekDay = 'Thu'; break;
                    case 5: weekDay = 'Fri'; break;
                    case 6: weekDay = 'Sat'; break;
                    default: throw Error();
                  }
                  return BarTooltipItem(
                    '$weekDay\n',
                    TextStyle(
                      color: colorScheme.onSecondaryContainer,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    children: <TextSpan>[
                      TextSpan(
                        text: (rod.toY).toStringAsFixed(2), // Format to 2 decimal places
                        style: TextStyle(
                          color: colorScheme.onSecondaryContainer,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  );
                },
              ),
              touchCallback: (FlTouchEvent event, barTouchResponse) {
                // Handle touch events if needed (e.g., for navigation or highlighting)
                // if (!event.isInterestedForInteractions ||
                //     barTouchResponse == null ||
                //     barTouchResponse.spot == null) {
                //   // setState(() { touchedIndex = -1; }); // If managing touched state
                //   return;
                // }
                // // setState(() { touchedIndex = barTouchResponse.spot!.touchedBarGroupIndex; });
              },
            ),
          ),
          swapAnimationDuration: const Duration(milliseconds: 250), // Optional animation
          swapAnimationCurve: Curves.linear, // Optional animation
        ),
      ),
    );
  }
}

// Updated getBottomTitles to accept Theme
Widget _getBottomTitles(double value, TitleMeta meta, ThemeData theme) {
  final style = TextStyle(
    color: theme.colorScheme.onSurface.withOpacity(0.7),
    fontWeight: FontWeight.bold,
    fontSize: 12, // Slightly smaller for potentially more text
  );
  Widget text;
  switch (value.toInt()) {
    case 0: text = Text('Sun', style: style); break;
    case 1: text = Text('Mon', style: style); break;
    case 2: text = Text('Tue', style: style); break;
    case 3: text = Text('Wed', style: style); break;
    case 4: text = Text('Thu', style: style); break;
    case 5: text = Text('Fri', style: style); break;
    case 6: text = Text('Sat', style: style); break;
    default: text = Text('', style: style); break;
  }
  return SideTitleWidget(
    meta: meta, // Use meta to get axis side and other properties
    //axisSide: meta.axisSide,
    space: 8, // Space between titles and chart
    child: text,
  );
}

// New function for Left Titles (Y-Axis)
Widget _getLeftTitles(double value, TitleMeta meta, ThemeData theme) {
  final style = TextStyle(
    color: theme.colorScheme.onSurface.withOpacity(0.7),
    fontWeight: FontWeight.w500, // Regular weight is fine
    fontSize: 10,
  );
  String text;
  // Show value if it's not 0 or if it's explicitly generated by interval
  if (value == 0 && meta.appliedInterval == 0) { // Avoid cluttering 0 if not an interval stop
    text = '';
  } else if (value == meta.max) { // Don't show max value if it overlaps with top
    text = '';
  }
  else {
    text = value.toStringAsFixed(0); // Adjust formatting as needed (e.g. for K, M)
  }

  return SideTitleWidget(
    //axisSide: meta.axisSide,
    meta: meta,
    space: 8, // Space between titles and chart
    child: Text(text, style: style, textAlign: TextAlign.center),
  );
}

// Ensure your BarData and IndividualBar classes are defined correctly.
// Example for IndividualBar if it's not already in bar_data.dart
// class IndividualBar {
//   final int x; // position on x axis
//   final double y; // value on y axis
//
//   IndividualBar({required this.x, required this.y});
// }
//
// class BarData {
//   final double sunAmount;
//   // ... other amounts
//   List<IndividualBar> barData = [];
//   void initializeBarData() {
//     barData = [
//       IndividualBar(x: 0, y: sunAmount),
//       // ... initialize for other days
//     ];
//   }
// }

