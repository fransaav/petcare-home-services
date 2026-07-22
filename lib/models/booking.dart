enum ServiceType { pickup, homeVisit }

enum BookingStatus { pending, confirmed, inProgress, completed, rejected }

class Booking {
  final String id;
  final String clientName;
  final String petName;
  final String serviceName;
  final String date;
  final String time;
  final String address;
  final ServiceType serviceType;
  final BookingStatus status;

  const Booking({
    required this.id,
    required this.clientName,
    required this.petName,
    required this.serviceName,
    required this.date,
    required this.time,
    required this.address,
    required this.serviceType,
    required this.status,
  });

  Booking copyWith({BookingStatus? status}) {
    return Booking(
      id: id,
      clientName: clientName,
      petName: petName,
      serviceName: serviceName,
      date: date,
      time: time,
      address: address,
      serviceType: serviceType,
      status: status ?? this.status,
    );
  }
}

// ── Datos simulados (dummy data) ──────────────────────────────────────────────
const List<Booking> dummyBookings = [
  Booking(
    id: '1',
    clientName: 'María García',
    petName: 'Max',
    serviceName: 'Peluquería',
    date: '22 Jul 2026',
    time: '10:00 AM',
    address: 'Calle Principal 123, Ciudad',
    serviceType: ServiceType.homeVisit,
    status: BookingStatus.pending,
  ),
  Booking(
    id: '2',
    clientName: 'Carlos López',
    petName: 'Luna',
    serviceName: 'Visita Veterinaria',
    date: '22 Jul 2026',
    time: '02:00 PM',
    address: 'Av. Central 456, Ciudad',
    serviceType: ServiceType.pickup,
    status: BookingStatus.pending,
  ),
  Booking(
    id: '3',
    clientName: 'Ana Martínez',
    petName: 'Coco',
    serviceName: 'Paseo de Perros',
    date: '23 Jul 2026',
    time: '08:00 AM',
    address: 'Blvd. Norte 789, Ciudad',
    serviceType: ServiceType.homeVisit,
    status: BookingStatus.confirmed,
  ),
];
