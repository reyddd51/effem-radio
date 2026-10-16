# Effem Radio — règles de design

Direction : **Sunset Premium** (validée le 16 octobre 2026). Une nuit violette, un coucher de soleil réservé aux actions, les logos des radios comme héros. L'app doit se lire en une seconde, d'une main, même en marchant.

## 1. Couleurs (jetons)
| Jeton | Valeur | Usage |
|---|---|---|
| `--nuit` | `#170B2E` | Fond de l'app. Jamais de noir pur. |
| `--nuit2` | `#2A0F4A` | Surfaces : cartes, listes, boutons secondaires. |
| `--nuit3` | `#3A1763` | Surface active, élément en cours de déplacement, pistes d'interrupteur. |
| `--magenta` | `#FF2E88` | État « en direct », onglet actif, favori (cœur plein), retrait. |
| `--mandarine` | `#FF8A3D` | Libellés de section (petites capitales). |
| `--soleil` | `#FFD166` | Avertissements doux (pause, minuteur, erreur réseau). |
| `--lagon` | `#19C3B4` | Informations rassurantes (promesse, recherche, focus). |
| `--creme` | `#FFF4E6` | Texte principal. Jamais de blanc pur. |
| `--lilas` | `#CDBFE6` | Texte secondaire, icônes inactives. |
| `--gris` | `#8E7FAA` | Texte tertiaire, éléments désactivés, numéros. |
| `--sun` | dégradé vertical `#FFD166 → #FF8A3D → #FF2E88 → #8B2BD9` | **Uniquement** le bouton lecture/pause et le mot EFFEM. |
| `--sunh` | dégradé horizontal `#FFD166 → #FF8A3D → #FF2E88` | Boutons d'action principaux, choix sélectionné. |

Règle : **un seul dégradé soleil visible par zone d'écran.** Le reste est en aplats.

## 2. Typographie
- **Anton** (titres, noms de radio dans le lecteur et le mode voiture, chiffres) : toujours en MAJUSCULES, interlettrage +1 px. Jamais pour du texte courant.
- **Yellowtail** : uniquement le mot « radio » du logo. Nulle part ailleurs.
- **Manrope** : tout le reste. Graisses : 500 (texte), 700 (boutons, lignes de liste), 800 (noms de radio dans les listes, libellés).
- Échelle : titre d'écran 40 px · titre de section 22–26 px · nom de radio (lecteur) 44 px · texte 15–17 px · secondaire 13 px · libellé 12 px majuscules, interlettrage 1,6 px, mandarine.
- Pas de texte sous 12 px. Pas de texte en gris sur fond gris.

## 3. Espacement et formes
- Marges latérales : 20 px (16 px pour le mini-lecteur et le mode voiture).
- Grille d'espacement : 4 · 8 · 10 · 12 · 14 · 18 · 24 px. Rien d'autre.
- Rayons : vignette d'accueil 18 · liste 14 · mini-lecteur 20 · carte 20 · lecteur (visuel) 32 · bouton pilule = moitié de la hauteur.
- Zones tactiles : **44 × 44 px minimum**, toujours.
- Respecter les zones sûres iPhone : `env(safe-area-inset-top/bottom)`. La barre d'onglets touche le bas de l'écran.

## 4. Composants
- **Vignette de radio** : carré, logo plein cadre sur fond blanc si le logo en a un. Sans logo : dégradé mandarine → magenta, nom en Anton couleur nuit, qui rétrécit pour que chaque mot tienne sur une ligne (jamais de mot coupé).
- **Radio en cours** : anneau intérieur crème 3 px + nuit 3 px (jamais d'anneau extérieur, il se fait couper) et petit égaliseur magenta en haut à droite.
- **Mini-lecteur** : 64 px de haut, logo 48 px, nom en Anton 19 px, état en dessous (« ● EN DIRECT » magenta, pause en soleil), bouton soleil 48 px.
- **Barre d'onglets** : 3 onglets (Accueil, Explorer, Réglages). Actif = magenta + graisse 800. Retoucher l'onglet actif ramène à son début.
- **Bouton principal** : pilule `--sunh`, texte Anton nuit. Un seul par écran.
- **Bouton secondaire** : pilule `--nuit2`, texte Manrope 700 crème.
- **Feuille (minuteur, promesse)** : monte du bas, coins 30 px, poignée grise, croix de fermeture 44 px, fond assombri derrière.
- **États** : chaque écran a son état chargement, erreur (avec « Réessayer »), vide et hors ligne. Jamais d'écran blanc.

## 4 bis. Finition Premium (validée)
- **Verre dépoli** pour la barre d'onglets et le mini-lecteur : capsules flottantes, fond `rgba(42,15,74,.55)` + flou 24 px + liseré clair 1 px. Barre d'onglets à `--tabB` du bas, mini-lecteur 74 px au-dessus. Sur l'accueil, la carte « en direct » remplace le mini-lecteur.
- **Grain** très léger sur tout l'écran (opacité 6 %), jamais plus.
- **Teinte de la radio** (`--tint`) : couleur dominante du logo, calculée automatiquement. Elle colore la carte « en direct » de l'accueil, l'ombre du visuel et le fond flouté du lecteur. Le bouton lecture reste toujours au dégradé soleil.
- **Carte « en direct »** (accueil) : 168 px, coins 30, ondes radio en filigrane, logo 76, nom en Anton, bouton crème 62 px.
- **Top du mois** : grands chiffres en contour soleil derrière les logos ; page Top avec podium (1er au centre, liseré soleil) puis liste avec barres proportionnelles.
- **Vignettes de genre** : dégradé de la couleur du genre, reflet en haut, motif fin propre au genre (lignes, cercles de vinyle, paillettes, zigzag, ondes, arcs, égaliseur), nom en Anton + nombre de radios.

## 4 ter. Podcasts et Autour de moi (16 octobre 2026)
- Carte « Podcasts » dans Explorer : dégradé lagon → violet, pile de 3 pochettes à droite, libellé « À réécouter » en lagon.
- Page d'émission : pochette 104 px (coins 20), nom en Anton, bouton « Suivre » en contour lagon (plein lagon quand suivi). Épisodes en liste : titre sur 2 lignes max, date + durée (ou « Reste … »), fine barre magenta de progression, rond lecture 44 px.
- Lecteur en mode podcast : pas de « EN DIRECT » ni de point magenta, barre d'avancement magenta avec temps écoulé / restant, boutons −15 s et +30 s à la place de précédent / suivant, pas de cœur ni de bandeau de favoris.
- « Autour de moi » : carte verre avec pastille lagon et repère de position ; les résultats affichent « à X km ».

## 5. Textes
- Tutoiement, phrases courtes, verbes d'action (« Réessayer », « Ajouter une station »).
- Dire ce qui se passe et quoi faire : « La station ne répond pas. Réessaie ou choisis-en une autre. »
- Pas de jargon (flux, stream, buffer, URL) dans l'interface.
- Ne jamais écrire « 0 pisteur ». La promesse est « 0 pub dans l'app ».

## 6. Interdits
- Aucune bannière, aucun écran plein de pub, aucune fenêtre surgissante au lancement.
- Pas de dégradé violet → bleu « IA générique », pas d'émojis comme icônes, pas de police système pour les titres.
- Pas d'icônes épaisses dans des pastilles sur les vignettes de genre (jugées pas assez premium).
- Pas plus de 3 couleurs vives sur un même écran (hors logos).
- Pas de logo de radio déformé, recoloré ou recadré au point de le rendre illisible.
- Pas de faux logo : si on n'a pas le vrai, on affiche la vignette avec le nom.
- Pas d'animation qui dure plus de 300 ms ou qui bloque une action.
