---
name: project-docs
description: Génère la documentation du projet Campus - comment ça marche et comment l'utiliser
---

# Project Docs

Générer la documentation du projet Campus :

## 1. Analyser la structure du projet

Lire les fichiers clés pour comprendre l'architecture :
- `AGENTS.md` (instructions principales)
- `upgc/core/views.py` - endpoints API
- `upgc/core/scraping.py` - logique de scraping
- `upgc/core/models.py` - modèles de données
- `lib/core/constants/constantes_api.dart` - configuration API Flutter
- `lib/main.dart` - point d'entrée Flutter
- `lib/presentation/providers/` - providers state management
- `lib/data/services/service_api.dart` - communication API

## 2. Documenter l'architecture

Structure du projet :
- **Backend (upgc/)** : Django REST API
- **Frontend (emploi_app/)** : Application Flutter mobile
- **Configuration** : `.env`, `constantes_api.dart`

## 3. Expliquer le fonctionnement

### Backend Django
- Scraping : comment les données sont extraites du site UPGC
- API : endpoints disponibles (`/aujourdhui/`, `/<day>/<month>/<year>/`, `/api/rooms/`, `/api/domaines/`)
- Modèles : Cours, Salle, Domaine, Information
- Cache : timeout 300 secondes

### Frontend Flutter
- State management : Provider pattern
- Cache local : SharedPreferences
- Communication : Dio HTTP client
- Écrans : Splash, Accueil, Cours, Informations, Paramètres

## 4. Expliquer l'utilisation

### Configuration initiale
1. Backend : créer `.env` avec SECRET_KEY, DEBUG, ALLOWED_HOSTS
2. Frontend : configurer IP du serveur dans `constantes_api.dart`

### Lancer le projet
- Backend : `cd upgc && python manage.py runserver`
- Frontend : `cd emploi_app && flutter run`

### Tester le scraper
```bash
cd upgc
python -c "from core.scraping import ExtracteurUPGC; e = ExtracteurUPGC(); print(e.recuperer_emploi_du_temps(area=2, date_cible=__import__('datetime').date.today(), date_specifique=True))"
```

## 5. Créer le README.md à la racine

Le README doit contenir une documentation complète avec les sections suivantes :

### a) Backend Django (upgc/)
- **Vue d'ensemble** : API REST qui scrape les données du site UPGC
- **Scraping (core/scraping.py)** : ExtracteurUPGC utilisant BeautifulSoup
  - URL source: https://upgc.mygrr.net/app.php
  - Paramètres: area, room, date_cible, date_specifique
  - Modes: p=jour (vue jour), p=semaine (semaine UPGC), p=semaine_all (tous domaines)
- **Modèles (core/models.py)** : Cours (horaire, type_cours, enseignant, intitule, niveau, salle, jour, ressource) et Information
- **Views (core/views.py)** : Tous les endpoints API
- **Cache** : Timeout 300 secondes avec clés par area/room/date

### b) Frontend Flutter (emploi_app/)
- **Point d'entrée (main.dart)** : MultiProvider avec CoursProvider, InformationProvider, SettingsProvider
- **Configuration API (lib/core/constants/constantes_api.dart)** : baseUrl, endpoints
- **Service API (lib/data/services/service_api.dart)** : Client Dio
  - Méthodes: getCours, getInformations, getDomaines, getRooms, getEmploiRessource
- **Providers** :
  - CoursProvider : charge EDT jour/semaine
  - SettingsProvider : préférences via SharedPreferences (area_id, room_id, jour_offset)
  - InformationProvider : actualités
- **Structure du code** : core/, data/, presentation/

### c) Documentation API Django
- **Endpoints** : /api/, /api/aujourdhui/, /api/<jour>/<mois>/<annee>/, /api/domaines/, /api/domaines/<id>/ressources/, /api/rooms/, /api/informations/
- **Paramètres** : area, room, date, semaine, actualiser, inclure_expirees, refresh
- **Exemples de requêtes et réponses JSON détaillées**

### d) Configuration et Installation
- Backend: requirements.txt, .env, migrate, runserver
- Frontend: flutter pub get, configurer IP serveur, flutter run
- Commandes utiles et tests

### e) Résolution des problèmes
- Table des problèmes courants avec causes et solutions

## 6. Mettre à jour AGENTS.md

Si besoin, ajouter des informations sur :
- Commandes spécifiques au projet
- Tests ou vérifications
- Points d'attention particuliers