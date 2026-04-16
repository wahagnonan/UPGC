import 'package:dio/dio.dart';
import '../../core/constants/constantes_api.dart';
import '../../core/services/network_service.dart';

class ServiceApi {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: ConstantesApi.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  final NetworkService _networkService = NetworkService();

  Future<bool> _checkConnectivity() async {
    final isConnected = await _networkService.isConnected();
    if (!isConnected) {
      throw 'Pas de connexion internet';
    }
    return true;
  }

  Future<Map<String, dynamic>> getCours({
    String? date,
    bool semaine = false,
    int? area,
    int? room,
  }) async {
    await _checkConnectivity();

    String url = ConstantesApi.aujourdhui;

    List<String> params = [];
    if (semaine) {
      params.add('semaine=true');
    }

    // Si area = 2 (défaut UPGC), ne pas l'envoyer pour que le backend utilise AREAS_PAR_DEFAUT [2,16]
    // Cela permet d'avoir toutes les salles du campus (UPGC + Salles louées)
    // Only send explicit area filter (not the default)
    if (area != null && area > 0 && area != 2) {
      params.add('area=$area');
    }

    if (room != null && room > 0) {
      params.add('room=$room');
    }

    if (date != null && date.isNotEmpty) {
      // Convertir DD/MM/YYYY vers YYYY-MM-DD
      final parties = date.split('/');
      if (parties.length == 3) {
        final dateFormatee =
            '${parties[2]}-${parties[1].padLeft(2, '0')}-${parties[0].padLeft(2, '0')}';
        params.add('date=$dateFormatee');
      }
    }

    String queryParams = '';
    if (params.isNotEmpty) {
      queryParams = '?${params.join("&")}';
    }

    try {
      final reponse = await _dio.get('$url$queryParams');
      return reponse.data;
    } on DioException catch (e) {
      throw _gererErreur(e);
    }
  }

  Future<List<dynamic>> getInformations({bool actives = false}) async {
    await _checkConnectivity();

    String url = ConstantesApi.informations;
    if (actives) {
      url += '?inclure_expirees=false';
    }

    try {
      final reponse = await _dio.get(url);
      final data = reponse.data;
      return data['informations'] ?? [];
    } on DioException catch (e) {
      throw _gererErreur(e);
    }
  }

  Future<Map<String, dynamic>> creerInformation(
    Map<String, dynamic> data,
  ) async {
    await _checkConnectivity();

    final url = ConstantesApi.informations;

    try {
      final reponse = await _dio.post(url, data: data);
      return reponse.data;
    } on DioException catch (e) {
      throw _gererErreur(e);
    }
  }

  Future<Map<String, dynamic>> getConfig({int? area}) async {
    await _checkConnectivity();

    String url = ConstantesApi.config;
    if (area != null && area > 0) {
      url += '?area=$area';
    }
    try {
      final reponse = await _dio.get(url);
      return reponse.data;
    } on DioException catch (e) {
      throw _gererErreur(e);
    }
  }

  Future<Map<String, dynamic>> getDomaines() async {
    await _checkConnectivity();

    try {
      final reponse = await _dio.get(ConstantesApi.domaines);
      return reponse.data;
    } on DioException catch (e) {
      throw _gererErreur(e);
    }
  }

  Future<Map<String, dynamic>> getDomaineDetail(int areaId) async {
    await _checkConnectivity();

    try {
      final reponse = await _dio.get('${ConstantesApi.domaines}$areaId/');
      return reponse.data;
    } on DioException catch (e) {
      throw _gererErreur(e);
    }
  }

  Future<Map<String, dynamic>> getRessources(int areaId) async {
    await _checkConnectivity();

    try {
      final reponse = await _dio.get(
        '${ConstantesApi.domaines}$areaId/ressources/',
      );
      return reponse.data;
    } on DioException catch (e) {
      throw _gererErreur(e);
    }
  }

  Future<Map<String, dynamic>> getEmploiRessource(
    int areaId,
    int roomId, {
    String? date,
    bool semaine = false,
  }) async {
    await _checkConnectivity();

    List<String> params = [];
    if (date != null) {
      params.add('date=$date');
    }
    if (semaine) {
      params.add('semaine=true');
    }

    String queryParams = '';
    if (params.isNotEmpty) {
      queryParams = '?${params.join("&")}';
    }

    try {
      final reponse = await _dio.get(
        '${ConstantesApi.domaines}$areaId/ressources/$roomId/edt/$queryParams',
      );
      return reponse.data;
    } on DioException catch (e) {
      throw _gererErreur(e);
    }
  }

  Future<Map<String, dynamic>> getRooms({int? area}) async {
    await _checkConnectivity();

    String url = ConstantesApi.rooms;
    if (area != null && area > 0) {
      url += '?area=$area';
    }

    try {
      final reponse = await _dio.get(url);
      return reponse.data;
    } on DioException catch (e) {
      throw _gererErreur(e);
    }
  }

  String _gererErreur(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Délai de connexion dépassé - Vérifiez votre connexion';
      case DioExceptionType.connectionError:
        final message = e.message ?? '';
        if (message.contains('SocketException')) {
          return 'Serveur inaccessible - Vérifiez que le serveur est en cours d\'exécution';
        }
        return 'Erreur de connexion: $message';
      case DioExceptionType.badResponse:
        return 'Erreur du serveur: ${e.response?.statusCode}';
      case DioExceptionType.cancel:
        return 'Requête annulée';
      default:
        return 'Erreur: ${e.message}';
    }
  }
}
