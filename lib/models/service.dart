import 'service_category.dart';

/// Servicio reservable del catálogo (tabla `services`).
class Service {
  final String id;
  final String name;
  final String description;
  final double price;
  final String icon;
  final ServiceCategory category;

  const Service({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.icon,
    required this.category,
  });

  factory Service.fromMap(Map<String, dynamic> map) {
    return Service(
      id: map['id'] as String,
      name: map['name'] as String,
      description: (map['description'] as String?) ?? '',
      price: (map['price'] as num).toDouble(),
      icon: (map['icon'] as String?) ?? '🐾',
      category: ServiceCategory.fromDb(map['category'] as String),
    );
  }
}
