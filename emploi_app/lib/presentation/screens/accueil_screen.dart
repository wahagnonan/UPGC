import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../core/theme/app_theme.dart';
import '../providers/cours_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/cours_card.dart';

class AccueilScreen extends StatefulWidget {
  const AccueilScreen({super.key});

  @override
  State<AccueilScreen> createState() => _AccueilScreenState();
}

class _AccueilScreenState extends State<AccueilScreen>
    with WidgetsBindingObserver {
  int _dernierAreaId = 0;
  int _dernierRoomId = 0;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _chargerCours();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _chargerCours();
    }
  }

  void _chargerCours() {
    final provider = context.read<CoursProvider>();
    final settings = context.read<SettingsProvider>();

    // Attendre que les settings soient chargés
    if (!settings.settingsPret) {
      return;
    }

    final areaId = settings.areaId;
    final roomId = settings.roomId;

    // Si areaId = 2 (défaut), ne pas envoyer pour que le backend utilise AREAS_PAR_DEFAUT [2,16]
    // Sinon envoyer le area spécifique (ex: 20 = Informatique)
    int? apiArea = (areaId > 0 && areaId != 2) ? areaId : null;
    int? apiRoom = roomId > 0 ? roomId : null;

    final doitRecharger =
        _dernierAreaId != settings.areaId || _dernierRoomId != settings.roomId;

    if (doitRecharger || _dernierAreaId == 0) {
      _dernierAreaId = settings.areaId;
      _dernierRoomId = settings.roomId;
    }

    provider.chargerEmploiDuJour(
      date: _getDateFromOffset(settings.jourOffset),
      area: apiArea,
      room: apiRoom,
      semaine: settings.jourOffset == -999,
    );
  }

  String? _getDateFromOffset(int offset) {
    if (offset == -999) return null;
    final date = DateTime.now().add(Duration(days: offset));
    return '${date.day}/${date.month}/${date.year}';
  }

  void _onJourChanged(int offset) {
    final settings = context.read<SettingsProvider>();
    settings.setJourOffset(offset);
    _chargerCours();
  }

  void _showCalendarPopup(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    showModalBottomSheet(
      context: context,
      backgroundColor: colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) {
        return Consumer<SettingsProvider>(
          builder: (context, settings, _) {
            return Builder(
              builder: (builderContext) {
                return Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TableCalendar(
                        firstDay: DateTime.utc(2020, 1, 1),
                        lastDay: DateTime.utc(2030, 12, 31),
                        focusedDay: _focusedDay,
                        selectedDayPredicate: (day) =>
                            isSameDay(_selectedDay, day),
                        calendarFormat: _calendarFormat,
                        onDaySelected: (selectedDay, focusedDay) {
                          Navigator.pop(sheetContext);
                          _chargerCoursAvecDate(selectedDay);
                        },
                        calendarStyle: CalendarStyle(
                          selectedDecoration: BoxDecoration(
                            color: colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                          todayDecoration: BoxDecoration(
                            color: colorScheme.primary.withValues(alpha: 0.3),
                            shape: BoxShape.circle,
                          ),
                        ),
                        headerStyle: HeaderStyle(
                          formatButtonVisible: false,
                          titleCentered: true,
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  void _chargerCoursAvecDate(DateTime date) {
    final settings = context.read<SettingsProvider>();
    final provider = context.read<CoursProvider>();

    final dateStr =
        '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    final areaId = settings.areaId;
    final roomId = settings.roomId;

    int? apiArea;
    int? apiRoom;

    if (areaId == 2 || areaId == 16) {
      apiArea = areaId;
      apiRoom = roomId > 0 ? roomId : null;
    } else {
      apiArea = null;
      apiRoom = roomId > 0 ? roomId : null;
    }

    provider.chargerEmploiDuJour(
      date: dateStr,
      area: apiArea,
      room: apiRoom,
      semaine: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Consumer<SettingsProvider>(
          builder: (context, settings, child) {
            final filter = settings.roomId > 0
                ? settings.ressourceNom
                : (settings.areaId > 0
                      ? settings.departementDomaineNom
                      : 'Tous les domaines');
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Emploi du temps',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2),
                Text(
                  filter,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.normal,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: () => _showCalendarPopup(context),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildDateBar(context),
          Expanded(
            child: Consumer2<CoursProvider, SettingsProvider>(
              builder: (context, provider, settings, child) {
                if (provider.estChargement) {
                  return _buildLoadingState(colorScheme);
                }

                if (provider.erreur != null) {
                  return _buildErrorState(
                    context,
                    provider.erreur!,
                    colorScheme,
                  );
                }

                if (settings.jourOffset == -999) {
                  final semaineData = provider.donneesSemaine;
                  if (semaineData == null) {
                    return _buildEmptyState(colorScheme);
                  }
                  return _buildSemaineView(semaineData, colorScheme);
                }

                final donnees = provider.donnees;

                if (donnees == null || donnees.donnees.isEmpty) {
                  return _buildEmptyState(colorScheme);
                }

                return _buildListeView(donnees, colorScheme);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateBar(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildDateChip(
                'Hier',
                -1,
                settings.jourOffset,
                Icons.chevron_left,
                colorScheme,
              ),
              const SizedBox(width: 8),
              _buildDateChip(
                'Aujourd\'hui',
                0,
                settings.jourOffset,
                null,
                colorScheme,
              ),
              const SizedBox(width: 8),
              _buildDateChip(
                'Demain',
                1,
                settings.jourOffset,
                Icons.chevron_right,
                colorScheme,
              ),
              const SizedBox(width: 8),
              _buildSemaineChip(settings.jourOffset, colorScheme),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDateChip(
    String label,
    int offset,
    int currentOffset,
    IconData? icon,
    ColorScheme colorScheme,
  ) {
    final isSelected = offset == currentOffset;

    return GestureDetector(
      onTap: () => _onJourChanged(offset),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primary
              : colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 16,
                color: isSelected ? Colors.white : colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.white : colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSemaineChip(int currentOffset, ColorScheme colorScheme) {
    final isSelected = currentOffset == -999;

    return GestureDetector(
      onTap: () => _onJourChanged(-999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primary
              : colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.grid_view,
              size: 16,
              color: isSelected ? Colors.white : colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 4),
            Text(
              'Semaine',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.white : colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState(ColorScheme colorScheme) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 3,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 50,
                    height: 20,
                    decoration: BoxDecoration(
                      color: colorScheme.outline.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  Container(
                    width: 70,
                    height: 14,
                    decoration: BoxDecoration(
                      color: colorScheme.outline.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                height: 16,
                decoration: BoxDecoration(
                  color: colorScheme.outline.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildErrorState(
    BuildContext context,
    String erreur,
    ColorScheme colorScheme,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_off_outlined, size: 64, color: colorScheme.error),
            const SizedBox(height: 16),
            Text(
              'Erreur de connexion',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              erreur,
              style: TextStyle(
                fontSize: 13,
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: _chargerCours,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.refresh, size: 18, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      'Réessayer',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(ColorScheme colorScheme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 64,
              color: colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'Aucun cours',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Essayez une autre date',
              style: TextStyle(
                fontSize: 13,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListeView(donnees, ColorScheme colorScheme) {
    return RefreshIndicator(
      onRefresh: () async => _chargerCours(),
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 8, bottom: 80),
        itemCount: donnees.donnees.length,
        itemBuilder: (context, index) {
          final cours = donnees.donnees[index];
          return CoursCard(cours: cours);
        },
      ),
    );
  }

  Widget _buildSemaineView(
    Map<String, dynamic> semaineData,
    ColorScheme colorScheme,
  ) {
    final jours = semaineData['jours'] as List<dynamic>? ?? [];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: jours.length,
      itemBuilder: (context, index) {
        final jour = jours[index];
        final evenements = jour['evenements'] as List<dynamic>? ?? [];

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(12),
          ),
          child: ExpansionTile(
            title: Text(
              '${jour['jour_semaine'] ?? ''}',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            subtitle: Text(
              '${jour['date'] ?? ''} • ${evenements.length} cours',
              style: TextStyle(
                fontSize: 12,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            children: evenements.map<Widget>((e) {
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                leading: Container(
                  width: 4,
                  height: 40,
                  decoration: BoxDecoration(
                    color: CoursColors.getTypeColor(e['type_cours'] ?? ''),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                title: Text(
                  e['intitule'] ?? '',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                subtitle: Text(
                  '${e['horaire']} • ${e['salle']}',
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
