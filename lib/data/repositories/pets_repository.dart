import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/pet.dart';
import '../../models/vaccination_record.dart';

class PetsRepository {
  final SupabaseClient _client;
  const PetsRepository(this._client);

  Future<List<Pet>> getPetsByOwner(String ownerId) async {
    final rows = await _client
        .from('pets')
        .select('*, vaccination_records(*)')
        .eq('owner_id', ownerId)
        .order('created_at');

    return rows.map((row) {
      final records = (row['vaccination_records'] as List<dynamic>? ?? [])
          .map((r) => VaccinationRecord.fromMap(r as Map<String, dynamic>))
          .toList();
      return Pet.fromMap(row, vaccinationRecords: records);
    }).toList();
  }

  Future<Pet> addPet(Pet pet) async {
    final map =
        await _client.from('pets').insert(pet.toInsertMap()).select().single();
    return Pet.fromMap(map);
  }

  Future<void> updatePet(String petId, Map<String, dynamic> changes) async {
    await _client.from('pets').update(changes).eq('id', petId);
  }

  /// Sube un documento de vacunación a Storage y registra la fila asociada.
  Future<VaccinationRecord> uploadVaccinationRecord({
    required String ownerId,
    required String petId,
    required String fileName,
    required Uint8List bytes,
  }) async {
    final path = '$ownerId/$petId/$fileName';
    await _client.storage.from('vaccination-docs').uploadBinary(
          path,
          bytes,
          fileOptions: const FileOptions(upsert: true),
        );
    final documentUrl =
        _client.storage.from('vaccination-docs').getPublicUrl(path);
    final map = await _client
        .from('vaccination_records')
        .insert({'pet_id': petId, 'document_url': documentUrl})
        .select()
        .single();
    return VaccinationRecord.fromMap(map);
  }
}
