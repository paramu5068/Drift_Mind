import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/provider/auth_provider.dart';
import '../../analytics/provider/usage_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final userName = ref.watch(userNameProvider);
    final syncService = ref.watch(firebaseSyncServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Management'),
      ),
      body: authState.when(
        data: (user) {
          if (user == null) return const Center(child: Text('Please log in'));
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProfileCard(context, userName.asData?.value ?? 'User', user.email ?? ''),
                const SizedBox(height: 32),
                Text(
                  'Manage Daily Screen Time',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _buildLimitSelector(context, syncService),
                const SizedBox(height: 40),
                _buildActionSection(context, ref, user.email ?? ''),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildProfileCard(BuildContext context, String name, String email) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : 'U',
                style: const TextStyle(fontSize: 32, color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    email,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.outline),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLimitSelector(BuildContext context, dynamic syncService) {
    return StreamBuilder<double>(
      stream: syncService.dailyLimitStream,
      builder: (context, snapshot) {
        final limit = snapshot.data ?? 8.0;
        return Card(
          elevation: 0,
          color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Daily Goal Limit', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                    Text('${limit.toInt()} Hours', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary)),
                  ],
                ),
                const SizedBox(height: 16),
                Slider(
                  value: limit,
                  min: 1,
                  max: 24,
                  divisions: 23,
                  label: '${limit.toInt()}h',
                  onChanged: (value) {
                    syncService.setDailyLimit(value);
                  },
                ),
                Text(
                  'We will notify you once you cross this limit.',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Theme.of(context).colorScheme.outline),
                ),
              ],
            ),
          ),
        );
      }
    );
  }

  Widget _buildActionSection(BuildContext context, WidgetRef ref, String email) {
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.lock_reset_rounded),
          title: const Text('Reset Password'),
          subtitle: const Text('Send a password reset link to your email'),
          onTap: () {
            ref.read(authServiceProvider).resetPassword(email);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Reset email sent!')),
            );
          },
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.logout_rounded, color: Colors.red),
          title: const Text('Logout', style: TextStyle(color: Colors.red)),
          onTap: () {
            ref.read(authServiceProvider).signOut();
            Navigator.pop(context);
          },
        ),
      ],
    );
  }
}
