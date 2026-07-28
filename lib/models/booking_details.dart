import 'booking.dart';

/// Vista de una reserva con los nombres ya resueltos (mascota, dueño,
/// servicio), para mostrar directamente en las tarjetas de la UI sin
/// que cada widget tenga que hacer sus propias consultas.
class BookingDetails {
  final Booking booking;
  final String petName;
  final String clientName;
  final String serviceName;

  const BookingDetails({
    required this.booking,
    required this.petName,
    required this.clientName,
    required this.serviceName,
  });

  factory BookingDetails.fromMap(Map<String, dynamic> map) {
    final petMap = map['pets'] as Map<String, dynamic>?;
    final profileMap = map['profiles'] as Map<String, dynamic>?;
    final serviceMap = map['services'] as Map<String, dynamic>?;
    return BookingDetails(
      booking: Booking.fromMap(map),
      petName: (petMap?['name'] as String?) ?? 'Mascota',
      clientName: (profileMap?['full_name'] as String?) ?? 'Cliente',
      serviceName:
          (serviceMap?['name'] as String?) ?? (map['category'] as String),
    );
  }
}
