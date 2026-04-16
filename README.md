# Campus - Gestion des Emploi du Temps UPGC

Application complète pour consulter et gérer les emploi du temps du campus UPGC (Université Peleforo Gbon Coulibaly). Composée d'un backend Django REST API et d'une application mobile Flutter.

---

## Table des Matières

1. [Architecture du Projet](#architecture-du-projet)
2. [Backend Django (upgc/)](#backend-django-upgc)
3. [Frontend Flutter (emploi_app/)](#frontend-flutter-emploi_app)
4. [Documentation API Django](#documentation-api-django)
5. [Configuration et Installation](#configuration-et-installation)
6. [Problèmes Courants](#problèmes-courants)

---

## Architecture du Projet

```
Campus/
├── upgc/               # Backend Django REST API
│   ├── core/          # Models, Views, Serializers, Scraping
│   │   ├── models.py       # Cours, Information
│   │   ├── views.py       # API endpoints
│   │   ├── serializers.py # Serialisation JSON
│   │   ├── scraping.py    # Extracteur UPGC (BeautifulSoup)
│   │   └── data.py        # Constantes (AREAS, ROOMS, etc.)
│   └── upgc/          # Configuration Django
│
├── emploi_app/        # Application Flutter mobile
│   └── lib/
│       ├── core/           # Constantes, Cache, Theme, Services
│       ├── data/           # Models, Repositories, API Service
│       └── presentation/   # Providers, Screens, Widgets
│
├── .agents/           # Configuration des agents IA
└── README.md         # Ce fichier
```

---

## Backend Django (upgc/)

### Vue d'Ensemble

Le backend est une API REST Django qui scrape les données du site UPGC et les expose via des endpoints REST.

### Scraping (core/scraping.py)

Le module `ExtracteurUPGC` utilise **BeautifulSoup** pour extraire les données du site `https://upgc.mygrr.net/app.php`.

**Fonctionnalités principales:**
- Récupère l'emploi du temps par date ou par semaine
- Supporte le filtrage par zone (`area(domaines)`) et par salle (`room (ressources)`)
- Parse les types de cours: CM, TD, TP, EXAMEN, DEVOIR, etc.
- Extrait: horaire, type_cours, enseignant, intitule, niveau, salle, ressource

**Paramètres de scraping:**
- `area`: ID de la zone (2 = UPGC principal, 16 = Salles louées)
- `room`: ID de la salle (optionnel)
- `date_cible`: Date目标
- `date_specifique`: True = jour, False = semaine

**Modes d'affichage:**
- `p=jour`: Vue jour - ressources en colonnes
- `p=semaine`: Vue semaine - créneaux horaires (UPGC)
- `p=semaine_all`: Vue semaine tous domaines

### Modèles de Données (core/models.py)

**Cours:**
- `horaire` - Ex: "07:30 à 11:30"
- `type_cours` - CM, TD, TP, EXAMEN, DEVOIR, etc.
- `enseignant` - Nom de l'enseignant
- `intitule` - Nom du cours
- `niveau` - Ex: "L2 BIO"
- `salle` - Ex: "AMPHI B"
- `jour` - Date du cours
- `ressource` - Salle principale

**Information:**
- `titre` - Titre de l'information
- `description` - Contenu
- `image` - Image optionnelle
- `date_publication` - Date de publication
- `date_expiration` - Date d'expiration (optionnel)

### Cache

- Timeout: 300 secondes (5 minutes)
- Stockage: Django cache (par défaut en mémoire)
- Clés: `edt_jour_area{area}_room{room}_{date}`, `edt_semaine_area{area}_room{room}_{date}`

---

## Frontend Flutter (emploi_app/)

### Vue d'Ensemble

Application mobile multi-plateforme (Android/iOS) utilisant Provider pour le state management.

### Point d'Entrée (main.dart)

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await CacheService.init();  // Initialise le cache local

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CoursProvider()),
        ChangeNotifierProvider(create: (_) => InformationProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
      ],
      child: const MonApp(),
    ),
  );
}
```

### Configuration API (lib/core/constants/constantes_api.dart)

```dart
class ConstantesApi {
  static const String baseUrl = 'http://192.168.100.74:8000';
  static const String aujourdhui = '/api/aujourdhui/';
  static const String informations = '/api/informations/';
  static const String domaines = '/api/domaines/';
  static const String rooms = '/api/rooms/';
}
```

### Communication API (lib/data/services/service_api.dart)

Le `ServiceApi` utilise **Dio** comme client HTTP pour communiquer avec le backend.

**Méthodes principales:**
- `getCours(date, semaine, area, room)` - Récupère l'emploi du temps
- `getInformations(actives)` - Liste les informations/actualités
- `getDomaines()` - Liste les domaines/zones
- `getRooms(area)` - Liste les salles d'une zone
- `getEmploiRessource(areaId, roomId, date, semaine)` - EDT par ressource

**Gestion des erreurs:**
- Timeout de connexion (30s)
- Erreurs réseau (SocketException)
- Réponses serveur incorrectes

### Providers (State Management)

**CoursProvider:**
- Charge l'emploi du temps du jour ou de la semaine
- Stocke: `_donnees` (jour), `_donneesSemaine` (semaine), `_estChargement`, `_erreur`

**SettingsProvider:**
- Gère les préférences utilisateur persistées via **SharedPreferences**
- Clés: `area_id`, `room_id`, `jour_offset`
- Charge la configuration (domaines, rooms) depuis l'API
- Méthodes: `setDepartement()`, `setRessource()`, `setJourOffset()`

**InformationProvider:**
- Gère les informations/actualités du campus

### Persistance (SharedPreferences)

| Clé | Type | Description |
|-----|------|-------------|
| `area_id` | int | Zone sélectionnée (défaut: 2) |
| `room_id` | int | Salle sélectionnée (défaut: 0 = toutes) |
| `jour_offset` | int | Décalage jour (0=aujourd'hui, 1=demain, -1=hier, -999=semaine) |

### Structure du Code Flutter

```
lib/
├── core/
│   ├── constants/
│   │   └── constantes_api.dart    # URLs API
│   ├── cache/
│   │   └── cache_service.dart     # Cache local
│   ├── theme/
│   │   └── app_theme.dart         # Thèmes Material/Cupertino
│   └── services/
│       └── network_service.dart   # Vérification connexion
├── data/
│   ├── models/
│   │   ├── cours_model.dart       # Modèle Cours
│   │   └── information_model.dart # Modèle Information
│   ├── repositories/
│   │   ├── cours_repository.dart  # Logique récupération cours
│   │   └── information_repository.dart
│   └── services/
│       └── service_api.dart       # Client HTTP Dio
└── presentation/
    ├── providers/
    │   ├── cours_provider.dart     # State cours
    │   ├── settings_provider.dart # State paramètres
    │   └── information_provider.dart
    ├── screens/
    │   ├── splash_screen.dart     # Écran splash
    │   ├── accueil_screen.dart    # Écran principal
    │   ├── cours_screen.dart      # Liste des cours
    │   ├── informations_screen.dart
    │   └── parametres_screen.dart # Paramètres
    └── widgets/
        └── cours_card.dart        # Carte cours
```

---

## Documentation API Django

### Endpoints Disponibles

| Méthode | Endpoint | Description |
|---------|----------|-------------|
| GET | `/api/` | Racine API - liste des endpoints |
| GET | `/api/aujourdhui/` | Emploi du temps du jour |
| GET | `/api/<jour>/<mois>/<annee>/` | Emploi d'une date spécifique |
| GET | `/api/semaine/` | Emploi de la semaine |
| GET | `/api/domaines/` | Liste des domaines/zones |
| GET | `/api/domaines/<id>/` | Détail d'un domaine |
| GET | `/api/domaines/<id>/ressources/` | Ressources d'un domaine |
| GET | `/api/domaines/<id>/ressources/<room_id>/edt/` | EDT d'une ressource |
| GET | `/api/rooms/` | Liste des salles |
| GET | `/api/informations/` | Liste des informations |

### Paramètres de Requête

| Paramètre | Type | Description | Exemple |
|-----------|------|-------------|---------|
| `area` | int | ID de la zone (défaut: 2) | `?area=2` |
| `room` | int | ID de la salle | `?room=5` |
| `date` | string | Date (YYYY-MM-DD ou DD/MM/YYYY) | `?date=2024-01-15` |
| `semaine` | bool | Retourner la semaine | `?semaine=true` |
| `actualiser` | bool | Forcer le re-scraping | `?actualiser=true` |
| `inclure_expirees` | bool | Inclure les informations expirées | `?inclure_expirees=false` |
| `refresh` | bool | Forcer le rafraîchissement | `?refresh=true` |

### Exemples de Requêtes

**Emploi du jour:**
```
GET /api/aujourdhui/
GET /api/aujourdhui/?area=2&room=5
GET /api/aujourdhui/?date=15/01/2024
```

**Emploi de la semaine:**
```
GET /api/aujourdhui/?semaine=true
GET /api/aujourdhui/?semaine=true&area=16
```

**Domaines et Salles:**
```
GET /api/domaines/
GET /api/domaines/2/ressources/
GET /api/rooms/?area=2
```

**Informations:**
```
GET /api/informations/
GET /api/informations/?inclure_expirees=false
```

### Réponses JSON

**Emploi du jour:**
```json
{
  "date": "2024-01-15",
  "jour_semaine": "Lundi",
  "area": 2,
  "room": null,
  "source": "scraping",
  "timestamp": "2024-01-15T10:30:00Z",
  "nombre_evenements": 5,
  "donnees": [
    {
      "id": 1,
      "jour": "2024-01-15",
      "horaire": "07:30 à 11:30",
      "type_cours": "CM",
      "enseignant": "Dr COULIBALY",
      "intitule": "CHIMIE ORGANIQUE",
      "niveau": "L2 BIO",
      "salle": "AMPHI B",
      "ressource": "Amphi B"
    }
  ]
}
```

**Semaine:**
```json
{
  "semaine": {
    "debut": "2024-01-15",
    "fin": "2024-01-21",
    "numero": 3,
    "annee": 2024
  },
  "area": 2,
  "room": null,
  "nombre_total_evenements": 25,
  "jours": [
    {
      "date": "2024-01-15",
      "jour_semaine": "Lundi",
      "nombre_evenements": 5,
      "evenements": [...]
    }
  ],
  "timestamp": "2024-01-15T10:30:00Z"
}
```

---

## Configuration et Installation

### Backend (Django)

1. **Installer les dépendances:**
   ```bash
   cd upgc
   pip install -r requirements.txt
   ```

2. **Créer le fichier `.env`:**
   ```env
   SECRET_KEY=votre_secret_key_generer
   DEBUG=True
   ALLOWED_HOSTS=127.0.0.1,localhost
   ```

3. **Appliquer les migrations:**
   ```bash
   python manage.py migrate
   ```

4. **Lancer le serveur:**
   ```bash
   python manage.py runserver
   ```

### Frontend (Flutter)

1. **Installer les dépendances:**
   ```bash
   cd emploi_app
   flutter pub get
   ```

2. **Configurer l'IP du serveur** dans `lib/core/constants/constantes_api.dart`:
   ```dart
   static const String baseUrl = 'http://192.168.100.74:8000';
   ```

3. **Lancer l'application:**
   ```bash
   flutter run
   ```

4. **Build APK (Android):**
   ```bash
   flutter build apk --debug
   ```

### Tester le Scraper

```bash
cd upgc
python -c "from core.scraping import ExtracteurUPGC; e = ExtracteurUPGC(); print(e.recuperer_emploi_du_temps(area=2, date_cible=__import__('datetime').date.today(), date_specifique=True))"
```

---

## Problèmes Courants

| Problème | Cause | Solution |
|----------|-------|----------|
| `ImproperlyConfigured` | Fichier `.env` manquant | Créer le fichier `.env` avec les variables requises |
| Emploi du temps vide | Problème réseau ou site source | Vérifier la connexion et l'accessibilité de upgc.mygrr.net |
| App ne se connecte pas | IP serveur incorrecte | Modifier `baseUrl` dans `constantes_api.dart` |
| Timeout de connexion | Serveur trop lent ou unreachable | Vérifier que le backend est en cours d'exécution |
| Données obsolètes | Cache non expiré | Ajouter `?actualiser=true` à la requête API |

---

## Zones/Domaines

| ID | Nom |
|----|-----|
| 2 | Salle UPGC (campus principal) |
| 16 | Salles louées |

**Zones par défaut:** `[2, 16]` (affiche toutes les salles du campus)

---

## Notes

- L'application mobile nécessite un réseau permettant d'atteindre le serveur backend
- Le backend utilise BeautifulSoup pour le scraping -敏感性 au changement de structure du site source
- Le cache serveur (300s) et le cache local SharedPreferences travaillent ensemble pour optimiser les performances