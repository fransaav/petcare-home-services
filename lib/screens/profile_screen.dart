import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/data_providers.dart';
import '../providers/supabase_providers.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  Future<void> _signOut(BuildContext context, WidgetRef ref) async {
    await ref.read(supabaseClientProvider).auth.signOut();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final profileAsync = ref.watch(currentProfileProvider);
    final profile = profileAsync.valueOrNull;
    final initial = profile != null && profile.fullName.isNotEmpty
        ? profile.fullName[0]
        : 'U';

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const SliverAppBar.large(title: Text('Mi Perfil')),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverToBoxAdapter(
              child: Column(
                children: [
                  // ── Avatar ─────────────────────────────────────────────────
                  CircleAvatar(
                    radius: 52,
                    backgroundColor: colorScheme.primaryContainer,
                    backgroundImage: profile?.avatarUrl != null
                        ? NetworkImage(profile!.avatarUrl!)
                        : null,
                    child: profile?.avatarUrl == null
                        ? Text(
                            initial.toUpperCase(),
                            style: TextStyle(
                              fontSize: 44,
                              color: colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    profile?.fullName.isNotEmpty == true
                        ? profile!.fullName
                        : 'Usuario',
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    profile?.email ?? '',
                    style: TextStyle(color: colorScheme.onSurfaceVariant),
                  ),
                  if (profile != null) ...[
                    const SizedBox(height: 4),
                    Chip(
                      label: Text(
                        profile.role.dbValue == 'provider'
                            ? 'Proveedor'
                            : 'Dueño de mascota',
                      ),
                    ),
                  ],
                  const SizedBox(height: 32),

                  // ── Opciones de perfil ─────────────────────────────────────
                  _ProfileTile(
                    icon: Icons.person_outline,
                    title: 'Editar Perfil',
                    onTap: () {},
                  ),
                  _ProfileTile(
                    icon: Icons.location_on_outlined,
                    title: 'Mis Direcciones',
                    onTap: () {},
                  ),
                  _ProfileTile(
                    icon: Icons.history,
                    title: 'Historial de Reservas',
                    onTap: () {},
                  ),
                  _ProfileTile(
                    icon: Icons.payment_outlined,
                    title: 'Métodos de Pago',
                    onTap: () {},
                  ),
                  _ProfileTile(
                    icon: Icons.notifications_outlined,
                    title: 'Notificaciones',
                    onTap: () {},
                  ),
                  _ProfileTile(
                    icon: Icons.help_outline,
                    title: 'Ayuda y Soporte',
                    onTap: () {},
                  ),

                  const SizedBox(height: 16),

                  // ── Cerrar sesión ──────────────────────────────────────────
                  OutlinedButton.icon(
                    onPressed: () => _signOut(context, ref),
                    icon: const Icon(Icons.logout, color: Colors.red),
                    label: const Text(
                      'Cerrar Sesión',
                      style: TextStyle(color: Colors.red),
                    ),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 52),
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _ProfileTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        trailing: const Icon(Icons.chevron_right),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        onTap: onTap,
      ),
    );
  }
}
