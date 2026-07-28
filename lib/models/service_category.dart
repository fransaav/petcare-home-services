/// Categorías de servicio soportadas por la plataforma.
///
/// Los valores coinciden exactamente con las etiquetas del tipo enumerado
/// `service_category` definido en `supabase/migrations/0001_init.sql`.
enum ServiceCategory {
  grooming,
  veterinaryVisit,
  walking,
  boarding,
  homeVisit;

  static ServiceCategory fromDb(String value) {
    return ServiceCategory.values.firstWhere(
      (c) => c.dbValue == value,
      orElse: () => throw ArgumentError('Categoría desconocida: $value'),
    );
  }

  String get dbValue => switch (this) {
        ServiceCategory.grooming => 'grooming',
        ServiceCategory.veterinaryVisit => 'veterinary_visit',
        ServiceCategory.walking => 'walking',
        ServiceCategory.boarding => 'boarding',
        ServiceCategory.homeVisit => 'home_visit',
      };

  String get label => switch (this) {
        ServiceCategory.grooming => 'Peluquería',
        ServiceCategory.veterinaryVisit => 'Visita Veterinaria',
        ServiceCategory.walking => 'Paseo',
        ServiceCategory.boarding => 'Alojamiento',
        ServiceCategory.homeVisit => 'Visita a Domicilio',
      };

  /// Regla de negocio: todos los servicios excepto el paseo requieren
  /// verificación previa del registro de vacunación de la mascota.
  bool get requiresVaccinationVerification => this != ServiceCategory.walking;
}
