import 'package:flutter/material.dart';
import '../models/pet.dart';

class PetCard extends StatelessWidget {
  final Pet pet;

  const PetCard({super.key, required this.pet});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final vaccineOk = pet.hasVaccinationRecord;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Fila principal ───────────────────────────────────────────────
            Row(
              children: [
                // Avatar de mascota
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(pet.imageEmoji,
                        style: const TextStyle(fontSize: 40)),
                  ),
                ),
                const SizedBox(width: 16),

                // Datos de la mascota
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pet.name,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Text(
                        '${pet.species} • ${pet.breed}',
                        style: TextStyle(color: colorScheme.onSurfaceVariant),
                      ),
                      Text(
                        '${pet.age} ${pet.age == 1 ? 'año' : 'años'}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),

                // Chip de vacunación
                _VaccineBadge(vaccineOk: vaccineOk),
              ],
            ),

            const SizedBox(height: 14),
            const Divider(height: 1),
            const SizedBox(height: 14),

            // ── Botones de acción ────────────────────────────────────────────
            Row(
              children: [
                // Editar (secundario)
                OutlinedButton.icon(
                  onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text('Editando perfil de ${pet.name}')),
                  ),
                  icon: const Icon(Icons.edit_outlined, size: 16),
                  label: const Text('Editar'),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                const SizedBox(width: 10),

                // Subir registro de vacunación (primario, destacado)
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () =>
                        ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            'Subir registro de vacunación — ${pet.name}'),
                        action: SnackBarAction(
                          label: 'OK',
                          onPressed: () {},
                        ),
                      ),
                    ),
                    icon: const Icon(Icons.upload_file, size: 16),
                    label: const Text(
                      'Subir registro de vacunación',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    style: FilledButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Badge de estado de vacunación ─────────────────────────────────────────────
class _VaccineBadge extends StatelessWidget {
  final bool vaccineOk;
  const _VaccineBadge({required this.vaccineOk});

  @override
  Widget build(BuildContext context) {
    final color = vaccineOk ? Colors.green : Colors.orange;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withAlpha(80)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            vaccineOk ? Icons.verified : Icons.warning_amber,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            vaccineOk ? 'Al día' : 'Pendiente',
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
