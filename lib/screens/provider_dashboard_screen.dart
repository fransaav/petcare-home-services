import 'package:flutter/material.dart';
import '../models/booking.dart';
import '../widgets/appointment_card.dart';

class ProviderDashboardScreen extends StatefulWidget {
  const ProviderDashboardScreen({super.key});

  @override
  State<ProviderDashboardScreen> createState() =>
      _ProviderDashboardScreenState();
}

class _ProviderDashboardScreenState extends State<ProviderDashboardScreen> {
  late List<Booking> _bookings;

  @override
  void initState() {
    super.initState();
    _bookings = List.from(dummyBookings);
  }

  // ── Actualizar estado ──────────────────────────────────────────────────────
  void _showUpdateStatus(Booking booking) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Actualizar Estado',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            Text(
              '${booking.petName} — ${booking.serviceName}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            ...BookingStatus.values.map((status) => ListTile(
                  leading: Icon(
                    _statusIcon(status),
                    color: _statusColor(status),
                  ),
                  title: Text(_statusLabel(status)),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  onTap: () {
                    _updateBooking(booking, status);
                    Navigator.of(ctx).pop();
                  },
                )),
          ],
        ),
      ),
    );
  }

  // ── Rechazar reserva ───────────────────────────────────────────────────────
  void _showRejectDialog(Booking booking) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.warning_amber_rounded,
            color: Colors.orange, size: 48),
        title: const Text('Rechazar Reserva'),
        content: Text(
          '¿Rechazar la reserva de ${booking.clientName} para '
          '${booking.petName}?\n\n'
          'Motivo habitual: requisitos de vacunación no cumplidos.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              _updateBooking(booking, BookingStatus.rejected);
              Navigator.of(ctx).pop();
            },
            child: const Text('Rechazar'),
          ),
        ],
      ),
    );
  }

  void _updateBooking(Booking booking, BookingStatus status) {
    setState(() {
      final idx = _bookings.indexWhere((b) => b.id == booking.id);
      if (idx != -1) _bookings[idx] = booking.copyWith(status: status);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Estado actualizado: ${_statusLabel(status)}')),
    );
  }

  // ── Helpers de estado ──────────────────────────────────────────────────────
  String _statusLabel(BookingStatus s) => switch (s) {
        BookingStatus.pending => 'Pendiente',
        BookingStatus.confirmed => 'Confirmado',
        BookingStatus.inProgress => 'En Progreso',
        BookingStatus.completed => 'Completado',
        BookingStatus.rejected => 'Rechazado',
      };

  IconData _statusIcon(BookingStatus s) => switch (s) {
        BookingStatus.pending => Icons.hourglass_empty,
        BookingStatus.confirmed => Icons.check_circle_outline,
        BookingStatus.inProgress => Icons.play_circle_outline,
        BookingStatus.completed => Icons.task_alt,
        BookingStatus.rejected => Icons.cancel_outlined,
      };

  Color _statusColor(BookingStatus s) => switch (s) {
        BookingStatus.pending => Colors.orange,
        BookingStatus.confirmed => Colors.blue,
        BookingStatus.inProgress => Colors.purple,
        BookingStatus.completed => Colors.green,
        BookingStatus.rejected => Colors.red,
      };

  // ── Contadores para las stats ──────────────────────────────────────────────
  int _count(BookingStatus s) =>
      _bookings.where((b) => b.status == s).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: const Text('Dashboard Proveedor'),
            leading: Navigator.canPop(context)
                ? IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.of(context).pop(),
                  )
                : null,
          ),

          // ── Tarjetas de estadísticas ──────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            sliver: SliverToBoxAdapter(
              child: Row(
                children: [
                  _StatTile(
                    label: 'Pendientes',
                    count: _count(BookingStatus.pending),
                    color: Colors.orange,
                    icon: Icons.hourglass_empty,
                  ),
                  const SizedBox(width: 10),
                  _StatTile(
                    label: 'Confirmados',
                    count: _count(BookingStatus.confirmed),
                    color: Colors.blue,
                    icon: Icons.check_circle_outline,
                  ),
                  const SizedBox(width: 10),
                  _StatTile(
                    label: 'Completados',
                    count: _count(BookingStatus.completed),
                    color: Colors.green,
                    icon: Icons.task_alt,
                  ),
                ],
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
            sliver: SliverToBoxAdapter(
              child: Text(
                'Citas del Día (${_bookings.length})',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
          ),

          // ── Lista de citas ────────────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList.separated(
              itemCount: _bookings.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final booking = _bookings[index];
                return AppointmentCard(
                  booking: booking,
                  onUpdateStatus: () => _showUpdateStatus(booking),
                  onReject: () => _showRejectDialog(booking),
                );
              },
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }
}

// ── Widget auxiliar: tarjeta de estadística ───────────────────────────────────
class _StatTile extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  final IconData icon;

  const _StatTile({
    required this.label,
    required this.count,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          child: Column(
            children: [
              Icon(icon, color: color, size: 26),
              const SizedBox(height: 4),
              Text(
                '$count',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
              ),
              Text(
                label,
                style: Theme.of(context).textTheme.labelSmall,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
