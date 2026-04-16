# Campus - Developer Instructions

Two related projects:
- **upgc/** - Django REST API backend
- **emploi_app/** - Flutter mobile app

---

## Django API (upgc/)

### Quick Commands
```bash
cd upgc
pip install -r requirements.txt
python manage.py migrate
python manage.py runserver
```

### Required `.env` File
```env
SECRET_KEY=your_secret_key
DEBUG=True
ALLOWED_HOSTS=127.0.0.1,localhost
```

### Key Endpoints
| Endpoint | Description |
|----------|-------------|
| `/aujourdhui/` | Today's schedule |
| `/<day>/<month>/<year>/` | Specific date |
| `/api/rooms/` | List rooms (`?area=2&refresh=true`) |
| `/api/domaines/` | List domains |

### Query Parameters
- `area` (int, default: 2) - Domain/area ID
- `room` (int, default: 0) - Room ID
- `date` (YYYY-MM-DD or DD/MM/YYYY)
- `semaine` (bool) - Return whole week
- `actualiser` (bool) - Force fresh scrape

### Important Areas
- `2` = Salle UPGC (main campus)
- `16` = Salles louées
- Default areas: `[2, 16]`

### Common Issues
- No `.env` = `ImproperlyConfigured` error
- Network issues = empty schedule (scraper returns `[]`)
- Cache timeout = 300 seconds (5 min)

### Test Scraper
```bash
python -c "from core.scraping import ExtracteurUPGC; e = ExtracteurUPGC(); print(e.recuperer_emploi_du_temps(area=2, date_cible=__import__('datetime').date.today(), date_specifique=True))"
```

---

## Flutter App (emploi_app/)

### Build & Run
```bash
cd emploi_app
flutter pub get
flutter run
```

### Architecture
```
lib/
├── core/
│   ├── constants/constantes_api.dart  # API baseUrl (default: http://192.168.100.74:8000)
│   ├── cache/                         # Local cache with shared_preferences
│   ├── theme/app_theme.dart
│   └── services/network_service.dart
├── data/
│   ├── models/                        # Cours, Information models
│   ├── repositories/                   # Data layer
│   └── services/service_api.dart       # Dio HTTP client
└── presentation/
    ├── providers/                      # ChangeNotifier providers (Cours, Settings, Information)
    ├── screens/                       # Splash, Accueil, Cours, Informations, Parametres
    └── widgets/                        # CoursCard, etc.
```

### Key Providers
- **CoursProvider** - loads schedule (day/week)
- **SettingsProvider** - persists area/room/date selection via SharedPreferences
- **InformationProvider** - news/announcements

### API Integration
- Base URL defined in `lib/core/constants/constantes_api.dart`
- App auto-reloads on resume (see `accueil_screen.dart:didChangeAppLifecycleState`)
- Area 2 (UPGC) uses backend default `[2, 16]` for all campus rooms

### State Management
- Provider + ChangeNotifier pattern
- Settings persisted to SharedPreferences (`area_id`, `room_id`, `jour_offset`)
- `jourOffset`: 0=today, 1=tomorrow, -1=yesterday, -999=week view

### Known IP Configuration
- App defaults to `http://192.168.100.74:8000` - change in `constantes_api.dart` for different networks