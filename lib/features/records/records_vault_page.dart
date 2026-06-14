import 'package:flutter/material.dart';

import '../../core/database/database_service.dart';

import 'records_helper.dart';
import '../../core/pdf/pdf_service.dart';

class RecordsVaultPage extends StatefulWidget {
  const RecordsVaultPage({super.key});

  @override
  State<RecordsVaultPage> createState() => _RecordsVaultPageState();
}

class _RecordsVaultPageState extends State<RecordsVaultPage> {
  final ScrollController dateController =
    ScrollController();

final ScrollController tableController =
    ScrollController();
  String _monthName(int month) {
    const months = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return months[month];
  }
  Map<String, dynamic> getRangeStats() {
  final allLogs = records
      .expand((day) => day.slots.values)
      .expand((logs) => logs)
      .toList();

  if (allLogs.isEmpty) {
    return {
      "avg": null,
      "high": null,
      "low": null,
      "count": 0,
    };
  }

  final glucoseValues =
      allLogs.map((e) => e.glucose).toList();

  final high = glucoseValues.reduce(
    (a, b) => a > b ? a : b,
  );

  final low = glucoseValues.reduce(
    (a, b) => a < b ? a : b,
  );

  final avg =
      glucoseValues.reduce((a, b) => a + b) /
      glucoseValues.length;

  return {
    "avg": avg,
    "high": high,
    "low": low,
    "count": glucoseValues.length,
  };
}
Future<void> exportPdf() async {
  final stats = getRangeStats();

  final rows = records.map((day) {
    return [
      "${day.date.day}/${day.date.month}",

      getCellValue(
        day,
        "Before Breakfast",
      ),

      getCellValue(
        day,
        "After Breakfast",
      ),

      getCellValue(
        day,
        "Before Lunch",
      ),

      getCellValue(
        day,
        "After Lunch",
      ),

      getCellValue(
        day,
        "Before Dinner",
      ),

      getCellValue(
        day,
        "After Dinner",
      ),

      getCellValue(
        day,
        "Before Lantus",
      ),
    ];
  }).toList();

  String period;

  if (selectedDays == -1) {
    period = "All Records";
  } else {
    period = "Last $selectedDays Days";
  }

  await PdfService.generateReport(
    rows: rows,
    period: period,
    avg: stats["avg"],
    high: stats["high"],
    low: stats["low"],
    entries: stats["count"],
  );
}
  void showLogDetails(
  String meal,
  List logs,
) {
  showDialog(
    context: context,
    builder: (_) {
      return AlertDialog(
        title: Text(meal),

        content: SizedBox(
          width: double.maxFinite,

          child: ListView.builder(
            shrinkWrap: true,
            itemCount: logs.length,
            controller: dateController,

            itemBuilder: (_, index) {
              final log = logs[index];

              return Card(
                child: ListTile(
                  title: Text(
                    "${log.glucose.toStringAsFixed(0)} mg/dL",
                  ),

                  subtitle: Text(
                    "Insulin: ${log.insulin ?? '--'} U\n"
                    "Time: ${log.timestamp.hour.toString().padLeft(2, '0')}:${log.timestamp.minute.toString().padLeft(2, '0')}\n"
                    "Exercise: ${log.exercised ? 'Yes' : 'No'}\n"
                    "Notes: ${log.notes ?? '--'}",
                  ),
                ),
              );
            },
          ),
        ),
      );
    },
  );
}
Widget buildCell(
  DailyRecord day,
  String meal,
) {
  final logs = day.slots[meal];

  return InkWell(
    onTap: logs == null || logs.isEmpty
        ? null
        : () {
            showLogDetails(
              meal,
              logs,
            );
          },

    child: Padding(
      padding: const EdgeInsets.all(4),

      child: Text(
        getCellValue(
          day,
          meal,
        ),
      ),
    ),
  );
}
  String getCellValue(
  DailyRecord day,
  String meal,
) {
  final logs = day.slots[meal];

  if (logs == null || logs.isEmpty) {
    return "-";
  }

  if (logs.length == 1) {
    final log = logs.first;

    if (log.insulin == null) {
      return log.glucose.toStringAsFixed(0);
    }

    return "${log.glucose.toStringAsFixed(0)} (${log.insulin!.toStringAsFixed(0)}U)";
  }

  final first = logs.first;

  return "${first.glucose.toStringAsFixed(0)} (+${logs.length - 1})";
}

  Map<String, dynamic> getDayStats(DailyRecord day) {
    final allLogs = day.slots.values.expand((logs) => logs);

    if (allLogs.isEmpty) {
      return {"high": null, "low": null, "count": 0};
    }

    final glucoseValues = allLogs.map((e) => e.glucose);

    return {
      "high": glucoseValues.reduce((a, b) => a > b ? a : b),
      "low": glucoseValues.reduce((a, b) => a < b ? a : b),
      "count": day.slots.values.fold(0, (sum, logs) => sum + logs.length),
    };
  }

  List<DailyRecord> records = [];

  bool loading = true;

  int selectedDays = 90;

  @override
void initState() {
  super.initState();

  dateController.addListener(() {
    if (tableController.hasClients) {
      tableController.jumpTo(
        dateController.offset,
      );
    }
  });

  loadRecords();
}

Future<void> jumpToDate() async {
  final picked = await showDatePicker(
    context: context,
    firstDate: DateTime(2020),
    lastDate: DateTime.now(),
    initialDate: DateTime.now(),
  );

  if (picked == null) return;

  final index = records.indexWhere(
    (record) =>
        record.date.year == picked.year &&
        record.date.month == picked.month &&
        record.date.day == picked.day,
  );

  if (index == -1) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(
      const SnackBar(
        content: Text(
          "No records found for that date",
        ),
      ),
    );

    return;
  }

  const rowHeight = 52.0;

  final offset = index * rowHeight;

  dateController.animateTo(
    offset,
    duration: const Duration(
      milliseconds: 400,
    ),
    curve: Curves.easeInOut,
  );
}
  Future<void> loadRecords() async {
    setState(() {
      loading = true;
    });

    final logs = selectedDays == -1
        ? await DatabaseService.instance.getLogs()
        : await DatabaseService.instance.getLogsLastDays(selectedDays);

    final grouped = RecordsHelper.groupLogs(logs);

    setState(() {
      records = grouped;
      loading = false;
    });
  }

  Widget buildFilterChip(String label, int days) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selectedDays == days,
        onSelected: (_) async {
          setState(() {
            selectedDays = days;
          });

          await loadRecords();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final stats = getRangeStats();
    return Scaffold(
      appBar: AppBar(
  title: const Text("Records Vault"),

  actions: [
    IconButton(
      icon: const Icon(
        Icons.picture_as_pdf,
      ),
      onPressed: exportPdf,
    ),

    IconButton(
      icon: const Icon(
        Icons.calendar_month,
      ),
      onPressed: jumpToDate,
    ),
  ],
),

body: Column(
        children: [
          const SizedBox(height: 12),
          Padding(
  padding: const EdgeInsets.symmetric(
    horizontal: 12,
  ),
  child: Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.spaceAround,
        children: [

          Column(
            children: [
              const Text("AVG"),
              Text(
                stats["avg"] == null
                    ? "--"
                    : stats["avg"]
                        .toStringAsFixed(0),
              ),
            ],
          ),

          Column(
            children: [
              const Text("HIGH"),
              Text(
                stats["high"] == null
                    ? "--"
                    : stats["high"]
                        .toStringAsFixed(0),
              ),
            ],
          ),

          Column(
            children: [
              const Text("LOW"),
              Text(
                stats["low"] == null
                    ? "--"
                    : stats["low"]
                        .toStringAsFixed(0),
              ),
            ],
          ),

          Column(
            children: [
              const Text("ENTRIES"),
              Text(
                stats["count"].toString(),
              ),
            ],
          ),
        ],
      ),
    ),
  ),
),

          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                buildFilterChip("7D", 7),
                buildFilterChip("30D", 30),
                buildFilterChip("90D", 90),
                buildFilterChip("180D", 180),
                buildFilterChip("365D", 365),
                buildFilterChip("ALL", -1),
              ],
            ),
          ),

          const SizedBox(height: 12),

          Expanded(
  child: loading
      ? const Center(
          child: CircularProgressIndicator(),
        )
      : Row(
          children: [

            // FROZEN DATE COLUMN

            SizedBox(
              width: 90,

              child: Column(
                children: [

                  Container(
                    height: 56,
                    alignment: Alignment.center,
                    child: const Text(
                      "Date",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  Expanded(
                    child: ListView.builder(
                      controller: dateController,
                      itemCount: records.length,
                      

                      itemBuilder: (context, index) {
                        final day = records[index];

                        return Container(
                          height: 52,

                          alignment: Alignment.center,

                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: Colors.grey.shade800,
                              ),
                            ),
                          ),

                          child: Text(
                            "${day.date.day} "
                            "${_monthName(day.date.month)}",
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            // SCROLLABLE TABLE

            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,

                child: SizedBox(
                  width: 700,

                  child: Column(
                    children: [

                      Container(
                        height: 56,

                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Colors.grey.shade800,
                            ),
                          ),
                        ),

                        child: const Row(
                          children: [

                            SizedBox(
                              width: 90,
                              child: Center(
                                child: Text(
                                  "BB",
                                  style: TextStyle(
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),

                            SizedBox(
                              width: 90,
                              child: Center(
                                child: Text(
                                  "AB",
                                  style: TextStyle(
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),

                            SizedBox(
                              width: 90,
                              child: Center(
                                child: Text(
                                  "BL",
                                  style: TextStyle(
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),

                            SizedBox(
                              width: 90,
                              child: Center(
                                child: Text(
                                  "AL",
                                  style: TextStyle(
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),

                            SizedBox(
                              width: 90,
                              child: Center(
                                child: Text(
                                  "BD",
                                  style: TextStyle(
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),

                            SizedBox(
                              width: 90,
                              child: Center(
                                child: Text(
                                  "AD",
                                  style: TextStyle(
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),

                            SizedBox(
                              width: 90,
                              child: Center(
                                child: Text(
                                  "L",
                                  style: TextStyle(
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      Expanded(
                        child: ListView.builder(
                          itemCount: records.length,

                          itemBuilder: (
                            context,
                            index,
                          ) {
                            final day =
                                records[index];

                            return Container(
                              height: 52,

                              decoration:
                                  BoxDecoration(
                                border: Border(
                                  bottom:
                                      BorderSide(
                                    color: Colors
                                        .grey
                                        .shade800,
                                  ),
                                ),
                              ),

                              child: Row(
                                children: [

                                  SizedBox(
                                    width: 90,
                                    child: Center(
                                      child:
                                          buildCell(
                                        day,
                                        "Before Breakfast",
                                      ),
                                    ),
                                  ),

                                  SizedBox(
                                    width: 90,
                                    child: Center(
                                      child:
                                          buildCell(
                                        day,
                                        "After Breakfast",
                                      ),
                                    ),
                                  ),

                                  SizedBox(
                                    width: 90,
                                    child: Center(
                                      child:
                                          buildCell(
                                        day,
                                        "Before Lunch",
                                      ),
                                    ),
                                  ),

                                  SizedBox(
                                    width: 90,
                                    child: Center(
                                      child:
                                          buildCell(
                                        day,
                                        "After Lunch",
                                      ),
                                    ),
                                  ),

                                  SizedBox(
                                    width: 90,
                                    child: Center(
                                      child:
                                          buildCell(
                                        day,
                                        "Before Dinner",
                                      ),
                                    ),
                                  ),

                                  SizedBox(
                                    width: 90,
                                    child: Center(
                                      child:
                                          buildCell(
                                        day,
                                        "After Dinner",
                                      ),
                                    ),
                                  ),

                                  SizedBox(
                                    width: 90,
                                    child: Center(
                                      child:
                                          buildCell(
                                        day,
                                        "Before Lantus",
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
)
        ],
      ),
    );
  }

}
