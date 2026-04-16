import 'package:flutter/foundation.dart';
import '../../data/models/information_model.dart';
import '../../data/repositories/information_repository.dart';

class InformationProvider with ChangeNotifier {
  final InformationRepository _repository = InformationRepository();
  
  List<Information> _informations = [];
  bool _estChargement = false;
  String? _erreur;
  
  List<Information> get informations => _informations;
  bool get estChargement => _estChargement;
  String? get erreur => _erreur;
  
  Future<void> chargerInformations({bool actives = false}) async {
    _estChargement = true;
    _erreur = null;
    notifyListeners();
    
    try {
      _informations = await _repository.recupererInformations(actives: actives);
    } catch (e) {
      _erreur = e.toString();
    }
    
    _estChargement = false;
    notifyListeners();
  }
  
  Future<void> creerInformation(Information information) async {
    _estChargement = true;
    _erreur = null;
    notifyListeners();
    
    try {
      final nouvelleInfo = await _repository.creerInformation(information);
      _informations.insert(0, nouvelleInfo);
    } catch (e) {
      _erreur = e.toString();
    }
    
    _estChargement = false;
    notifyListeners();
  }
}
