import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/booking.dart';
import '../models/booking_details.dart';
import '../providers/data_providers.dart';
import '../widgets/appointment_card.dart';

class ProviderDashboardScreen extends ConsumerWidget {
  const ProviderDashboardScreen({super.key});

  Future<void> _updateStatus(
    BuildContext context,
    WidgetRef ref,
    BookingDetails details,
    BookingStatus status,
  ) async {
    try {
      await ref
          .read(bookingsRepositoryProvider)
          .updateStatus(details.booking.id, status);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Estado actualizado: ${status.label}')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No se pudo actualizar el estado: $e')),
        );
      }
    }
  }

  void _showUpdateStatus(
      BuildContext context, WidgetRef ref, BookingDetails details) {
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
              '${details.petName} — ${details.serviceName}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            ...BookingStatus.values
                .where((s) => s != BookingStatus.rejected)
                .map((status) => ListTile(
                      leading: Icon(_statusIcon(status),
                          color: _statusColor(status)),
                      title: Text(status.label),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      onTap: () {
                        Navigator.of(ctx).pop();
                        _updateStatus(context, ref, details, status);
                      },
                    )),
          ],
        ),
      ),
    );
  }

  void _showRejectDialog(
      BuildContext context, WidgetRef ref, BookingDetails details) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.warning_amber_rounded,
            color: Colors.orange, size: 48),
        title: const Text('Rechazar Reserva'),
        content: Text(
          '¿Rechazar la reserva de ${details.clientName} para '
          '${details.petName}?\n\n'
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
              Navigator.of(ctx).pop();
              _updateStatus(context, ref, details, BookingStatus.rejected);
            },
            child: const Text('Rechazar'),
          ),
        ],
      ),
    );
  }

  IconData _statusIcon(BookingStatus s) => switch (s) {
        BookingStatus.pending => Icons.hourglass_empty,
        BookingStatus.confirmed => Icons.check_circle_outline,
        BookingStatus.inProgress => Icons.play_circle_outline,
        BookingStatus.completed => Icons.task_alt,
        BookingStatus.rejected => Icons.cancel_outlined,
        BookingStatus.cancelled => Icons.block,
      };

  Color _statusColor(BookingStatus s) => switch (s) {
        BookingStatus.pending => Colors.orange,
        BookingStatus.confirmed => Colors.blue,
        BookingStatus.inProgress => Colors.purple,
        BookingStatus.completed => Colors.green,
        BookingStatus.rejected => Colors.red,
        BookingStatus.cancelled => Colors.grey,
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final providerAsync = ref.watch(currentProviderProfileProvider);
    return Scaffold(
      body: providerAsync.when(
        data: (provider) {
          if (provider == null) {
            return CustomScrollView(
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
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(
                      child: Text(
                        'Tu perfil no está vinculado a ningún proveedor todavía. '
                        'Pide a un administrador que vincule tu cuenta en la tabla "providers".',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ],
            );
          }
          return _DashboardBody(
            providerId: provider.id,
            onUpdateStatus: (details) =>
                _showUpdateStatus(context, ref, details),
            onReject: (details) => _showRejectDialog(context, ref, details),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) =>
            Center(child: Text('Error al cargar el proveedor: $error')),
      ),
    );
  }
}

class _DashboardBody extends ConsumerWidget {
  final String providerId;
  final void Function(BookingDetails) onUpdateStatus;
  final void Function(BookingDetails) onReject;

  const _DashboardBody({
    required this.providerId,
    required this.onUpdateStatus,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingsAsync = ref.watch(providerBookingsProvider(providerId));

    return bookingsAsync.when(
      data: (bookings) => CustomScrollView(
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
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            sliver: SliverToBoxAdapter(
              child: Row(
                children: [
                  _StatTile(
                    label: 'Pendientes',
                    count: _count(bookings, BookingStatus.pending),
                    color: Colors.orange,
                    icon: Icons.hourglass_empty,
                  ),
                  const SizedBox(width: 10),
                  _StatTile(
                    label: 'Confirmados',
                    count: _count(bookings, BookingStatus.confirmed),
                    color: Colors.blue,
                    icon: Icons.check_circle_outline,
                  ),
                  const SizedBox(width: 10),
                  _StatTile(
                    label: 'Completados',
                    count: _count(bookings, BookingStatus.completed),
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
                'Citas (${bookings.length})',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          bookings.isEmpty
              ? const SliverPadding(
                  padding: EdgeInsets.all(32),
                  sliver: SliverToBoxAdapter(
                    child: Center(child: Text('No tienes reservas todavía.')),
                  ),
                )
              : SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList.separated(
                    itemCount: bookings.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final details = bookings[index];
                      return AppointmentCard(
                        details: details,
                        onUpdateStatus: () => onUpdateStatus(details),
                        onReject: () => onReject(details),
                      );
                    },
                  ),
                ),
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) =>
          Center(child: Text('Error al cargar reservas: $error')),
    );
  }

  int _count(List<BookingDetails> bookings, BookingStatus s) =>
      bookings.where((b) => b.booking.status == s).length;
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
