import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/analytics/provider/usage_provider.dart';

class AppIcon extends ConsumerWidget {
  final String packageName;
  final double size;

  const AppIcon({
    super.key,
    required this.packageName,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final service = ref.watch(usageServiceProvider);

    return FutureBuilder<String?>(
      future: service.getAppIcon(packageName),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done && snapshot.data != null) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(size * 0.25),
            child: Image.memory(
              base64Decode(snapshot.data!),
              width: size,
              height: size,
              fit: BoxFit.cover,
            ),
          );
        }
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(size * 0.25),
          ),
          child: Icon(Icons.android, size: size * 0.6),
        );
      },
    );
  }
}
