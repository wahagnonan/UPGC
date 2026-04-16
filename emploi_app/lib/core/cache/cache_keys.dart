class CacheKeys {
  static const String cours = 'cours_list';
  static const String domaines = 'domaines_list';
  static const String ressources = 'ressources_list';
  static const String informations = 'informations_list';
  static const String settings = 'app_settings';
}

class CacheTTL {
  static const Duration cours = Duration(minutes: 30);
  static const Duration domaines = Duration(hours: 24);
  static const Duration ressources = Duration(hours: 24);
  static const Duration informations = Duration(hours: 1);
  static const Duration defaultDuration = Duration(minutes: 15);
}
