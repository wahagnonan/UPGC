import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/widgets/platform_widgets.dart';
import '../providers/settings_provider.dart';

class ParametresScreen extends StatefulWidget {
  const ParametresScreen({super.key});

  @override
  State<ParametresScreen> createState() => _ParametresScreenState();
}

class _ParametresScreenState extends State<ParametresScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SettingsProvider>().chargerConfig();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Paramètres'),
        centerTitle: true,
        backgroundColor: colorScheme.surface,
      ),
      body: Consumer<SettingsProvider>(
        builder: (context, settings, child) {
          if (settings.estChargement) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildFilterSection(settings, colorScheme),
              const SizedBox(height: 24),
              _buildDisplaySection(settings, colorScheme),
              const SizedBox(height: 24),
              _buildAboutSection(colorScheme),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilterSection(
    SettingsProvider settings,
    ColorScheme colorScheme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Filtres',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: colorScheme.primary,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              _buildDropdownTile(
                icon: Icons.school_outlined,
                title: 'Domaine',
                value: settings.areaId,
                items: settings.areas,
                onChanged: (value) {
                  if (value != null) {
                    final area = settings.areas.firstWhere(
                      (a) => a.id == value,
                      orElse: () => settings.areas.first,
                    );
                    settings.setDepartement(value, area.nom);
                  }
                },
                colorScheme: colorScheme,
              ),
              Divider(
                height: 1,
                color: colorScheme.outline.withValues(alpha: 0.1),
              ),
              _buildDropdownTile(
                icon: Icons.meeting_room_outlined,
                title: 'Ressource',
                value: settings.roomId == 0 ? null : settings.roomId,
                items: settings.rooms,
                onChanged: (value) {
                  if (value != null) {
                    final room = settings.rooms.firstWhere(
                      (r) => r.id == value,
                      orElse: () => settings.rooms.first,
                    );
                    settings.setRessource(value, room.nom);
                  }
                },
                colorScheme: colorScheme,
              ),
              const SizedBox(height: 16),
              Center(
                child: TextButton.icon(
                  onPressed: () async {
                    await settings.reinitialiserParametres();
                    if (context.mounted) {
                      PlatformWidgets.showSnackBar(
                        context,
                        'Paramètres réinitialisés',
                      );
                    }
                  },
                  icon: Icon(Icons.refresh, color: colorScheme.error),
                  label: Text(
                    'Réinitialiser',
                    style: TextStyle(color: colorScheme.error),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownTile({
    required IconData icon,
    required String title,
    required int? value,
    required List items,
    required Function(int?) onChanged,
    required ColorScheme colorScheme,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: colorScheme.onSurfaceVariant),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                DropdownButton<int>(
                  value: value,
                  isExpanded: true,
                  underline: const SizedBox(),
                  icon: Icon(
                    Icons.keyboard_arrow_down,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  items: items.map<DropdownMenuItem<int>>((item) {
                    return DropdownMenuItem<int>(
                      value: item.id,
                      child: Text(
                        item.nom,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: onChanged,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDisplaySection(
    SettingsProvider settings,
    ColorScheme colorScheme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Affichage',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: colorScheme.primary,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  Icons.view_agenda_outlined,
                  color: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Mode liste',
                    style: TextStyle(color: colorScheme.onSurface),
                  ),
                ),
                PlatformWidgets.adaptiveSwitch(
                  value: settings.modeAffichage == ModeAffichage.liste,
                  onChanged: (value) {
                    settings.setModeAffichage(
                      value ? ModeAffichage.liste : ModeAffichage.tableau,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAboutSection(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'À propos',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: colorScheme.primary,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              ListTile(
                leading: Icon(
                  Icons.school_outlined,
                  color: colorScheme.onSurfaceVariant,
                ),
                title: const Text('UPGC'),
                subtitle: const Text('Université Peleforo Gon Coulibaly'),
              ),
              Divider(
                height: 1,
                color: colorScheme.outline.withValues(alpha: 0.1),
              ),
              ListTile(
                leading: Icon(
                  Icons.info_outline,
                  color: colorScheme.onSurfaceVariant,
                ),
                title: const Text('Version'),
                trailing: Text(
                  '1.0.0',
                  style: TextStyle(color: colorScheme.onSurfaceVariant),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
