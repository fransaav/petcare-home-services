/// Alcance de aplicación de una promoción.
enum PromotionScope {
  national,
  local;

  static PromotionScope fromDb(String value) => switch (value) {
        'national' => PromotionScope.national,
        'local' => PromotionScope.local,
        _ => throw ArgumentError('Alcance de promoción desconocido: $value'),
      };
}

/// Promoción aplicable a una reserva.
class Promotion {
  final String id;
  final String name;
  final PromotionScope scope;
  final String? branchId;
  final String? providerId;
  final double discountPercentage;
  final DateTime validFrom;
  final DateTime validUntil;
  final bool active;

  const Promotion({
    required this.id,
    required this.name,
    required this.scope,
    this.branchId,
    this.providerId,
    required this.discountPercentage,
    required this.validFrom,
    required this.validUntil,
    required this.active,
  });

  bool isValidOn(DateTime date) =>
      active && !date.isBefore(validFrom) && !date.isAfter(validUntil);

  double applyTo(double amount) => amount - (amount * discountPercentage / 100);

  factory Promotion.fromMap(Map<String, dynamic> map) {
    return Promotion(
      id: map['id'] as String,
      name: map['name'] as String,
      scope: PromotionScope.fromDb(map['scope'] as String),
      branchId: map['branch_id'] as String?,
      providerId: map['provider_id'] as String?,
      discountPercentage: (map['discount_percentage'] as num).toDouble(),
      validFrom: DateTime.parse(map['valid_from'] as String),
      validUntil: DateTime.parse(map['valid_until'] as String),
      active: (map['active'] as bool?) ?? true,
    );
  }
}
