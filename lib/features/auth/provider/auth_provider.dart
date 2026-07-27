import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../services/firebase/auth_service.dart';

final authServiceProvider = Provider((ref) => AuthService());

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

final userNameProvider = FutureProvider<String?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.when(
    data: (user) {
      if (user == null) return null;
      return ref.read(authServiceProvider).getUserName();
    },
    loading: () => null,
    error: (_, _) => null,
  );
});
