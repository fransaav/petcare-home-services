import 'vaccination_record.dart';

/// Mascota registrada por un dueño (owner) de la plataforma.
class Pet {
  final String id;
  final String ownerId;
  final String name;
  final String species;
  final String breed;
  final int age;
  final String? photoUrl;
  final bool requiresSpecialHandling;
  final String? specialHandlingNotes;
  final List<VaccinationRecord> vaccinationRecords;

  const Pet({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.species,
    required this.breed,
    required this.age,
    this.photoUrl,
    this.requiresSpecialHandling = false,
    this.specialHandlingNotes,
    this.vaccinationRecords = const [],
  });

  bool get hasVerifiedVaccination => vaccinationRecords.any((r) => r.verified);

  /// Emoji de respaldo cuando la mascota no tiene foto real cargada.
  String get fallbackEmoji => switch (species.toLowerCase()) {
        'perro' => '🐕',
        'gato' => '🐈',
        _ => '🐾',
      };

  factory Pet.fromMap(
    Map<String, dynamic> map, {
    List<VaccinationRecord> vaccinationRecords = const [],
  }) {
    return Pet(
      id: map['id'] as String,
      ownerId: map['owner_id'] as String,
      name: map['name'] as String,
      species: map['species'] as String,
      breed: (map['breed'] as String?) ?? '',
      age: (map['age'] as num?)?.toInt() ?? 0,
      photoUrl: map['photo_url'] as String?,
      requiresSpecialHandling:
          (map['requires_special_handling'] as bool?) ?? false,
      specialHandlingNotes: map['special_handling_notes'] as String?,
      vaccinationRecords: vaccinationRecords,
    );
  }

  Map<String, dynamic> toInsertMap() => {
        'owner_id': ownerId,
        'name': name,
        'species': species,
        'breed': breed,
        'age': age,
        'photo_url': photoUrl,
        'requires_special_handling': requiresSpecialHandling,
        'special_handling_notes': specialHandlingNotes,
      };
}
