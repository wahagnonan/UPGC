import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

class CacheService {
  static const String _cacheBoxName = 'cache';
  static Box<Map>? _box;

  static Future<void> init() async {
    await Hive.initFlutter();
    _box = await Hive.openBox<Map>(_cacheBoxName);
    debugPrint('Cache Hive initialisé');
  }

  static Future<void> close() async {
    await _box?.close();
  }

  static Future<void> clearAll() async {
    await _box?.clear();
    debugPrint('Cache.clearAll()');
  }

  static Box<Map>? get box {
    if (_box == null || !_box!.isOpen) {
      debugPrint('Cache: Box non initialisée, appel init() requis');
    }
    return _box;
  }

  static Future<T?> get<T>(String key) async {
    final box = CacheService.box;
    if (box == null) return null;

    final raw = box.get(key);
    if (raw == null) {
      debugPrint('Cache MISS: $key (inexistant)');
      return null;
    }

    try {
      final ttlMinutes = raw['ttl'] as int? ?? 15;
      final cachedAtStr = raw['cachedAt'] as String?;

      if (cachedAtStr == null) {
        await box.delete(key);
        return null;
      }

      final cachedAt = DateTime.parse(cachedAtStr);
      final ttl = Duration(minutes: ttlMinutes);
      final isExpired = DateTime.now().isAfter(cachedAt.add(ttl));

      if (isExpired) {
        await box.delete(key);
        debugPrint('Cache EXPIRÉ: $key');
        return null;
      }

      debugPrint('Cache HIT: $key');
      return raw['data'] as T?;
    } catch (e) {
      debugPrint('Cache ERREUR lecture $key: $e');
      await box.delete(key);
      return null;
    }
  }

  static Future<void> set<T>(String key, T data, {Duration? ttl}) async {
    final box = CacheService.box;
    if (box == null) return;

    final ttlValue = ttl?.inMinutes ?? 15;
    final entry = <String, dynamic>{
      'data': data,
      'cachedAt': DateTime.now().toIso8601String(),
      'ttl': ttlValue,
    };

    await box.put(key, entry);
    debugPrint('Cache SET: $key (TTL: ${ttlValue}min)');
  }

  static Future<void> invalidate(String key) async {
    final box = CacheService.box;
    if (box == null) return;

    await box.delete(key);
    debugPrint('Cache invalidate: $key');
  }

  static Future<T?> getStale<T>(String key) async {
    final box = CacheService.box;
    if (box == null) return null;

    final raw = box.get(key);
    if (raw == null) return null;

    try {
      debugPrint('Cache STALE (offline fallback): $key');
      return raw['data'] as T?;
    } catch (e) {
      return null;
    }
  }
}
