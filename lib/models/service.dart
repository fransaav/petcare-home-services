class Service {
  final String id;
  final String name;
  final String description;
  final double price;
  final String icon;
  final String category;

  const Service({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.icon,
    required this.category,
  });
}

// ── Datos simulados (dummy data) ──────────────────────────────────────────────
const List<Service> dummyServices = [
  Service(
    id: '1',
    name: 'Peluquería',
    description: 'Baño, corte y estilismo para tu mascota.',
    price: 35.0,
    icon: '✂️',
    category: 'grooming',
  ),
  Service(
    id: '2',
    name: 'Visita Veterinaria',
    description: 'Consulta médica profesional en tu hogar.',
    price: 60.0,
    icon: '🩺',
    category: 'veterinary',
  ),
  Service(
    id: '3',
    name: 'Paseo de Perros',
    description: 'Paseos diarios con cuidadores certificados.',
    price: 20.0,
    icon: '🐕',
    category: 'walking',
  ),
  Service(
    id: '4',
    name: 'Alojamiento',
    description: 'Hospedaje cómodo y seguro para tu mascota.',
    price: 45.0,
    icon: '🏠',
    category: 'boarding',
  ),
  Service(
    id: '5',
    name: 'Visita a Domicilio',
    description: 'Cuidado personalizado en la comodidad de tu casa.',
    price: 30.0,
    icon: '🏡',
    category: 'home_visit',
  ),
];
