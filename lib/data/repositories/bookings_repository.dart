import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/booking.dart';
import '../../models/booking_details.dart';

const _bookingDetailsSelect =
    '*, pets(name), services(name), profiles:owner_id(full_name)';

class BookingsRepository {
  final SupabaseClient _client;
  const BookingsRepository(this._client);

  Future<Booking> createBooking(Booking booking) async {
    final map = await _client
        .from('bookings')
        .insert(booking.toInsertMap())
        .select()
        .single();
    return Booking.fromMap(map);
  }

  Future<void> updateStatus(
    String bookingId,
    BookingStatus status, {
    String? rejectionReason,
  }) async {
    await _client.from('bookings').update({
      'status': status.dbValue,
      if (rejectionReason != null) 'rejection_reason': rejectionReason,
    }).eq('id', bookingId);
  }

  Future<List<BookingDetails>> _fetchByProvider(String providerId) async {
    final rows = await _client
        .from('bookings')
        .select(_bookingDetailsSelect)
        .eq('provider_id', providerId)
        .order('scheduled_at');
    return rows.map((row) => BookingDetails.fromMap(row)).toList();
  }

  /// Emite la lista de reservas de un proveedor y la vuelve a emitir cada
  /// vez que hay un cambio (insert/update/delete) en tiempo real.
  Stream<List<BookingDetails>> watchProviderBookings(String providerId) {
    final controller = StreamController<List<BookingDetails>>();
    RealtimeChannel? channel;

    Future<void> refresh() async {
      if (controller.isClosed) return;
      try {
        controller.add(await _fetchByProvider(providerId));
      } catch (e, st) {
        if (!controller.isClosed) controller.addError(e, st);
      }
    }

    controller.onListen = () {
      refresh();
      channel = _client
          .channel('bookings-provider-$providerId')
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'bookings',
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'provider_id',
              value: providerId,
            ),
            callback: (_) => refresh(),
          )
          .subscribe();
    };
    controller.onCancel = () async {
      if (channel != null) {
        await _client.removeChannel(channel!);
      }
      await controller.close();
    };

    return controller.stream;
  }

  Future<List<BookingDetails>> getOwnerBookings(String ownerId) async {
    final rows = await _client
        .from('bookings')
        .select(_bookingDetailsSelect)
        .eq('owner_id', ownerId)
        .order('scheduled_at', ascending: false);
    return rows.map((row) => BookingDetails.fromMap(row)).toList();
  }
}
