# Effem Radio — règles du projet

Lire ce fichier en entier avant toute modification de l'app. Les règles de design sont dans `DESIGN.md` : les relire avant de toucher à l'interface, et les mettre à jour quand un nouveau choix est validé par Johanna.

## Le produit
- App de radio grand public, **radios françaises uniquement** (outre-mer compris : Guadeloupe, Martinique, Guyane, La Réunion, Mayotte, Nouvelle-Calédonie, Polynésie, etc.).
- Promesse : **0 pub dans l'app**. Ne jamais écrire « 0 pisteur » (retiré à la demande de Johanna). La pub diffusée par la radio elle-même reste la radio.
- Pause = **son coupé, flux gardé connecté** (durée réglable, 15 min par défaut) : à la reprise on retombe sur le direct sans nouveau préroll. Ne pas casser ce comportement.
- Ne jamais contourner volontairement la publicité des radios (pas de modification des adresses de flux pour éviter les régies).
- 8 favoris mis en avant (accueil en 4 × 2, mode voiture en 2 × 4). Une même radio sous deux noms (« France Info » / « franceinfo ») est la même radio : fonction `same()`.
- Décision du 16 octobre 2026 : **on reste à zéro pub** pour l'instant (aucune bannière, aucun plein écran, aucun sponsor). Les revenus viendront d'**Effem+**.
- **Effem+** (payant, à construire avec l'app native) : réveil radio, « Passeport monde » (radios des autres pays, rangées par pays), égaliseur. Prix proposé, pas encore validé : 1,99 €/mois, 14,99 €/an ou 29,99 € à vie, avec 7 jours d'essai. Tout le reste est gratuit pour tout le monde : écoute, 8 favoris, mode voiture, podcasts, Autour de moi.
- **Podcasts** gratuits, dans leur propre onglet de la barre du bas. Page d'arrivée = **Top des podcasts** (classement Apple Podcasts France du jour, `itunes.apple.com/fr/rss/toppodcasts`), puis Mes podcasts (émissions suivies) et une recherche dédiée. Épisodes via l'annuaire Apple Podcasts, lus directement chez l'éditeur. Pause = vraie pause, reprise là où on s'est arrêté.
- **Autour de moi** : radios à moins de 60 km (recherche par position de Radio Browser). Position arrondie à environ 1 km, jamais enregistrée.
- Éditeur : CYCLONE (SASU, détenue par DLMD). Vendeur affiché sur l'App Store : CYCLONE.

## Le code
- `source/src.html` : tout le code de l'app (HTML, CSS, JS dans un seul fichier).
- `source/build.py` : génère `index.html` à la racine, à lancer depuis la racine : `python3 source/build.py`. Ne jamais modifier `index.html` à la main.
- `source/radio_logos/` : logos intégrés. Un fichier `cle.png` (carré, 320 px) devient le logo `cle` ; l'associer au nom de la radio dans `KNOWN` (clé = nom normalisé, sans espaces ni accents).
- `source/data/local.json` : radios locales par région (relevé Radio Browser).
- Annuaire en direct : Radio Browser (`de1.api.radio-browser.info`), uniquement les flux en `https://`.
- Top radios : classement ACPM du mois (écoutes actives en ligne en France), dans `TOP` ; autorisation de réutilisation à demander à l'ACPM avant le lancement public.
- Publication : GitHub Pages, dépôt `reyddd51/effem-radio`, branche `main`. L'app en ligne : https://reyddd51.github.io/effem-radio/

## Façon de travailler
- Johanna teste sur iPhone (Safari, app ajoutée à l'écran d'accueil). Vérifier chaque changement dans un navigateur à 390 × 844 avant de publier, et penser aux zones sûres de l'iPhone (barre d'état, trait du bas).
- Expliquer les changements en français simple, sans jargon technique.
