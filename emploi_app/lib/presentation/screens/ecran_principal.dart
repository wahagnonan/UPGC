import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cours_provider.dart';
import '../providers/settings_provider.dart';
import 'accueil_screen.dart';
import 'informations_screen.dart';
import 'parametres_screen.dart';

class EcranPrincipal extends StatefulWidget {
  const EcranPrincipal({super.key});

  @override
  State<EcranPrincipal> createState() => _EcranPrincipalState();
}

class _EcranPrincipalState extends State<EcranPrincipal> {
  int _indexActuel = 0;

  final List<Widget> _ecrans = [
    const AccueilScreen(),
    const InformationsScreen(),
    const ParametresScreen(),
  ];

  void _onDestinationSelected(int index) {
    if (index == 0 && _indexActuel != 0) {
      final settings = context.read<SettingsProvider>();

      final areaId = settings.areaId;
      final roomId = settings.roomId;

      int? apiArea = (areaId > 0 && areaId != 2) ? areaId : null;
      int? apiRoom = roomId > 0 ? roomId : null;

      context.read<CoursProvider>().chargerEmploiDuJour(
        date: _getDateFromOffset(settings.jourOffset),
        area: apiArea,
        room: apiRoom,
        semaine: settings.jourOffset == -999,
      );
    }
    setState(() {
      _indexActuel = index;
    });
  }

  String? _getDateFromOffset(int offset) {
    if (offset == -999) return null;
    final date = DateTime.now().add(Duration(days: offset));
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: IndexedStack(index: _indexActuel, children: _ecrans),
      bottomNavigationBar: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLowest.withValues(alpha: 0.9),
              border: Border(
                top: BorderSide(
                  color: colorScheme.outline.withValues(alpha: 0.1),
                ),
              ),
            ),
            child: NavigationBar(
              selectedIndex: _indexActuel,
              onDestinationSelected: _onDestinationSelected,
              backgroundColor: Colors.transparent,
              elevation: 0,
              height: 80,
              labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.calendar_month_outlined),
                  selectedIcon: Icon(Icons.calendar_month),
                  label: 'Accueil',
                ),
                NavigationDestination(
                  icon: Icon(Icons.newspaper_outlined),
                  selectedIcon: Icon(Icons.newspaper),
                  label: 'Information',
                ),
                NavigationDestination(
                  icon: Icon(Icons.settings_outlined),
                  selectedIcon: Icon(Icons.settings),
                  label: 'Paramètres',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
