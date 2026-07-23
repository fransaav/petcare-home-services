import 'provider.dart';

/// Alcance de aplicación de una promoción.
enum PromotionScope { national, local }

/// Entidad de dominio: Promoción.
///
/// Invariante: las promociones locales requieren una sucursal o proveedor
/// asociado; las nacionales no pueden restringirse a ninguno. El descuento
/// debe ser un porcentaje válido y el rango de vigencia debe ser coherente.
class Promotion {
  final String id;
  final String name;
  final PromotionScope scope;
  final String? branchId;
  final String? providerId;
  final double discountPercentage;
  final DateTime validFrom;
  final DateTime validUntil;

  bool _active = true;

  Promotion({
    required this.id,
    required this.name,
    required this.scope,
    this.branchId,
    this.providerId,
    required this.discountPercentage,
    required this.validFrom,
    required this.validUntil,
  }) {
    if (id.trim().isEmpty) {
      throw ArgumentError('El id de la promoción no puede estar vacío.');
    }
    if (name.trim().isEmpty) {
      throw ArgumentError('El nombre de la promoción no puede estar vacío.');
    }
    if (discountPercentage <= 0 || discountPercentage > 100) {
      throw ArgumentError('El descuento debe ser un porcentaje entre 0 y 100.');
    }
    if (!validUntil.isAfter(validFrom)) {
      throw ArgumentError('La fecha de fin debe ser posterior a la de inicio.');
    }
    final hasLocalTarget = (branchId != null && branchId!.trim().isNotEmpty) ||
        (providerId != null && providerId!.trim().isNotEmpty);
    if (scope == PromotionScope.local && !hasLocalTarget) {
      throw ArgumentError(
        'Una promoción local debe especificar una sucursal o un proveedor.',
      );
    }
    if (scope == PromotionScope.national && hasLocalTarget) {
      throw ArgumentError(
        'Una promoción nacional no puede restringirse a una sucursal o proveedor.',
      );
    }
  }

  bool get isActive => _active;

  bool isValidOn(DateTime date) {
    return _active && !date.isBefore(validFrom) && !date.isAfter(validUntil);
  }

  /// Determina si la promoción es aplicable al proveedor indicado, según
  /// su alcance nacional o local (por sucursal o por proveedor puntual).
  bool appliesToProvider(Provider provider) {
    if (!_active) return false;
    if (scope == PromotionScope.national) return true;
    if (providerId != null && providerId == provider.id) return true;
    if (branchId != null && branchId == provider.branchId) return true;
    return false;
  }

  double applyTo(double amount) {
    if (amount < 0) {
      throw ArgumentError('El monto no puede ser negativo.');
    }
    return amount - (amount * discountPercentage / 100);
  }

  void deactivate() => _active = false;
}
