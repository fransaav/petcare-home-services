/// Rol de un usuario dentro de la plataforma.
enum UserRole {
  owner,
  provider;

  static UserRole fromDb(String value) => switch (value) {
        'owner' => UserRole.owner,
        'provider' => UserRole.provider,
        _ => throw ArgumentError('Rol desconocido: $value'),
      };

  String get dbValue => switch (this) {
        UserRole.owner => 'owner',
        UserRole.provider => 'provider',
      };
}

/// Perfil de usuario (dueño de mascota o proveedor), 1:1 con `auth.users`.
class Profile {
  final String id;
  final UserRole role;
  final String fullName;
  final String email;
  final String? phone;
  final String? avatarUrl;

  const Profile({
    required this.id,
    required this.role,
    required this.fullName,
    required this.email,
    this.phone,
    this.avatarUrl,
  });

  factory Profile.fromMap(Map<String, dynamic> map) {
    return Profile(
      id: map['id'] as String,
      role: UserRole.fromDb(map['role'] as String),
      fullName: (map['full_name'] as String?) ?? '',
      email: map['email'] as String,
      phone: map['phone'] as String?,
      avatarUrl: map['avatar_url'] as String?,
    );
  }

  Map<String, dynamic> toUpdateMap() => {
        'full_name': fullName,
        'phone': phone,
        'avatar_url': avatarUrl,
      };

  Profile copyWith({
    String? fullName,
    String? phone,
    String? avatarUrl,
    UserRole? role,
  }) {
    return Profile(
      id: id,
      role: role ?? this.role,
      fullName: fullName ?? this.fullName,
      email: email,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }
}
