---
name: commit-ready
description: Prépare un commit cohérent - inspecte git status, proposeConventional commits, refuse les changements sans lien
---

# Commit Ready

Préparer un commit propre et cohérent :

1. **Analyser le statut**
   - `git status` → fichiers modifiés, ajoutés, supprimés
   - `git diff` → changements précis par fichier

2. **Vérifier la cohérence des changements**
   - Les changements sont-ils liés à une même fonctionnalité ?
   - Y a-t-il un mélange de concerns (ex: auth + UI + business logic) ?

3. **Proposer le message de commit**
   - Format: `type(scope): description`
   - Types: `feat`, `fix`, `refactor`, `docs`, `chore`, `test`
   - Description courte (max 50 caractères)

4. **Découper si nécessaire**
   - Si changements sans lien → proposer plusieurs commits
   - Grouper par: fonctionnalité, fichier, ou type de changement

5. **Rappeler les conventions**
   - Naming: camelCase
   - Format:conventional commits
   - Sujet: infinitif (add, not adding)

6. **NE PAS créer le commit**
   - Proposer uniquement le message
   - Attendre validation user avant de commit
   - Ne jamais auto-commiter