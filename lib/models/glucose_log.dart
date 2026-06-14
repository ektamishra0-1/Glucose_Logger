enum LogType {
  beforeBreakfast,
  afterBreakfast,
  beforeLunch,
  afterLunch,
  beforeDinner,
  afterDinner,
  beforeLantus,
}

class GlucoseLog {
  final int? id;
  final DateTime timestamp;
  final String mealType;
  final double glucose;
  final double? insulin;
  final bool exercised;
  final String? notes;

  GlucoseLog({
    this.id,
    required this.timestamp,
    required this.mealType,
    required this.glucose,
    this.insulin,
    required this.exercised,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'meal_type': mealType,
      'glucose': glucose,
      'insulin': insulin,
      'exercised': exercised ? 1 : 0,
      'notes': notes,
    };
  }

  factory GlucoseLog.fromMap(Map<String, dynamic> map) {
    return GlucoseLog(
      id: map['id'],
      timestamp: DateTime.parse(map['timestamp']),
      mealType: map['meal_type'],
      glucose: map['glucose'],
      insulin: map['insulin'],
      exercised: map['exercised'] == 1,
      notes: map['notes'],
    );
  }
  bool isSameDay(DateTime other) {
    return timestamp.year == other.year &&
        timestamp.month == other.month &&
        timestamp.day == other.day;
  }

  DateTime get dateOnly =>
      DateTime(timestamp.year, timestamp.month, timestamp.day);
}
