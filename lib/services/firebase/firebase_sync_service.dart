import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../native_tracking/usage_service.dart';

class FirebaseSyncService {
  final UsageService _usageService;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  Timer? _pollingTimer;
  Timer? _weeklySyncTimer;
  StreamSubscription<User?>? _authSubscription;
  String? _userId;

  FirebaseSyncService(this._usageService);

  Future<void> initialize() async {
    _authSubscription = _auth.authStateChanges().listen((user) {
      _userId = user?.uid;
      if (_userId != null) {
        // Immediate sync on auth change to prevent "empty doc" errors for new accounts
        syncAllData();
      }
    });

    _userId = _auth.currentUser?.uid;
    _startSyncLoops();
  }

  void _startSyncLoops() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 30), (_) async {
      await syncDailyAndAppData();
    });

    _weeklySyncTimer?.cancel();
    _weeklySyncTimer = Timer.periodic(const Duration(hours: 1), (_) async {
      await syncWeeklyData();
    });
  }

  Future<void> syncAllData() async {
    await syncDailyAndAppData();
    await syncWeeklyData();
  }

  Future<void> syncDailyAndAppData() async {
    if (_userId == null) return;
    
    try {
      final totalSOT = await _usageService.getTotalScreenTime();
      final appStats = await _usageService.getDailyUsageStats();
      
      final Map<String, int> appUsageMap = {};
      int calculatedTotalMs = 0;
      for (var app in appStats) {
        final ms = app.totalTimeVisible.inMilliseconds;
        appUsageMap[app.packageName.replaceAll('.', '_')] = ms;
        calculatedTotalMs += ms;
      }

      final int finalTotalScreenTimeMs = calculatedTotalMs > 0 ? calculatedTotalMs : totalSOT.inMilliseconds;

      final unlockCount = await _usageService.getUnlockCount();
      final sleepStats = await _usageService.getSleepStats();
      final int sleepMs = sleepStats?.duration.inMilliseconds ?? 0;
      final double sleepHours = sleepStats != null ? (sleepStats.duration.inMinutes / 60.0) : 0.0;

      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('metrics')
          .doc('daily')
          .set({
        'totalScreenTimeMs': finalTotalScreenTimeMs,
        'unlockCount': unlockCount,
        'sleepMs': sleepMs,
        'sleepHours': sleepHours,
        'appUsage': appUsageMap,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      
    } catch (e) {
      debugPrint('Daily Sync Error: $e');
    }
  }

  Future<void> syncWeeklyData() async {
    if (_userId == null) return;
    
    try {
      final weeklyData = await _usageService.getWeeklyUsage();
      final weeklyMs = weeklyData.map((d) => d.inMilliseconds).toList();

      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('metrics')
          .doc('weekly')
          .set({
        'days': weeklyMs,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Weekly Sync Error: $e');
    }
  }

  Future<void> setDailyLimit(double hours) async {
    if (_userId == null) return;
    await _firestore.collection('users').doc(_userId).collection('settings').doc('limits').set({
      'dailyLimitHours': hours,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<double> get dailyLimitStream {
    if (_userId == null) return Stream.value(8.0);
    return _firestore
        .collection('users')
        .doc(_userId)
        .collection('settings')
        .doc('limits')
        .snapshots()
        .handleError((_) => 8.0)
        .map((snap) => (snap.data()?['dailyLimitHours'] as num?)?.toDouble() ?? 8.0);
  }

  Stream<Duration> get liveScreenTimeStream async* {
    // 1. Instantly yield local data to ensure NO ERROR on first load
    final initialSOT = await _usageService.getTotalScreenTime();
    yield initialSOT;

    // 2. Continuous stream from Firestore with robust error handling
    await for (final user in _auth.authStateChanges()) {
      if (user != null) {
        yield* _firestore
            .collection('users')
            .doc(user.uid)
            .collection('metrics')
            .doc('daily')
            .snapshots()
            .map((snapshot) {
              if (snapshot.exists && snapshot.data() != null) {
                final ms = snapshot.data()!['totalScreenTimeMs'] as int? ?? 0;
                return Duration(milliseconds: ms);
              }
              return initialSOT;
            })
            .handleError((error) {
              debugPrint('Firestore Stream Error suppressed: $error');
              return initialSOT;
            });
      } else {
        yield* Stream.periodic(const Duration(seconds: 15), (_) async => await _usageService.getTotalScreenTime()).asyncMap((event) => event);
      }
    }
  }

  void dispose() {
    _pollingTimer?.cancel();
    _weeklySyncTimer?.cancel();
    _authSubscription?.cancel();
  }
}
