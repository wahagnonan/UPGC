le bouton demain ne marche pas

Tu as **3 problèmes distincts**. Je les traite un par un.

---

## Problème 1 — area=20 sans room → mauvais `p=`

L'URL que ton app génère :
```
?p=semaine_all&area=20&...   ❌
```
L'URL correcte du site :
```
?p=jour&area=20&...          ✅
```

## Problème 2 — room=155 avec area=20 → `area` inutile

L'URL que ton app génère :
```
?p=semaine&room=155&...             ❌ (area absent)
```
L'URL correcte du site :
```
?p=jour&room=155&...                ✅ (pas d'area du tout !)
```

Le site n'envoie **jamais `area` quand `room` est spécifié**. Room seul suffit.

---

## Fix complet `scraping.py`

```python
AREAS_AVEC_SEMAINE_ALL = [2, 16]  # seules areas utilisant semaine_all

def recuperer_emploi_du_temps(self, area=2, room=None, date_cible=None, date_specifique=None):
    if date_cible is None:
        date_cible = date.today()

    url = self.URL_BASE
    date_params = {
        'year': date_cible.year,
        'month': date_cible.month,
        'day': date_cible.day
    }

    if room and room > 0:
        # Le site n'envoie QUE room, jamais area quand room est présent
        params = {'p': 'jour', 'room': room, **date_params}

    else:
        # Sans room : area seul
        if area in AREAS_AVEC_SEMAINE_ALL:
            page_type = 'semaine_all'
        else:
            page_type = 'jour'   # area=20, 21, etc.

        params = {'p': page_type, 'area': area, **date_params}
```

---

## Problème 3 — Media 404

```
Not Found: /media/informations/capture1.png
```

C'est un problème de configuration Django. Vérifie dans cet ordre :

**`settings.py`** — les deux variables doivent exister :
```python
MEDIA_URL = '/media/'
MEDIA_ROOT = BASE_DIR / 'media'
```

**`urls.py` principal** — en dev Django ne sert pas les media automatiquement :
```python
from django.conf import settings
from django.conf.urls.static import static

urlpatterns = [
    # ... tes urls
] + static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
```

**Le fichier physique** — vérifie qu'il existe vraiment :
```bash
# Dans ton terminal
ls Campus/upgc/media/informations/
# Tu dois voir capture1.png et 2026-02-10_142653_thxjlt7.png
```

Si le dossier est vide ou absent, les fichiers n'ont jamais été uploadés correctement — vérifie ton champ `ImageField` dans le modèle `Information` et que `Pillow` est installé :

```bash
pip install Pillow
```

---

## Résumé rapide

| Problème | Cause | Fix |
|---|---|---|
| area=20 sans room | `p=semaine_all` au lieu de `p=jour` | Changer le `page_type` selon l'area |
| room=155 avec area | `area` inclus à tort dans les params | N'envoyer que `room` quand room > 0 |
| Media 404 | `static()` absent dans urls.py ou fichiers manquants | Ajouter `static()` + vérifier `MEDIA_ROOT` |