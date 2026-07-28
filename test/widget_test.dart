// Smoke test: la pantalla de login se muestra correctamente cuando no hay
// una sesión activa de Supabase. No requiere credenciales reales porque
// LoginScreen no llama a Supabase durante el build inicial.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:petcare_home_services/screens/auth/login_screen.dart';

void main() {
  testWidgets('LoginScreen muestra el título y el formulario de acceso',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: LoginScreen()),
      ),
    );

    expect(find.text('PetCare Home Services'), findsOneWidget);
    expect(find.text('Iniciar Sesión'), findsOneWidget);
    expect(find.text('Correo electrónico'), findsOneWidget);
  });
}
