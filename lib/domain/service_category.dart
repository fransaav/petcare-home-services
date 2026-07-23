/// Categorías de servicio soportadas por la plataforma.
enum ServiceCategory { grooming, veterinaryVisit, walking, boarding, homeVisit }

extension ServiceCategoryRules on ServiceCategory {
  /// Regla de negocio: todos los servicios excepto el paseo requieren
  /// verificación previa del registro de vacunación de la mascota.
  bool get requiresVaccinationVerification => this != ServiceCategory.walking;
}
