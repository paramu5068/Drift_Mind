import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../analytics/provider/usage_provider.dart';
import '../../auth/screens/auth_wrapper.dart';

class PermissionsScreen extends ConsumerStatefulWidget {
  const PermissionsScreen({super.key});

  @override
  ConsumerState<PermissionsScreen> createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends ConsumerState<PermissionsScreen> with WidgetsBindingObserver {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkPermission();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkPermission();
    }
  }

  Future<void> _checkPermission() async {
    final service = ref.read(usageServiceProvider);
    final hasPermission = await service.hasPermission();
    if (hasPermission && mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const AuthWrapper()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.errorContainer.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(40),
                ),
                child: Icon(
                  Icons.lock_person_rounded,
                  size: 80,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 48),
              Text(
                'Data Access Required',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 24),
              Text(
                'To analyze your routine, Drift Mind needs permission to view app usage statistics. This data stays locally on your device.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () async {
                  final service = ref.read(usageServiceProvider);
                  await service.openSettings();
                },
                child: const Text('Grant Access'),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () async {
                  await Hive.box('settings').put('onboarding_completed', true);
                  if (!context.mounted) return;
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => const AuthWrapper()),
                  );
                },
                child: const Text('Maybe Later'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
