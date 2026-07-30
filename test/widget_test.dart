import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:drift_mind/features/splash/splash_screen.dart';
import 'package:drift_mind/models/usage_data.dart';
import 'package:drift_mind/models/wellness_data.dart';
import 'package:drift_mind/core/theme/app_theme.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    final tempDir = await Directory.systemTemp.createTemp('drift_mind_hive_test');
    Hive.init(tempDir.path);
    await Hive.openBox('settings');
  });

  group('Drift Mind Real-Time App Tests', () {
    testWidgets('Splash Screen renders logo and app title correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const SplashScreen(),
        ),
      );

      // Verify logo icon and app title branding
      expect(find.text('Drift Mind'), findsOneWidget);
      expect(find.text('Find your rhythm'), findsOneWidget);
      expect(find.byIcon(Icons.psychology_outlined), findsOneWidget);

      // Advance timer to clear 3s splash delay timer
      await tester.pump(const Duration(seconds: 4));
    });

    test('UsageData serialization and model validation', () {
      final usageMap = {
        'appName': 'Instagram',
        'packageName': 'com.instagram.android',
        'totalTimeVisible': 3600000, // 1 hour in ms
        'lastUsed': 1700000000000,
        'unlockCount': 12,
      };

      final usage = UsageData.fromMap(usageMap);
      expect(usage.appName, equals('Instagram'));
      expect(usage.packageName, equals('com.instagram.android'));
      expect(usage.totalTimeVisible.inHours, equals(1));
      expect(usage.unlockCount, equals(12));

      final serializedMap = usage.toMap();
      expect(serializedMap['appName'], equals('Instagram'));
      expect(serializedMap['totalTimeVisible'], equals(3600000));
      expect(serializedMap['unlockCount'], equals(12));
    });

    test('FocusSession focus score calculation', () {
      final session = FocusSession(
        startTime: DateTime.now(),
        duration: const Duration(minutes: 50),
        interruptions: 2,
        primaryCategory: 'Productivity',
      );

      final score = session.focusScore;
      expect(score, greaterThan(0.0));
      expect(score, lessThanOrEqualTo(1.0));
    });

    test('SleepData calculation logic', () {
      final lastAct = DateTime(2026, 7, 30, 23, 0);
      final firstAct = DateTime(2026, 7, 31, 7, 0);
      final sleep = SleepData.calculate(lastAct, firstAct);

      expect(sleep.duration.inHours, equals(8));
      expect(sleep.qualityScore, equals(0.8));
    });

    test('AppTheme configuration validity', () {
      expect(AppTheme.lightTheme.useMaterial3, isTrue);
      expect(AppTheme.darkTheme.useMaterial3, isTrue);
      expect(AppTheme.lightTheme.brightness, equals(Brightness.light));
      expect(AppTheme.darkTheme.brightness, equals(Brightness.dark));
    });
  });
}
