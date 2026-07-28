import 'service_category.dart';

/// Naturaleza contractual de un proveedor.
enum ProviderKind {
  employee,
  contractor,
  franchise;

  static ProviderKind fromDb(String value) => switch (value) {
        'employee' => ProviderKind.employee,
        'contractor' => ProviderKind.contractor,
        'franchise' => ProviderKind.franchise,
        _ => throw ArgumentError('Tipo de proveedor desconocido: $value'),
      };
}

/// Proveedor de servicios (llamado `ServiceProvider` para no colisionar
/// con la clase `Provider` de Riverpod).
class ServiceProvider {
  final String id;
  final String? profileId;
  final String name;
  final ProviderKind type;
  final String? branchId;
  final int dailyCapacity;
  final int activeBookings;
  final bool active;
  final Set<ServiceCategory> offeredServices;

  const ServiceProvider({
    required this.id,
    this.profileId,
    required this.name,
    required this.type,
    this.branchId,
    required this.dailyCapacity,
    required this.activeBookings,
    required this.active,
    required this.offeredServices,
  });

  bool get hasAvailableCapacity => active && activeBookings < dailyCapacity;

  bool offers(ServiceCategory category) => offeredServices.contains(category);

  factory ServiceProvider.fromMap(
    Map<String, dynamic> map, {
    Set<ServiceCategory> offeredServices = const {},
  }) {
    return ServiceProvider(
      id: map['id'] as String,
      profileId: map['profile_id'] as String?,
      name: map['name'] as String,
      type: ProviderKind.fromDb(map['type'] as String),
      branchId: map['branch_id'] as String?,
      dailyCapacity: (map['daily_capacity'] as num).toInt(),
      activeBookings: (map['active_bookings'] as num?)?.toInt() ?? 0,
      active: (map['active'] as bool?) ?? true,
      offeredServices: offeredServices,
    );
  }
}
