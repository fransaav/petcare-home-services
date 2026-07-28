import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repositories/bookings_repository.dart';
import '../data/repositories/pets_repository.dart';
import '../data/repositories/profile_repository.dart';
import '../data/repositories/providers_repository.dart';
import '../data/repositories/services_repository.dart';
import '../models/booking_details.dart';
import '../models/pet.dart';
import '../models/profile.dart';
import '../models/service.dart';
import '../models/service_category.dart';
import '../models/service_provider.dart';
import 'auth_providers.dart';
import 'supabase_providers.dart';

// ── Repositorios ─────────────────────────────────────────────────────────
final profileRepositoryProvider = Provider<ProfileRepository>(
  (ref) => ProfileRepository(ref.watch(supabaseClientProvider)),
);
final petsRepositoryProvider = Provider<PetsRepository>(
  (ref) => PetsRepository(ref.watch(supabaseClientProvider)),
);
final servicesRepositoryProvider = Provider<ServicesRepository>(
  (ref) => ServicesRepository(ref.watch(supabaseClientProvider)),
);
final providersRepositoryProvider = Provider<ProvidersRepository>(
  (ref) => ProvidersRepository(ref.watch(supabaseClientProvider)),
);
final bookingsRepositoryProvider = Provider<BookingsRepository>(
  (ref) => BookingsRepository(ref.watch(supabaseClientProvider)),
);

// ── Perfil del usuario autenticado ───────────────────────────────────────
final currentProfileProvider = FutureProvider<Profile?>((ref) async {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return null;
  return ref.watch(profileRepositoryProvider).getProfile(userId);
});

// ── Mascotas del dueño autenticado ───────────────────────────────────────
final petsProvider = FutureProvider<List<Pet>>((ref) async {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return [];
  return ref.watch(petsRepositoryProvider).getPetsByOwner(userId);
});

// ── Catálogo de servicios ────────────────────────────────────────────────
final servicesProvider = FutureProvider<List<Service>>((ref) {
  return ref.watch(servicesRepositoryProvider).getActiveServices();
});

// ── Proveedores disponibles para una categoría ───────────────────────────
final availableProvidersProvider =
    FutureProvider.family<List<ServiceProvider>, ServiceCategory>(
  (ref, category) {
    return ref
        .watch(providersRepositoryProvider)
        .getAvailableProviders(category);
  },
);

// ── Proveedor vinculado al perfil autenticado (dashboard proveedor) ─────
final currentProviderProfileProvider =
    FutureProvider<ServiceProvider?>((ref) async {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return null;
  return ref.watch(providersRepositoryProvider).getProviderByProfileId(userId);
});

// ── Reservas del proveedor autenticado, en tiempo real ──────────────────
final providerBookingsProvider =
    StreamProvider.family<List<BookingDetails>, String>((ref, providerId) {
  return ref
      .watch(bookingsRepositoryProvider)
      .watchProviderBookings(providerId);
});

// ── Historial de reservas del dueño autenticado ──────────────────────────
final ownerBookingsProvider = FutureProvider<List<BookingDetails>>((ref) async {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return [];
  return ref.watch(bookingsRepositoryProvider).getOwnerBookings(userId);
});
