import '../../models/glucose_log.dart';

class DailyRecord {
  final DateTime date;

  final Map<String, List<GlucoseLog>> slots;

  DailyRecord({required this.date, required this.slots});
}

class RecordsHelper {
  static List<DailyRecord> groupLogs(List<GlucoseLog> logs) {
    final Map<DateTime, List<GlucoseLog>> groupedByDate = {};

    for (final log in logs) {
      final day = DateTime(
        log.timestamp.year,
        log.timestamp.month,
        log.timestamp.day,
      );

      groupedByDate.putIfAbsent(day, () => []);

      groupedByDate[day]!.add(log);
    }

    final result = <DailyRecord>[];

    for (final entry in groupedByDate.entries) {
      final Map<String, List<GlucoseLog>> mealSlots = {};

      for (final log in entry.value) {
        mealSlots.putIfAbsent(log.mealType, () => []);

        mealSlots[log.mealType]!.add(log);
      }

      result.add(DailyRecord(date: entry.key, slots: mealSlots));
    }

    result.sort((a, b) => b.date.compareTo(a.date));

    return result;
  }
}
