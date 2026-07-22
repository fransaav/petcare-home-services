import 'package:flutter/material.dart';
import 'screens/main_navigation.dart';
import 'screens/booking_screen.dart';
import 'screens/provider_dashboard_screen.dart';

void main() {
  runApp(const PetCareApp());
}

class PetCareApp extends StatelessWidget {
  const PetCareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PetCare Home Services',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(209, 4, 17, 185), 
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const MainNavigation(),
      routes: {
        '/home': (_) => const MainNavigation(),
        '/booking': (_) => const BookingScreen(),
        '/provider': (_) => const ProviderDashboardScreen(),
      },
    );
  }
}
