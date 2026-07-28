import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Acceso centralizado a las variables de entorno cargadas desde `.env`.
///
/// Ver `.env.example` para la lista de variables requeridas. El archivo
/// `.env` real (con credenciales) nunca debe subirse al control de versiones.
class Env {
  Env._();

  static String get supabaseUrl => _require('SUPABASE_URL');
  static String get supabaseAnonKey => _require('SUPABASE_ANON_KEY');

  /// Esquema de redirección para el flujo de OAuth (Google/Apple).
  static String get authRedirect =>
      dotenv.env['SUPABASE_AUTH_REDIRECT'] ??
      'io.supabase.petcarehomeservices://login-callback';

  static String _require(String key) {
    final value = dotenv.env[key];
    if (value == null || value.trim().isEmpty || value.startsWith('TU-')) {
      throw StateError(
        'Falta configurar "$key" en el archivo .env. '
        'Copia .env.example a .env y completa tus credenciales de Supabase.',
      );
    }
    return value;
  }
}
