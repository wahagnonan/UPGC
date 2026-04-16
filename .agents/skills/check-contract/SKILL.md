---
name: check-contract
description: Vérifie la cohérence front/back - compare endpoints API, types, payloads et identifie les écarts
---

# Check Contract

Inspecter la cohérence entre le frontend et le backend :

1. **Lister les endpoints backend**
   - Examiner tous les fichiers dans `src/app/api/`
   - Identifier: route, méthode HTTP, handler, types de requête/réponse

2. **Analyser les appels frontend**
   - Examiner les fichiers `src/app/(protected)/` et `src/components/`
   - Identifier les appels API (fetch, axios, server actions)

3. **Comparer les contrats**
   - Routes : correspondance front ↔ back ?
   - Méthodes HTTP : GET/POST/PUT/DELETE alignées ?
   - Types TypeScript : payloads correspondants ?
   - Formats de réponse : cohérents ?

4. **Identifier les écarts**
   - Routes manquantes ou différentes
   - Types invalides ou obsolètes
   - Données attendues vs reçues

5. **Proposer corrections**
   - Fichier et ligne concernés
   - Solution recommandée
   - Priorité: high/medium/low

6. **Résumé**
   - Nombre total d'écarts
   - Par catégorie (route, type, format)
   - Actions correctives prioritaires