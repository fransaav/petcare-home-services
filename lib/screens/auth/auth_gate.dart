import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_providers.dart';
import '../main_navigation.dart';
import 'login_screen.dart';

/// Punto de entrada que decide, según el estado de la sesión de Supabase,
/// si se muestra la pantalla de login o la navegación principal de la app.
class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateChangesProvider);

    return authState.when(
      data: (state) {
        final hasSession = state.session != null;
        return hasSession ? const MainNavigation() : const LoginScreen();
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stackTrace) => const LoginScreen(),
    );
  }
}
