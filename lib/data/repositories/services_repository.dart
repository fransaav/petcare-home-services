import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/service.dart';

class ServicesRepository {
  final SupabaseClient _client;
  const ServicesRepository(this._client);

  Future<List<Service>> getActiveServices() async {
    final rows = await _client
        .from('services')
        .select()
        .eq('active', true)
        .order('name');
    return rows.map((row) => Service.fromMap(row)).toList();
  }
}
