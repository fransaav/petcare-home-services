import 'pet.dart';
import 'promotion.dart';
import 'provider.dart';
import 'service_category.dart';

/// Modalidad de entrega del servicio.
enum DeliveryMode { pickupDropOff, homeVisit }

/// Método de pago de la reserva.
enum PaymentMethod { online, atLocation }

/// Ciclo de vida de una reserva.
enum BookingStatus {
  pending,
  confirmed,
  inProgress,
  completed,
  rejected,
  cancelled
}

/// Entidad de dominio: Reserva.
///
/// Invariantes validadas en construcción:
/// - Una reserva a domicilio (homeVisit) requiere dirección para la
///   integración con servicios de mapas.
/// - El proveedor debe ofrecer la categoría de servicio solicitada.
/// - Si el servicio requiere verificación de vacunación, la mascota debe
///   contar con un registro verificado.
/// - Una promoción, si se aplica, debe corresponder al proveedor asignado.
class Booking {
  final String id;
  final String petId;
  final String ownerId;
  final String providerId;
  final ServiceCategory serviceCategory;
  final DeliveryMode deliveryMode;
  final PaymentMethod paymentMethod;
  final DateTime scheduledAt;
  final String? address;
  final double price;
  final Promotion? _promotion;

  BookingStatus _status = BookingStatus.pending;
  String? _rejectionReason;

  Booking({
    required this.id,
    required Pet pet,
    required Provider provider,
    required this.serviceCategory,
    required this.deliveryMode,
    required this.paymentMethod,
    required this.scheduledAt,
    required this.price,
    this.address,
    Promotion? promotion,
  })  : petId = pet.id,
        ownerId = pet.ownerId,
        providerId = provider.id,
        _promotion = promotion {
    if (id.trim().isEmpty) {
      throw ArgumentError('El id de la reserva no puede estar vacío.');
    }
    if (price < 0) {
      throw ArgumentError('El precio de la reserva no puede ser negativo.');
    }
    if (deliveryMode == DeliveryMode.homeVisit &&
        (address == null || address!.trim().isEmpty)) {
      throw ArgumentError(
        'Una reserva a domicilio requiere una dirección para la integración con mapas.',
      );
    }
    if (!provider.offers(serviceCategory)) {
      throw ArgumentError(
        'El proveedor seleccionado no ofrece la categoría de servicio solicitada.',
      );
    }
    if (serviceCategory.requiresVaccinationVerification &&
        !pet.hasVerifiedVaccination) {
      throw ArgumentError(
        'Este servicio requiere un registro de vacunación verificado para la mascota.',
      );
    }
    if (promotion != null && !promotion.appliesToProvider(provider)) {
      throw ArgumentError(
        'La promoción seleccionada no aplica al proveedor de esta reserva.',
      );
    }
  }

  BookingStatus get status => _status;
  String? get rejectionReason => _rejectionReason;
  bool get hasPromotion => _promotion != null;

  double get finalPrice =>
      _promotion != null ? _promotion.applyTo(price) : price;

  /// El proveedor confirma la reserva pendiente.
  void confirm() {
    _ensureStatus(BookingStatus.pending, action: 'confirmar');
    _status = BookingStatus.confirmed;
  }

  /// El proveedor rechaza la reserva porque no se cumplen los requisitos
  /// (por ejemplo, vacunación pendiente o incompatibilidad de manejo especial).
  void rejectBooking(String reason) {
    if (reason.trim().isEmpty) {
      throw ArgumentError('Se requiere un motivo para rechazar la reserva.');
    }
    if (_status != BookingStatus.pending &&
        _status != BookingStatus.confirmed) {
      throw ArgumentError(
        'Solo se pueden rechazar reservas pendientes o confirmadas.',
      );
    }
    _status = BookingStatus.rejected;
    _rejectionReason = reason;
  }

  /// El proveedor marca el inicio de la prestación del servicio.
  void start() {
    _ensureStatus(BookingStatus.confirmed, action: 'iniciar');
    _status = BookingStatus.inProgress;
  }

  /// El proveedor marca la reserva como completada.
  void complete() {
    _ensureStatus(BookingStatus.inProgress, action: 'completar');
    _status = BookingStatus.completed;
  }

  /// El dueño de la mascota cancela la reserva antes de su finalización.
  void cancel() {
    const finalStates = {
      BookingStatus.completed,
      BookingStatus.rejected,
      BookingStatus.cancelled,
    };
    if (finalStates.contains(_status)) {
      throw ArgumentError(
          'No se puede cancelar una reserva en estado $_status.');
    }
    _status = BookingStatus.cancelled;
  }

  void _ensureStatus(BookingStatus expected, {required String action}) {
    if (_status != expected) {
      throw ArgumentError(
        'No se puede $action una reserva en estado $_status (se esperaba $expected).',
      );
    }
  }
}
