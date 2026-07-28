import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_providers.dart';

/// Emite cada cambio de sesión (login, logout, refresh de token).
final authStateChangesProvider = StreamProvider<AuthState>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return client.auth.onAuthStateChange;
});

/// Id del usuario autenticado actualmente, o null si no hay sesión.
final currentUserIdProvider = Provider<String?>((ref) {
  final authState = ref.watch(authStateChangesProvider).valueOrNull;
  return authState?.session?.user.id ??
      ref.watch(supabaseClientProvider).auth.currentUser?.id;
});
