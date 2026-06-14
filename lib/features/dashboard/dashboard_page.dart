import 'package:flutter/material.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/futuristic_button.dart';
import '../../widgets/insight_card.dart';
import '../logger/log_entry_sheet.dart';
import '../../core/database/database_service.dart';
import '../../models/glucose_log.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  GlucoseLog? latestLog;

  int totalLogsToday = 0;

  double? highestToday;
  double? lowestToday;

  @override
  void initState() {
    super.initState();

    loadDashboardData();
  }

  Future<void> loadDashboardData() async {
    final logs = await DatabaseService.instance.getLogs();

    if (logs.isEmpty) {
      setState(() {
        latestLog = null;
      });
      return;
    }

    final today = DateTime.now();

    final todayLogs = logs.where((log) {
      return log.timestamp.year == today.year &&
          log.timestamp.month == today.month &&
          log.timestamp.day == today.day;
    }).toList();

    if (todayLogs.isEmpty) {
      setState(() {
        latestLog = logs.first;
      });
      return;
    }

    final glucoseValues = todayLogs.map((e) => e.glucose);

    setState(() {
      latestLog = logs.first;

      totalLogsToday = todayLogs.length;

      highestToday = glucoseValues.reduce((a, b) => a > b ? a : b);

      lowestToday = glucoseValues.reduce((a, b) => a < b ? a : b);
    });
  }

  Future<void> openLogSheet() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return const LogEntrySheet();
      },
    );

    await loadDashboardData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),

      appBar: AppBar(title: const Text("Glucose Logger")),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [
            const SizedBox(height: 40),

            Center(child: FuturisticButton(onTap: openLogSheet)),

            const SizedBox(height: 40),

            InsightCard(
              latestLog: latestLog,
              totalLogsToday: totalLogsToday,
              highestToday: highestToday,
              lowestToday: lowestToday,
            ),
          ],
        ),
      ),
    );
  }
}
