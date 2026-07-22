import 'package:flutter/material.dart';
import '../models/service.dart';

class BookingScreen extends StatefulWidget {
  final Service? service;

  const BookingScreen({super.key, this.service});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  String _serviceType = 'pickup';
  String? _selectedPet;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  static const List<String> _pets = [
    'Max — Labrador Retriever',
    'Luna — Siamés',
    'Coco — Poodle',
  ];

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

  void _confirmPayment(String method) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.check_circle_outline, color: Colors.green, size: 48),
        title: const Text('¡Reserva Registrada!'),
        content: Text(
          'Servicio: ${widget.service?.name ?? "Servicio"}\n'
          'Método de pago: $method\n\n'
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
            InputDecorator(
              decoration: InputDecoration(
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.pets),
                filled: true,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedPet,
                  hint: const Text('Elige tu mascota'),
                  isExpanded: true,
                  isDense: true,
                  items: _pets
                      .map((p) =>
                          DropdownMenuItem(value: p, child: Text(p)))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedPet = v),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ── Tipo de servicio ─────────────────────────────────────────────
            _SectionLabel('Tipo de Servicio'),
            const SizedBox(height: 8),
            SegmentedButton<String>(
              selected: {_serviceType},
              onSelectionChanged: (s) =>
                  setState(() => _serviceType = s.first),
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

            // ── Mapa placeholder (solo domicilio) ────────────────────────────
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: isHomeVisit
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 24),
                        _SectionLabel('Ubicación del Domicilio'),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          height: 200,
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                                color: colorScheme.outline, width: 1),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Cuadrícula que simula un mapa
                              CustomPaint(
                                size: const Size.fromHeight(200),
                                painter: _MapGridPainter(
                                    color: colorScheme.outlineVariant),
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.map_outlined,
                                      size: 52, color: colorScheme.primary),
                                  const SizedBox(height: 8),
                                  Text('Mapa de Ubicación',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: colorScheme.onSurface)),
                                  Text(
                                    'Integración con Google Maps\n(próximamente con Supabase)',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: colorScheme.onSurfaceVariant),
                                  ),
                                ],
                              ),
                              Positioned(
                                bottom: 12,
                                right: 12,
                                child: FilledButton.icon(
                                  onPressed: () {},
                                  icon: const Icon(Icons.my_location, size: 16),
                                  label: const Text('Mi ubicación'),
                                  style: FilledButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 8),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  : const SizedBox.shrink(),
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
              onPressed: () => _confirmPayment('Pago en línea'),
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
              onPressed: () => _confirmPayment('Pago en ubicación'),
              icon: const Icon(Icons.payments_outlined),
              label: const Text('Pagar en la Ubicación'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),

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

class _MapGridPainter extends CustomPainter {
  final Color color;
  const _MapGridPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 0.8;
    const spacing = 22.0;
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
