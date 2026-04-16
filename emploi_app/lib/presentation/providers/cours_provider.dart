import 'package:flutter/foundation.dart';
import '../../data/models/cours_model.dart';
import '../../data/repositories/cours_repository.dart';

class CoursProvider with ChangeNotifier {
  final CoursRepository _repository = CoursRepository();
  
  ReponseEmploiDuTemps? _donnees;
  Map<String, dynamic>? _donneesSemaine;
  bool _estChargement = false;
  String? _erreur;
  
  ReponseEmploiDuTemps? get donnees => _donnees;
  Map<String, dynamic>? get donneesSemaine => _donneesSemaine;
  bool get estChargement => _estChargement;
  String? get erreur => _erreur;
  
  Future<void> chargerEmploiDuJour({String? date, int? area, int? room, bool semaine = false}) async {
    _estChargement = true;
    _erreur = null;
    notifyListeners();
    
    try {
      if (semaine) {
        _donneesSemaine = await _repository.recupererSemaine(area: area, room: room);
        _donnees = null;
      } else {
        _donnees = await _repository.recupererEmploiDuJour(date: date, area: area, room: room);
      }
    } catch (e) {
      _erreur = e.toString();
    }
    
    _estChargement = false;
    notifyListeners();
  }
}
