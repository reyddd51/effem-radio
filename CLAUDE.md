# Effem Radio — règles du projet

Lire ce fichier en entier avant toute modification de l'app. Les règles de design sont dans `DESIGN.md` : les relire avant de toucher à l'interface, et les mettre à jour quand un nouveau choix est validé par Johanna.

## Le produit
- App de radio grand public, **radios françaises uniquement** (outre-mer compris : Guadeloupe, Martinique, Guyane, La Réunion, Mayotte, Nouvelle-Calédonie, Polynésie, etc.).
- Promesse : **0 pub dans l'app**. Ne jamais écrire « 0 pisteur » (retiré à la demande de Johanna). La pub diffusée par la radio elle-même reste la radio.
- Pause = **son coupé, flux gardé connecté** (durée réglable, 15 min par défaut) : à la reprise on retombe sur le direct sans nouveau préroll. Ne pas casser ce comportement.
- Coupure de réseau pendant l'écoute d'une radio : reconnexion automatique (`scheduleRetry`, garde-fou si le son n'avance plus depuis 10 s, relance au retour du réseau), « Réseau perdu · reconnexion… » à l'écran. Ne pas la casser. L'app est figée : pas de zoom (viewport `user-scalable=no`, `touch-action: manipulation`).
- Ne jamais contourner volontairement la publicité des radios (pas de modification des adresses de flux pour éviter les régies).
- 8 favoris mis en avant (accueil en 4 × 2, mode voiture en 2 × 4). Une même radio sous deux noms (« France Info » / « franceinfo ») est la même radio : fonction `same()`.
- Décision du 16 octobre 2026 : **on reste à zéro pub** pour l'instant (aucune bannière, aucun plein écran, aucun sponsor). Les revenus viendront d'**Effem+**.
- **Effem+** (payant, à construire avec l'app native) : réveil radio, « Passeport monde » (radios des autres pays, rangées par pays), égaliseur. Prix proposé, pas encore validé : 1,99 €/mois, 14,99 €/an ou 29,99 € à vie, avec 7 jours d'essai. Tout le reste est gratuit pour tout le monde : écoute, 8 favoris, mode voiture, podcasts, Autour de moi.
- Effem+ construit le 17 octobre 2026 (sans paiement pour l'instant) : carte Effem+ en haut des Réglages, feuille d'offre (`#plusSheet`, formules mensuel / annuel / à vie, bouton « Bientôt disponible »), interrupteur « Aperçu de test » (`plusPreview`) qui débloque sur l'appareil. Réveil radio (`#alarmSheet`, son silencieux `KA` pour garder l'app éveillée tant qu'aucune radio ne joue) et Passeport monde (carte dans Explorer, `showWorld` / `showCountry` : seule exception à « radios françaises uniquement »). Égaliseur pas encore fait : il demande un lecteur audio natif (les flux des radios refusent le traitement du son par la page). Le paiement viendra avec les apps natives (achats intégrés Apple et Google).
- **Podcasts** gratuits, dans leur propre onglet de la barre du bas. Page d'arrivée = **Top des podcasts** (classement Apple Podcasts France du jour, `itunes.apple.com/fr/rss/toppodcasts`), puis Mes podcasts (émissions suivies) et une recherche dédiée. Épisodes via l'annuaire Apple Podcasts, lus directement chez l'éditeur. Pause = vraie pause, reprise là où on s'est arrêté. Lecteur de podcast (design C3 validé le 22 octobre 2026) : boutons −30 s / +30 s, carte « À suivre » qui montre l'épisode d'après dans la liste de l'émission (le plus ancien suivant), avec une flèche de chaque côté pour passer à l'épisode précédent ou suivant (`renderUpNext`, `epLists`). Pas de minuteur sur les podcasts (il reste sur les radios).
- **Autour de moi** : radios à moins de 60 km (recherche par position de Radio Browser). Position arrondie à environ 1 km, jamais enregistrée.
- Éditeur : CYCLONE (SAS au capital de 1 000 €, RCS Bobigny 951 659 655, siège 10 rue Paul Bert 93170 Bagnolet, présidée par DLMD). Vendeur affiché sur l'App Store : CYCLONE.
- Contact public : **contact@effemradio.fr** (domaine effemradio.fr acheté le 17 octobre 2026). Pages légales dans `legal/` : confidentialité, mentions légales, assistance (liens dans Réglages et sur la fiche App Store).

## Le code
- `source/src.html` : tout le code de l'app (HTML, CSS, JS dans un seul fichier).
- `source/build.py` : génère `index.html` à la racine, à lancer depuis la racine : `python3 source/build.py`. Ne jamais modifier `index.html` à la main.
- `source/radio_logos/` : logos intégrés. Un fichier `cle.png` (carré, 320 px) devient le logo `cle` ; l'associer au nom de la radio dans `KNOWN` (clé = nom normalisé, sans espaces ni accents).
- `source/data/local.json` : radios locales par région (relevé Radio Browser).
- Annuaire en direct : Radio Browser (`de1.api.radio-browser.info`), uniquement les flux en `https://`.
- Top radios : classement ACPM du mois (écoutes actives en ligne en France), dans `TOP` ; autorisation de réutilisation à demander à l'ACPM avant le lancement public.
- Publication : GitHub Pages, dépôt `reyddd51/effem-radio`, branche `main`, domaine **effemradio.fr** (fichier `CNAME`, zone DNS chez OVH). L’app en ligne : https://effemradio.fr/

## Façon de travailler
- Johanna teste sur iPhone (Safari, app ajoutée à l'écran d'accueil). Vérifier chaque changement dans un navigateur à 390 × 844 avant de publier, et penser aux zones sûres de l'iPhone (barre d'état, trait du bas).
- Expliquer les changements en français simple, sans jargon technique.

## App native iPhone
- Dossier `app/` : projet Capacitor 7 (gestionnaire de paquets Swift, pas de CocoaPods). Identifiant d'app `fr.cyclone.effem`, nom affiché « Effem », iPhone uniquement, portrait.
- L'app embarque la même page que la version web : `python3 source/build.py`, puis `cd app && node copy-web.js && npx cap sync ios`.
- Réglages natifs : lecture en arrière-plan (`UIBackgroundModes` audio + catégorie audio « playback » dans `AppDelegate.swift`), phrase d'autorisation de position pour « Autour de moi », icône 1024 px et écran de lancement au ciel de l'intro.
- Prévu pour la version 1.1 (décision du 20 octobre 2026, avec le lancement d'Effem+ payant) : Activité en direct (Live Activity) dans la Dynamic Island et sur l'écran verrouillé pour le minuteur et le réveil. Rien à faire avant la sortie de la version 1. Pendant la bêta, vérifier que la pastille « À l'écoute » de l'iPhone s'affiche bien.
- Fabrication et envoi sur TestFlight : `.github/workflows/ios-testflight.yml`, lancé à la main depuis l'onglet Actions de GitHub, sur un Mac Intel de GitHub (les Mac arm64 sont souvent saturés). L'archive est faite sans signature, puis signée pour l'App Store à l'envoi avec la clé App Store Connect (rôle Admin) ; le Mac prend le Xcode le plus récent installé. Premier envoi réussi le 22 octobre 2026 (Xcode 26.3). Version minimale d'iOS : 15 (passée de 14 à 15 le 22 octobre 2026, après l'avertissement ITMS-90068 d'Apple ; obligatoire à partir d'avril 2027). Secrets nécessaires : `APPLE_TEAM_ID`, `ASC_KEY_ID`, `ASC_ISSUER_ID`, `ASC_KEY_P8` (Johanna les saisit elle-même dans GitHub ; ne jamais les écrire dans le dépôt).

## App native Android
- Dossier `app/android/` (même projet Capacitor 7), identifiant `fr.cyclone.effem`, nom « Effem », portrait, vise Android 16 (API 36).
- Lecture écran éteint et notification de la radio en cours : module `@capgo/capacitor-media-session` (service de lecture au premier plan), appelé depuis `src.html` (`NMS`, `nativeSession`, `nativeState`) seulement sur Android. Pause « son coupé » = état `paused` : le service reste actif et le flux connecté.
- Icône adaptative générée à partir de l'icône iPhone (radio sur fond nuit), écran de lancement nuit.
- Fabrication : `.github/workflows/android.yml`, lancé à la main. Sans secrets : version d'essai `effem-essai.apk`. Avec les secrets `ANDROID_KEYSTORE_B64`, `ANDROID_KEYSTORE_PASSWORD`, `ANDROID_KEY_ALIAS`, `ANDROID_KEY_PASSWORD` (Johanna les saisit elle-même) : paquet signé `effem-google-play.aab`.
