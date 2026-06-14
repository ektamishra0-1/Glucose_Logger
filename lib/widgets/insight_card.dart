import 'package:flutter/material.dart';

import '../models/glucose_log.dart';

class InsightCard extends StatelessWidget {
  final GlucoseLog? latestLog;
  final int totalLogsToday;
  final double? highestToday;
  final double? lowestToday;

  const InsightCard({
    super.key,
    required this.latestLog,
    required this.totalLogsToday,
    required this.highestToday,
    required this.lowestToday,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "LAST READING",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 12),

                Text(
                  latestLog?.mealType ?? "No readings yet",
                  style: const TextStyle(fontSize: 16),
                ),

                const SizedBox(height: 8),

                Text(
                  latestLog == null ? "--" : "${latestLog!.glucose} mg/dL",
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  latestLog?.insulin == null
                      ? "Insulin: --"
                      : "Insulin: ${latestLog!.insulin} U",
                ),

                const SizedBox(height: 8),

                Text(
                  latestLog == null
                      ? "--"
                      : "${latestLog!.timestamp.hour.toString().padLeft(2, '0')}:${latestLog!.timestamp.minute.toString().padLeft(2, '0')}",
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 20),

        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "TODAY",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 12),

                Text("Logs: $totalLogsToday"),

                Text("High: ${highestToday?.toStringAsFixed(0) ?? '--'}"),

                Text("Low: ${lowestToday?.toStringAsFixed(0) ?? '--'}"),

                Text(
                  latestLog == null
                      ? "Latest: --"
                      : "Latest: ${latestLog!.glucose}",
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
