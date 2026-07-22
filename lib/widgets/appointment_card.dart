import 'package:flutter/material.dart';
import '../models/booking.dart';

class AppointmentCard extends StatelessWidget {
  final Booking booking;
  final VoidCallback onUpdateStatus;
  final VoidCallback onReject;

  const AppointmentCard({
    super.key,
    required this.booking,
    required this.onUpdateStatus,
    required this.onReject,
  });

  // ── Helpers visuales ───────────────────────────────────────────────────────
  Color _statusColor(BookingStatus s) => switch (s) {
        BookingStatus.pending => Colors.orange,
        BookingStatus.confirmed => Colors.blue,
        BookingStatus.inProgress => Colors.purple,
        BookingStatus.completed => Colors.green,
        BookingStatus.rejected => Colors.red,
      };

  String _statusLabel(BookingStatus s) => switch (s) {
        BookingStatus.pending => 'Pendiente',
        BookingStatus.confirmed => 'Confirmado',
        BookingStatus.inProgress => 'En Progreso',
        BookingStatus.completed => 'Completado',
        BookingStatus.rejected => 'Rechazado',
      };

  String _typeLabel(ServiceType t) => switch (t) {
        ServiceType.pickup => 'Recogida/Entrega',
        ServiceType.homeVisit => 'Visita a Domicilio',
      };

  IconData _typeIcon(ServiceType t) => switch (t) {
        ServiceType.pickup => Icons.local_shipping_outlined,
        ServiceType.homeVisit => Icons.home_outlined,
      };

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final sc = _statusColor(booking.status);
    final actionable = booking.status != BookingStatus.rejected &&
        booking.status != BookingStatus.completed;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Cabecera: nombre + estado ─────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking.serviceName,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${booking.clientName} · ${booking.petName}',
                        style: TextStyle(
                            color: colorScheme.onSurfaceVariant,
                            fontSize: 13),
                      ),
                    ],
                  ),
                ),
                // Chip de estado
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: sc.withAlpha(30),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: sc.withAlpha(100)),
                  ),
                  child: Text(
                    _statusLabel(booking.status),
                    style: TextStyle(
                      color: sc,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),

            // ── Detalles: fecha, tipo, dirección ──────────────────────────
            _DetailRow(
              icon: Icons.access_time_outlined,
              text: '${booking.date} — ${booking.time}',
            ),
            const SizedBox(height: 4),
            _DetailRow(
              icon: _typeIcon(booking.serviceType),
              text: _typeLabel(booking.serviceType),
            ),
            const SizedBox(height: 4),
            _DetailRow(
              icon: Icons.location_on_outlined,
              text: booking.address,
              overflow: true,
            ),

            // ── Botones de acción (solo si no está cerrada) ───────────────
            if (actionable) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  // Rechazar reserva
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onReject,
                      icon: const Icon(Icons.cancel_outlined,
                          size: 16, color: Colors.red),
                      label: const Text(
                        'Rechazar Reserva',
                        style:
                            TextStyle(color: Colors.red, fontSize: 12),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red),
                        padding:
                            const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Actualizar estado
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: onUpdateStatus,
                      icon: const Icon(Icons.update, size: 16),
                      label: const Text(
                        'Actualizar Estado',
                        style: TextStyle(fontSize: 12),
                      ),
                      style: FilledButton.styleFrom(
                        padding:
                            const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Fila de detalle genérica ──────────────────────────────────────────────────
class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool overflow;

  const _DetailRow({
    required this.icon,
    required this.text,
    this.overflow = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(icon, size: 15, color: colorScheme.onSurfaceVariant),
        const SizedBox(width: 6),
        overflow
            ? Expanded(
                child: Text(
                  text,
                  style: Theme.of(context).textTheme.bodySmall,
                  overflow: TextOverflow.ellipsis,
                ),
              )
            : Text(text, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
