/// Registro de vacunación (Value Object) asociado a una mascota.
class VaccinationRecord {
  final String documentReference;
  final DateTime uploadedAt;
  final bool verified;

  VaccinationRecord({
    required this.documentReference,
    required this.uploadedAt,
    this.verified = false,
  }) {
    if (documentReference.trim().isEmpty) {
      throw ArgumentError(
        'La referencia del documento de vacunación no puede estar vacía.',
      );
    }
  }

  VaccinationRecord asVerified() => VaccinationRecord(
        documentReference: documentReference,
        uploadedAt: uploadedAt,
        verified: true,
      );
}

/// Entidad de dominio: Mascota.
///
/// Invariante: toda mascota debe estar asociada obligatoriamente a un dueño.
class Pet {
  final String id;
  final String ownerId;
  final String name;
  final String species;
  final String breed;
  final int age;

  bool _requiresSpecialHandling;
  String? _specialHandlingNotes;
  final List<VaccinationRecord> _vaccinationRecords = [];

  Pet({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.species,
    required this.breed,
    required this.age,
    bool requiresSpecialHandling = false,
    String? specialHandlingNotes,
  })  : _requiresSpecialHandling = requiresSpecialHandling,
        _specialHandlingNotes = specialHandlingNotes {
    if (id.trim().isEmpty) {
      throw ArgumentError('El id de la mascota no puede estar vacío.');
    }
    if (ownerId.trim().isEmpty) {
      throw ArgumentError('Toda mascota debe estar asociada a un dueño.');
    }
    if (name.trim().isEmpty) {
      throw ArgumentError('El nombre de la mascota no puede estar vacío.');
    }
    if (species.trim().isEmpty) {
      throw ArgumentError('La especie de la mascota no puede estar vacía.');
    }
    if (age < 0) {
      throw ArgumentError('La edad de la mascota no puede ser negativa.');
    }
    if (requiresSpecialHandling &&
        (specialHandlingNotes == null || specialHandlingNotes.trim().isEmpty)) {
      throw ArgumentError(
        'Se requieren notas de manejo especial cuando la mascota lo necesita.',
      );
    }
  }

  bool get requiresSpecialHandling => _requiresSpecialHandling;
  String? get specialHandlingNotes => _specialHandlingNotes;
  List<VaccinationRecord> get vaccinationRecords =>
      List.unmodifiable(_vaccinationRecords);
  bool get hasVerifiedVaccination =>
      _vaccinationRecords.any((record) => record.verified);

  /// Sube un nuevo registro de vacunación (sin verificar) para la mascota.
  void uploadVaccinationRecord(String documentReference,
      {DateTime? uploadedAt}) {
    _vaccinationRecords.add(
      VaccinationRecord(
        documentReference: documentReference,
        uploadedAt: uploadedAt ?? DateTime.now(),
      ),
    );
  }

  /// Verifica el registro de vacunación más reciente.
  void verifyVaccine() {
    if (_vaccinationRecords.isEmpty) {
      throw ArgumentError(
        'No se puede verificar: la mascota no tiene registros de vacunación cargados.',
      );
    }
    final latest = _vaccinationRecords.removeLast();
    _vaccinationRecords.add(latest.asVerified());
  }

  /// Marca a la mascota como de manejo especial con las notas indicadas.
  void markSpecialHandling(String notes) {
    if (notes.trim().isEmpty) {
      throw ArgumentError(
          'Las notas de manejo especial no pueden estar vacías.');
    }
    _requiresSpecialHandling = true;
    _specialHandlingNotes = notes;
  }

  /// Retira la condición de manejo especial de la mascota.
  void clearSpecialHandling() {
    _requiresSpecialHandling = false;
    _specialHandlingNotes = null;
  }
}
