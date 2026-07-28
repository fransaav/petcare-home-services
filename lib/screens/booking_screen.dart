import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/booking.dart';
import '../models/pet.dart';
import '../models/service.dart';
import '../models/service_provider.dart';
import '../providers/auth_providers.dart';
import '../providers/data_providers.dart';

class BookingScreen extends ConsumerStatefulWidget {
  final Service? service;

  const BookingScreen({super.key, this.service});

  @override
  ConsumerState<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends ConsumerState<BookingScreen> {
  String _serviceType = 'pickup';
  Pet? _selectedPet;
  ServiceProvider? _selectedProvider;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  final _addressController = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 9, minute: 0),
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  Future<void> _confirmBooking(PaymentMethod method) async {
    final service = widget.service;
    final ownerId = ref.read(currentUserIdProvider);

    if (service == null || ownerId == null) return;
    if (_selectedPet == null) {
      _showError('Selecciona una mascota.');
      return;
    }
    if (_selectedProvider == null) {
      _showError(
          'No hay proveedores disponibles para este servicio en este momento.');
      return;
    }
    if (_selectedDate == null || _selectedTime == null) {
      _showError('Selecciona la fecha y la hora del servicio.');
      return;
    }
    final isHomeVisit = _serviceType == 'home_visit';
    if (isHomeVisit && _addressController.text.trim().isEmpty) {
      _showError('Ingresa la dirección para la visita a domicilio.');
      return;
    }
    if (service.category.requiresVaccinationVerification &&
        !_selectedPet!.hasVerifiedVaccination) {
      _showError(
        'Este servicio requiere que la mascota tenga un registro de vacunación verificado.',
      );
      return;
    }

    final scheduledAt = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

    setState(() => _submitting = true);
    try {
      final booking = Booking(
        id: '',
        petId: _selectedPet!.id,
        ownerId: ownerId,
        providerId: _selectedProvider!.id,
        serviceId: service.id,
        category: service.category,
        deliveryMode:
            isHomeVisit ? DeliveryMode.homeVisit : DeliveryMode.pickupDropOff,
        paymentMethod: method,
        scheduledAt: scheduledAt,
        address: isHomeVisit ? _addressController.text.trim() : null,
        price: service.price,
        status: BookingStatus.pending,
      );
      await ref.read(bookingsRepositoryProvider).createBooking(booking);
      if (!mounted) return;
      _showConfirmationDialog(method);
    } catch (e) {
      _showError('No se pudo registrar la reserva: $e');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  void _showConfirmationDialog(PaymentMethod method) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.check_circle_outline,
            color: Colors.green, size: 48),
        title: const Text('¡Reserva Registrada!'),
        content: Text(
          'Servicio: ${widget.service?.name ?? "Servicio"}\n'
          'Método de pago: ${method == PaymentMethod.online ? "Pago en línea" : "Pago en ubicación"}\n\n'
          'Recibirás una confirmación próximamente.',
        ),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isHomeVisit = _serviceType == 'home_visit';
    final petsAsync = ref.watch(petsProvider);
    final providersAsync = widget.service != null
        ? ref.watch(availableProvidersProvider(widget.service!.category))
        : null;

    // Selecciona automáticamente el primer proveedor disponible.
    providersAsync?.whenData((providers) {
      if (_selectedProvider == null && providers.isNotEmpty) {
        _selectedProvider = providers.first;
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.service?.name ?? 'Reservar Servicio'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Banner del servicio ──────────────────────────────────────────
            if (widget.service != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Text(widget.service!.icon,
                        style: const TextStyle(fontSize: 44)),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.service!.name,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onPrimaryContainer,
                                ),
                          ),
                          Text(
                            widget.service!.description,
                            style: TextStyle(
                                color: colorScheme.onPrimaryContainer,
                                fontSize: 12),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '\$${widget.service!.price.toStringAsFixed(2)}',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.primary,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 24),

            // ── Selección de mascota ─────────────────────────────────────────
            _SectionLabel('Seleccionar Mascota'),
            const SizedBox(height: 8),
            petsAsync.when(
              data: (pets) => InputDecorator(
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.pets),
                  filled: true,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<Pet>(
                    value: pets.contains(_selectedPet) ? _selectedPet : null,
                    hint: Text(pets.isEmpty
                        ? 'No tienes mascotas registradas'
                        : 'Elige tu mascota'),
                    isExpanded: true,
                    isDense: true,
                    items: pets
                        .map((p) => DropdownMenuItem(
                              value: p,
                              child: Text('${p.name} — ${p.breed}'),
                            ))
                        .toList(),
                    onChanged: (v) => setState(() => _selectedPet = v),
                  ),
                ),
              ),
              loading: () => const LinearProgressIndicator(),
              error: (e, st) => Text('Error al cargar mascotas: $e'),
            ),

            const SizedBox(height: 24),

            // ── Tipo de servicio ─────────────────────────────────────────────
            _SectionLabel('Tipo de Servicio'),
            const SizedBox(height: 8),
            SegmentedButton<String>(
              selected: {_serviceType},
              onSelectionChanged: (s) => setState(() => _serviceType = s.first),
              style: SegmentedButton.styleFrom(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              segments: const [
                ButtonSegment(
                  value: 'pickup',
                  icon: Icon(Icons.local_shipping_outlined),
                  label: Text('Recogida / Entrega'),
                ),
                ButtonSegment(
                  value: 'home_visit',
                  icon: Icon(Icons.home_outlined),
                  label: Text('Visita a Domicilio'),
                ),
              ],
            ),

            // ── Dirección (solo domicilio) ───────────────────────────────────
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: isHomeVisit
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 24),
                        _SectionLabel('Dirección del Domicilio'),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _addressController,
                          decoration: InputDecoration(
                            hintText: 'Calle, número, ciudad',
                            prefixIcon: const Icon(Icons.location_on_outlined),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          height: 140,
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                                color: colorScheme.outline, width: 1),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.map_outlined,
                                  size: 40, color: colorScheme.primary),
                              const SizedBox(height: 4),
                              Text(
                                'Integración con mapas — próximamente',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: colorScheme.onSurfaceVariant),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  : const SizedBox.shrink(),
            ),

            const SizedBox(height: 24),

            // ── Proveedor asignado ───────────────────────────────────────────
            _SectionLabel('Proveedor Asignado'),
            const SizedBox(height: 8),
            if (providersAsync != null)
              providersAsync.when(
                data: (providers) => providers.isEmpty
                    ? const Text(
                        'No hay proveedores disponibles en este momento.')
                    : Text(_selectedProvider?.name ?? providers.first.name),
                loading: () => const LinearProgressIndicator(),
                error: (e, st) => Text('Error al cargar proveedores: $e'),
              ),

            const SizedBox(height: 24),

            // ── Fecha y hora ─────────────────────────────────────────────────
            _SectionLabel('Fecha y Hora'),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _selectDate,
                    icon: const Icon(Icons.calendar_today_outlined),
                    label: Text(
                      _selectedDate == null
                          ? 'Fecha'
                          : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _selectTime,
                    icon: const Icon(Icons.access_time_outlined),
                    label: Text(
                      _selectedTime == null
                          ? 'Hora'
                          : _selectedTime!.format(context),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // ── Botones de pago ──────────────────────────────────────────────
            _SectionLabel('Método de Pago'),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: _submitting
                  ? null
                  : () => _confirmBooking(PaymentMethod.online),
              icon: const Icon(Icons.credit_card),
              label: const Text('Pagar Ahora (En línea)'),
              style: FilledButton.styleFrom(
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _submitting
                  ? null
                  : () => _confirmBooking(PaymentMethod.atLocation),
              icon: const Icon(Icons.payments_outlined),
              label: const Text('Pagar en la Ubicación'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
            if (_submitting) ...[
              const SizedBox(height: 16),
              const Center(child: CircularProgressIndicator()),
            ],

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context)
          .textTheme
          .titleMedium
          ?.copyWith(fontWeight: FontWeight.bold),
    );
  }
}
