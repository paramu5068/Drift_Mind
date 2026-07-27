import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../onboarding/screens/onboarding_screen.dart';
import '../auth/screens/auth_wrapper.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _controller.forward();

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        final box = Hive.box('settings');
        final bool onboardingCompleted = box.get('onboarding_completed', defaultValue: false);

        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => 
                onboardingCompleted ? const AuthWrapper() : const OnboardingScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(32),
                ),
                child: const Icon(
                  Icons.psychology_outlined,
                  size: 64,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Drift Mind',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 40,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Find your rhythm',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
