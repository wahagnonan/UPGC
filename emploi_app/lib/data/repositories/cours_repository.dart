import 'package:flutter/foundation.dart';
import '../../core/cache/cache_service.dart';
import '../../core/cache/cache_keys.dart';
import '../services/service_api.dart';
import '../models/cours_model.dart';

class CoursRepository {
  final ServiceApi _serviceApi = ServiceApi();

  Future<ReponseEmploiDuTemps> recupererEmploiDuJour({
    String? date,
    int? area,
    int? room,
    bool forceRefresh = false,
  }) async {
    final cacheKey =
        '${CacheKeys.cours}_${date ?? 'today'}_${area ?? 0}_${room ?? 0}';

    if (!forceRefresh) {
      final cached = await CacheService.get<Map<String, dynamic>>(cacheKey);
      if (cached != null) {
        debugPrint('✅ Cache HIT pour cours');
        return ReponseEmploiDuTemps.fromJson(cached);
      }
    }

    try {
      debugPrint('🌐 Cache MISS – appel API');
      final reponse = await _serviceApi.getCours(
        date: date,
        area: area,
        room: room,
      );

      await CacheService.set(
        cacheKey,
        reponse,
        ttl: const Duration(minutes: 30),
      );

      return ReponseEmploiDuTemps.fromJson(reponse);
    } catch (e) {
      debugPrint('⚠️ Erreur API, tentative fallback cache: $e');

      final staleData = await CacheService.getStale<Map<String, dynamic>>(
        cacheKey,
      );
      if (staleData != null) {
        debugPrint('⚠️ Utilisation données périmées (offline)');
        return ReponseEmploiDuTemps.fromJson(staleData);
      }

      rethrow;
    }
  }

  Future<Map<String, dynamic>> recupererSemaine({
    int? area,
    int? room,
    bool forceRefresh = false,
  }) async {
    final cacheKey = '${CacheKeys.cours}_semaine_${area ?? 0}_${room ?? 0}';

    if (!forceRefresh) {
      final cached = await CacheService.get<Map<String, dynamic>>(cacheKey);
      if (cached != null) {
        return cached;
      }
    }

    final reponse = await _serviceApi.getCours(
      semaine: true,
      area: area,
      room: room,
    );

    await CacheService.set(cacheKey, reponse, ttl: const Duration(hours: 2));

    return reponse;
  }
}
