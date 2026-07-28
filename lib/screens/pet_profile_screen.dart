import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/pet.dart';
import '../providers/auth_providers.dart';
import '../providers/data_providers.dart';
import '../widgets/pet_card.dart';

class PetProfileScreen extends ConsumerWidget {
  const PetProfileScreen({super.key});

  Future<void> _showAddPetDialog(BuildContext context, WidgetRef ref) async {
    final ownerId = ref.read(currentUserIdProvider);
    if (ownerId == null) return;

    final nameController = TextEditingController();
    final speciesController = TextEditingController();
    final breedController = TextEditingController();
    final ageController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Agregar Mascota'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Nombre'),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Requerido' : null,
                ),
                TextFormField(
                  controller: speciesController,
                  decoration: const InputDecoration(
                      labelText: 'Especie (Perro, Gato...)'),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Requerido' : null,
                ),
                TextFormField(
                  controller: breedController,
                  decoration: const InputDecoration(labelText: 'Raza'),
                ),
                TextFormField(
                  controller: ageController,
                  decoration: const InputDecoration(labelText: 'Edad (años)'),
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    final n = int.tryParse(v ?? '');
                    return (n == null || n < 0) ? 'Edad inválida' : null;
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              if (formKey.currentState!.validate()) Navigator.of(ctx).pop(true);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final pet = Pet(
      id: '',
      ownerId: ownerId,
      name: nameController.text.trim(),
      species: speciesController.text.trim(),
      breed: breedController.text.trim(),
      age: int.parse(ageController.text.trim()),
    );

    try {
      await ref.read(petsRepositoryProvider).addPet(pet);
      ref.invalidate(petsProvider);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No se pudo agregar la mascota: $e')),
        );
      }
    }
  }

  Future<void> _uploadVaccination(
      BuildContext context, WidgetRef ref, Pet pet) async {
    final ownerId = ref.read(currentUserIdProvider);
    if (ownerId == null) return;

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      withData: true,
    );
    final file = result?.files.single;
    if (file == null || file.bytes == null) return;

    try {
      await ref.read(petsRepositoryProvider).uploadVaccinationRecord(
            ownerId: ownerId,
            petId: pet.id,
            fileName: file.name,
            bytes: file.bytes!,
          );
      ref.invalidate(petsProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Registro de vacunación subido para ${pet.name}')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('No se pudo subir el archivo: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final petsAsync = ref.watch(petsProvider);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(petsProvider),
        child: CustomScrollView(
          slivers: [
            const SliverAppBar.large(title: Text('Mis Mascotas')),
            petsAsync.when(
              data: (pets) => pets.isEmpty
                  ? const SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                          child: Text('Aún no tienes mascotas registradas.')),
                    )
                  : SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      sliver: SliverList.separated(
                        itemCount: pets.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final pet = pets[index];
                          return PetCard(
                            pet: pet,
                            onUploadVaccination: () =>
                                _uploadVaccination(context, ref, pet),
                          );
                        },
                      ),
                    ),
              loading: () => const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (error, stackTrace) => SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: Text('Error al cargar mascotas: $error')),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddPetDialog(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Agregar Mascota'),
      ),
    );
  }
}
