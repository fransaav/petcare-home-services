import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/service_category.dart';
import '../../models/service_provider.dart';

class ProvidersRepository {
  final SupabaseClient _client;
  const ProvidersRepository(this._client);

  /// Proveedores activos que ofrecen la categoría indicada y tienen
  /// capacidad disponible.
  Future<List<ServiceProvider>> getAvailableProviders(
    ServiceCategory category,
  ) async {
    final rows = await _client
        .from('providers')
        .select('*, provider_services!inner(category)')
        .eq('active', true)
        .eq('provider_services.category', category.dbValue);

    return rows
        .map((row) {
          final services = (row['provider_services'] as List<dynamic>)
              .map((s) => ServiceCategory.fromDb(s['category'] as String))
              .toSet();
          return ServiceProvider.fromMap(row, offeredServices: services);
        })
        .where((p) => p.hasAvailableCapacity)
        .toList();
  }

  /// Busca el proveedor vinculado al perfil del usuario autenticado
  /// (para el dashboard de proveedor).
  Future<ServiceProvider?> getProviderByProfileId(String profileId) async {
    final rows = await _client
        .from('providers')
        .select('*, provider_services(category)')
        .eq('profile_id', profileId)
        .limit(1);
    if (rows.isEmpty) return null;
    final row = rows.first;
    final services = (row['provider_services'] as List<dynamic>)
        .map((s) => ServiceCategory.fromDb(s['category'] as String))
        .toSet();
    return ServiceProvider.fromMap(row, offeredServices: services);
  }
}
