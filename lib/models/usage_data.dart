class UsageData {
  final String appName;
  final String packageName;
  final Duration totalTimeVisible;
  final DateTime lastUsed;
  final int unlockCount;

  UsageData({
    required this.appName,
    required this.packageName,
    required this.totalTimeVisible,
    required this.lastUsed,
    this.unlockCount = 0,
  });

  factory UsageData.fromMap(Map<dynamic, dynamic> map) {
    return UsageData(
      appName: map['appName'] ?? 'Unknown',
      packageName: map['packageName'] ?? '',
      totalTimeVisible: Duration(milliseconds: map['totalTimeVisible'] ?? 0),
      lastUsed: DateTime.fromMillisecondsSinceEpoch(map['lastUsed'] ?? 0),
      unlockCount: map['unlockCount'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'appName': appName,
      'packageName': packageName,
      'totalTimeVisible': totalTimeVisible.inMilliseconds,
      'lastUsed': lastUsed.millisecondsSinceEpoch,
      'unlockCount': unlockCount,
    };
  }
}

class DailySummary {
  final DateTime date;
  final Duration totalScreenTime;
  final List<UsageData> appUsage;
  final int totalUnlocks;

  DailySummary({
    required this.date,
    required this.totalScreenTime,
    required this.appUsage,
    required this.totalUnlocks,
  });
}
