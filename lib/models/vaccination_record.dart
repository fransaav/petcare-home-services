/// Registro de vacunación asociado a una mascota.
class VaccinationRecord {
  final String id;
  final String petId;
  final String documentUrl;
  final DateTime uploadedAt;
  final bool verified;

  const VaccinationRecord({
    required this.id,
    required this.petId,
    required this.documentUrl,
    required this.uploadedAt,
    required this.verified,
  });

  factory VaccinationRecord.fromMap(Map<String, dynamic> map) {
    return VaccinationRecord(
      id: map['id'] as String,
      petId: map['pet_id'] as String,
      documentUrl: map['document_url'] as String,
      uploadedAt: DateTime.parse(map['uploaded_at'] as String),
      verified: map['verified'] as bool,
    );
  }
}
