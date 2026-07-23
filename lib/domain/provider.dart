import 'service_category.dart';

/// Naturaleza contractual de un proveedor.
enum ProviderType { employee, contractor, franchise }

/// Entidad de dominio: Proveedor de servicios.
///
/// Invariante: un proveedor franquicia debe estar asociado a una sucursal
/// (branch); todo proveedor debe ofrecer al menos un tipo de servicio y
/// declarar una capacidad diaria positiva.
class Provider {
  final String id;
  final String name;
  final ProviderType type;
  final String? branchId;
  final int _dailyCapacity;

  final Set<ServiceCategory> _offeredServices;
  int _activeBookings = 0;
  bool _active = true;

  Provider({
    required this.id,
    required this.name,
    required this.type,
    this.branchId,
    required Set<ServiceCategory> offeredServices,
    required int dailyCapacity,
  })  : _offeredServices = Set.of(offeredServices),
        _dailyCapacity = dailyCapacity {
    if (id.trim().isEmpty) {
      throw ArgumentError('El id del proveedor no puede estar vacío.');
    }
    if (name.trim().isEmpty) {
      throw ArgumentError('El nombre del proveedor no puede estar vacío.');
    }
    if (offeredServices.isEmpty) {
      throw ArgumentError(
        'El proveedor debe ofrecer al menos un tipo de servicio.',
      );
    }
    if (dailyCapacity <= 0) {
      throw ArgumentError('La capacidad diaria debe ser mayor a cero.');
    }
    if (type == ProviderType.franchise &&
        (branchId == null || branchId!.trim().isEmpty)) {
      throw ArgumentError(
        'Un proveedor de tipo franquicia debe estar asociado a una sucursal.',
      );
    }
  }

  bool get isActive => _active;
  int get dailyCapacity => _dailyCapacity;
  int get activeBookings => _activeBookings;
  bool get hasAvailableCapacity => _active && _activeBookings < _dailyCapacity;
  Set<ServiceCategory> get offeredServices =>
      Set.unmodifiable(_offeredServices);

  bool offers(ServiceCategory category) => _offeredServices.contains(category);

  /// Reserva capacidad para una nueva reserva asignada a este proveedor.
  void reserveCapacity() {
    if (!_active) {
      throw ArgumentError(
        'No se puede asignar una reserva a un proveedor inactivo.',
      );
    }
    if (!hasAvailableCapacity) {
      throw ArgumentError('El proveedor no tiene capacidad disponible.');
    }
    _activeBookings++;
  }

  /// Libera capacidad al finalizar, cancelar o rechazar una reserva.
  void releaseCapacity() {
    if (_activeBookings == 0) {
      throw ArgumentError(
          'El proveedor no tiene reservas activas para liberar.');
    }
    _activeBookings--;
  }

  void deactivate() => _active = false;

  void activate() => _active = true;
}
