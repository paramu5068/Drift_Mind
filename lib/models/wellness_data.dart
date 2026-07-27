class SleepData {
  final DateTime sleepStart;
  final DateTime sleepEnd;
  final Duration duration;
  final double qualityScore; // 0.0 to 1.0

  SleepData({
    required this.sleepStart,
    required this.sleepEnd,
    required this.duration,
    this.qualityScore = 0.8,
  });

  factory SleepData.calculate(DateTime lastActivity, DateTime firstActivity) {
    final duration = firstActivity.difference(lastActivity);
    return SleepData(
      sleepStart: lastActivity,
      sleepEnd: firstActivity,
      duration: duration,
    );
  }
}

class FocusSession {
  final DateTime startTime;
  final Duration duration;
  final int interruptions; // app switches
  final String primaryCategory;

  FocusSession({
    required this.startTime,
    required this.duration,
    required this.interruptions,
    required this.primaryCategory,
  });

  double get focusScore {
    if (duration.inMinutes == 0) return 0;
    return (1.0 - (interruptions / (duration.inMinutes / 10 + 1))).clamp(0.0, 1.0);
  }
}
