import 'service_category.dart';

enum DeliveryMode {
  pickupDropOff,
  homeVisit;

  static DeliveryMode fromDb(String value) => switch (value) {
        'pickup_drop_off' => DeliveryMode.pickupDropOff,
        'home_visit' => DeliveryMode.homeVisit,
        _ => throw ArgumentError('Modalidad desconocida: $value'),
      };

  String get dbValue =>
      this == DeliveryMode.pickupDropOff ? 'pickup_drop_off' : 'home_visit';
}

enum PaymentMethod {
  online,
  atLocation;

  static PaymentMethod fromDb(String value) => switch (value) {
        'online' => PaymentMethod.online,
        'at_location' => PaymentMethod.atLocation,
        _ => throw ArgumentError('Método de pago desconocido: $value'),
      };

  String get dbValue => this == PaymentMethod.online ? 'online' : 'at_location';
}

enum BookingStatus {
  pending,
  confirmed,
  inProgress,
  completed,
  rejected,
  cancelled;

  static BookingStatus fromDb(String value) => switch (value) {
        'pending' => BookingStatus.pending,
        'confirmed' => BookingStatus.confirmed,
        'in_progress' => BookingStatus.inProgress,
        'completed' => BookingStatus.completed,
        'rejected' => BookingStatus.rejected,
        'cancelled' => BookingStatus.cancelled,
        _ => throw ArgumentError('Estado de reserva desconocido: $value'),
      };

  String get dbValue => switch (this) {
        BookingStatus.pending => 'pending',
        BookingStatus.confirmed => 'confirmed',
        BookingStatus.inProgress => 'in_progress',
        BookingStatus.completed => 'completed',
        BookingStatus.rejected => 'rejected',
        BookingStatus.cancelled => 'cancelled',
      };

  String get label => switch (this) {
        BookingStatus.pending => 'Pendiente',
        BookingStatus.confirmed => 'Confirmado',
        BookingStatus.inProgress => 'En Progreso',
        BookingStatus.completed => 'Completado',
        BookingStatus.rejected => 'Rechazado',
        BookingStatus.cancelled => 'Cancelado',
      };
}

/// Reserva de un servicio (tabla `bookings`).
///
/// Los datos de mascota/dueño/proveedor se resuelven por id; las pantallas
/// obtienen los nombres a mostrar uniendo con los providers de Riverpod
/// correspondientes (petsProvider, providersProvider, etc.).
class Booking {
  final String id;
  final String petId;
  final String ownerId;
  final String providerId;
  final String? serviceId;
  final ServiceCategory category;
  final DeliveryMode deliveryMode;
  final PaymentMethod paymentMethod;
  final DateTime scheduledAt;
  final String? address;
  final double price;
  final String? promotionId;
  final BookingStatus status;
  final String? rejectionReason;

  const Booking({
    required this.id,
    required this.petId,
    required this.ownerId,
    required this.providerId,
    this.serviceId,
    required this.category,
    required this.deliveryMode,
    required this.paymentMethod,
    required this.scheduledAt,
    this.address,
    required this.price,
    this.promotionId,
    required this.status,
    this.rejectionReason,
  });

  Booking copyWith({BookingStatus? status, String? rejectionReason}) {
    return Booking(
      id: id,
      petId: petId,
      ownerId: ownerId,
      providerId: providerId,
      serviceId: serviceId,
      category: category,
      deliveryMode: deliveryMode,
      paymentMethod: paymentMethod,
      scheduledAt: scheduledAt,
      address: address,
      price: price,
      promotionId: promotionId,
      status: status ?? this.status,
      rejectionReason: rejectionReason ?? this.rejectionReason,
    );
  }

  factory Booking.fromMap(Map<String, dynamic> map) {
    return Booking(
      id: map['id'] as String,
      petId: map['pet_id'] as String,
      ownerId: map['owner_id'] as String,
      providerId: map['provider_id'] as String,
      serviceId: map['service_id'] as String?,
      category: ServiceCategory.fromDb(map['category'] as String),
      deliveryMode: DeliveryMode.fromDb(map['delivery_mode'] as String),
      paymentMethod: PaymentMethod.fromDb(map['payment_method'] as String),
      scheduledAt: DateTime.parse(map['scheduled_at'] as String),
      address: map['address'] as String?,
      price: (map['price'] as num).toDouble(),
      promotionId: map['promotion_id'] as String?,
      status: BookingStatus.fromDb(map['status'] as String),
      rejectionReason: map['rejection_reason'] as String?,
    );
  }

  Map<String, dynamic> toInsertMap() => {
        'pet_id': petId,
        'owner_id': ownerId,
        'provider_id': providerId,
        'service_id': serviceId,
        'category': category.dbValue,
        'delivery_mode': deliveryMode.dbValue,
        'payment_method': paymentMethod.dbValue,
        'scheduled_at': scheduledAt.toIso8601String(),
        'address': address,
        'price': price,
        'promotion_id': promotionId,
        'status': status.dbValue,
      };
}
