import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/services/service_api.dart';

enum ModeAffichage { liste, tableau }

class AreaItem {
  final int id;
  final String nom;

  const AreaItem({required this.id, required this.nom});

  factory AreaItem.fromJson(Map<String, dynamic> json) {
    return AreaItem(id: json['id'] ?? 0, nom: json['nom'] ?? '');
  }
}

class RoomItem {
  final int id;
  final String nom;

  const RoomItem({required this.id, required this.nom});

  factory RoomItem.fromJson(Map<String, dynamic> json) {
    return RoomItem(id: json['id'] ?? 0, nom: json['nom'] ?? '');
  }
}

class SettingsProvider with ChangeNotifier {
  final ServiceApi _serviceApi = ServiceApi();
  static SharedPreferences? _prefs;

  static const String _keyAreaId = 'area_id';
  static const String _keyRoomId = 'room_id';
  static const String _keyJourOffset = 'jour_offset';

  int _departementId = 0;
  String _departementDomaineNom = 'Tous les domaines';
  int _areaId = 2;
  int _ressourceId = 0;
  String _ressourceNom = 'Toutes les ressources';
  int _roomId = 0;
  ModeAffichage _modeAffichage = ModeAffichage.liste;
  int _jourOffset = 0;
  bool _estChargement = false;
  bool _settingsPret = false;

  bool get settingsPret => _settingsPret;
  List<AreaItem> _areas = [];
  List<RoomItem> _rooms = [];

  int get departementId => _departementId;
  String get departementDomaineNom => _departementDomaineNom;
  int get areaId => _areaId;
  int get ressourceId => _ressourceId;
  String get ressourceNom => _ressourceNom;
  int get roomId => _roomId;
  ModeAffichage get modeAffichage => _modeAffichage;
  int get jourOffset => _jourOffset;
  bool get estChargement => _estChargement;
  List<AreaItem> get areas => _areas;
  List<RoomItem> get rooms => _rooms;

  Future<void> _loadSavedSettings() async {
    _prefs ??= await SharedPreferences.getInstance();

    _areaId = _prefs!.getInt(_keyAreaId) ?? 2;
    _roomId = _prefs!.getInt(_keyRoomId) ?? 0;
    _jourOffset = _prefs!.getInt(_keyJourOffset) ?? 0;

    debugPrint(
      'Settings loaded: area=$_areaId, room=$_roomId, jourOffset=$_jourOffset',
    );
  }

  Future<void> _saveSettings() async {
    _prefs ??= await SharedPreferences.getInstance();

    await _prefs!.setInt(_keyAreaId, _areaId);
    await _prefs!.setInt(_keyRoomId, _roomId);
    await _prefs!.setInt(_keyJourOffset, _jourOffset);

    debugPrint(
      'Settings saved: area=$_areaId, room=$_roomId, jourOffset=$_jourOffset',
    );
  }

  Future<void> chargerConfig() async {
    _estChargement = true;
    notifyListeners();

    // Charger les paramètres enregistrés
    await _loadSavedSettings();

    try {
      final domaines = await _serviceApi.getDomaines();

      _areas =
          (domaines['domaines'] as List<dynamic>?)
              ?.map((e) => AreaItem.fromJson(e))
              .toList() ??
          [];

      _areas.insert(0, const AreaItem(id: 0, nom: 'Tous les domaines'));

      if (_areaId > 0) {
        await _chargerRoomsPourArea(_areaId);
      } else {
        _rooms = [];
        _rooms.insert(0, const RoomItem(id: 0, nom: 'Toutes les ressources'));
      }
    } catch (e) {
      debugPrint('Erreur chargement config: $e');
    }

    _estChargement = false;
    _settingsPret = true;
    notifyListeners();
  }

  void setDepartement(int areaId, String nom) {
    _departementId = areaId;
    _departementDomaineNom = nom;
    _areaId = areaId;
    _roomId = 0;
    _ressourceNom = 'Toutes les ressources';
    notifyListeners();

    _saveSettings();

    if (areaId > 0) {
      _chargerRoomsPourArea(areaId);
    } else {
      _rooms = [];
      _rooms.insert(0, const RoomItem(id: 0, nom: 'Toutes les ressources'));
      notifyListeners();
    }
  }

  Future<void> _chargerRoomsPourArea(int areaId) async {
    try {
      final ressources = await _serviceApi.getRessources(areaId);
      final roomsData =
          (ressources['ressources'] as List<dynamic>?)
              ?.map((e) => RoomItem.fromJson(e))
              .toList() ??
          [];

      _rooms = roomsData;
      _rooms.insert(0, const RoomItem(id: 0, nom: 'Toutes les ressources'));
      notifyListeners();
    } catch (e) {
      debugPrint('Erreur chargement rooms: $e');
    }
  }

  void setRessource(int roomId, String nom) {
    _ressourceId = roomId;
    _ressourceNom = nom;
    _roomId = roomId;
    notifyListeners();

    _saveSettings();
  }

  void setModeAffichage(ModeAffichage mode) {
    _modeAffichage = mode;
    notifyListeners();
  }

  void setJourOffset(int offset) {
    _jourOffset = offset;
    notifyListeners();

    _saveSettings();
  }

  void setAujourdhui() => setJourOffset(0);
  void setDemain() => setJourOffset(1);
  void setHier() => setJourOffset(-1);
  void setSemaine() => setJourOffset(-999);

  Future<void> reinitialiserParametres() async {
    _areaId = 2;
    _roomId = 0;
    _ressourceId = 0;
    _ressourceNom = 'Toutes les ressources';
    _jourOffset = 0;
    _departementId = 0;
    _departementDomaineNom = 'Salle UPGC';
    _settingsPret = false;

    _rooms = [];
    _rooms.insert(0, const RoomItem(id: 0, nom: 'Toutes les ressources'));

    await _saveSettings();
    notifyListeners();

    debugPrint(
      'Paramètres réinitialisés: area=$_areaId, room=$_roomId, jourOffset=$_jourOffset',
    );
  }
}
