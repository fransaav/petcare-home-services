class Pet {
  final String id;
  final String name;
  final String species;
  final String breed;
  final int age;
  final String imageEmoji;
  final bool hasVaccinationRecord;

  const Pet({
    required this.id,
    required this.name,
    required this.species,
    required this.breed,
    required this.age,
    required this.imageEmoji,
    required this.hasVaccinationRecord,
  });
}

// ── Datos simulados (dummy data) ──────────────────────────────────────────────
const List<Pet> dummyPets = [
  Pet(
    id: '1',
    name: 'Max',
    species: 'Perro',
    breed: 'Labrador Retriever',
    age: 3,
    imageEmoji: '🐕',
    hasVaccinationRecord: true,
  ),
  Pet(
    id: '2',
    name: 'Luna',
    species: 'Gato',
    breed: 'Siamés',
    age: 2,
    imageEmoji: '🐈',
    hasVaccinationRecord: false,
  ),
  Pet(
    id: '3',
    name: 'Coco',
    species: 'Perro',
    breed: 'Poodle',
    age: 5,
    imageEmoji: '🐩',
    hasVaccinationRecord: true,
  ),
];
