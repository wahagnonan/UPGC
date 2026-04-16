import '../services/service_api.dart';
import '../models/information_model.dart';

class InformationRepository {
  final ServiceApi _serviceApi = ServiceApi();
  
  Future<List<Information>> recupererInformations({bool actives = false}) async {
    final donnees = await _serviceApi.getInformations(actives: actives);
    return donnees.map((e) => Information.fromJson(e)).toList();
  }
  
  Future<Information> creerInformation(Information information) async {
    final reponse = await _serviceApi.creerInformation(information.toJson());
    return Information.fromJson(reponse);
  }
}
