import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/service.dart';
import '../providers/data_providers.dart';
import '../widgets/service_card.dart';
import 'booking_screen.dart';
import 'provider_dashboard_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final servicesAsync = ref.watch(servicesProvider);
    final profileAsync = ref.watch(currentProfileProvider);
    final greetingName = profileAsync.valueOrNull?.fullName.isNotEmpty == true
        ? profileAsync.valueOrNull!.fullName.split(' ').first
        : 'Usuario';

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(servicesProvider),
        child: CustomScrollView(
          slivers: [
            SliverAppBar.large(
              title: const Text('PetCare Home Services'),
              actions: [
                Tooltip(
                  message: 'Vista Proveedor',
                  child: IconButton(
                    icon: const Icon(Icons.business_center_outlined),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ProviderDashboardScreen(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
            ),

            // Banner de bienvenida
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              sliver: SliverToBoxAdapter(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        colorScheme.primaryContainer,
                        colorScheme.secondaryContainer,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '¡Hola, $greetingName! 👋',
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onPrimaryContainer,
                                ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '¿Qué servicio necesita tu mascota hoy?',
                        style: TextStyle(color: colorScheme.onPrimaryContainer),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Título de sección
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
              sliver: SliverToBoxAdapter(
                child: Text(
                  'Servicios Disponibles',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
            ),

            // Cuadrícula de servicios
            servicesAsync.when(
              data: (services) => SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.82,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final Service service = services[index];
                      return ServiceCard(
                        service: service,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BookingScreen(service: service),
                          ),
                        ),
                      );
                    },
                    childCount: services.length,
                  ),
                ),
              ),
              loading: () => const SliverPadding(
                padding: EdgeInsets.all(32),
                sliver: SliverToBoxAdapter(
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
              error: (error, stackTrace) => SliverPadding(
                padding: const EdgeInsets.all(32),
                sliver: SliverToBoxAdapter(
                  child: Center(
                      child:
                          Text('No se pudieron cargar los servicios.\n$error')),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
    );
  }
}
