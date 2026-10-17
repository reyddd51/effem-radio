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
- **Bebas Neue** (validée le 17 octobre 2026, remplace Anton) : titres, noms de radio dans le lecteur et le mode voiture, chiffres. Toujours en MAJUSCULES, interlettrage +1 px. Jamais pour du texte courant.
- **Yellowtail** : uniquement le mot « radio » du logo. Nulle part ailleurs.
- **Logo (validé le 16 octobre 2026, option 1)** : EFFEM en **Anton** au dégradé soleil (le logo garde Anton, même si l'app est passée en Bebas Neue) ; « radio » en Yellowtail lagon, posé en bas à droite, incliné de −9°, qui mord un peu sur le M, détouré d'un fin liseré de la couleur du fond. Ne plus jamais mettre « radio » à la suite d'EFFEM.
- **Rethink Sans** (validée le 17 octobre 2026, remplace Manrope) : tout le reste. Graisses : 500 (texte), 700 (boutons, lignes de liste), 800 (noms de radio dans les listes, libellés).
- Échelle : titre d'écran 40 px · titre de section 22–26 px · nom de radio (lecteur) 44 px · texte 15–17 px · secondaire 13 px · libellé 12 px majuscules, interlettrage 1,6 px, mandarine.
- Pas de texte sous 12 px. Pas de texte en gris sur fond gris.

## 3. Espacement et formes
- Marges latérales : 20 px (16 px pour le mini-lecteur et le mode voiture).
- Grille d'espacement : 4 · 8 · 10 · 12 · 14 · 18 · 24 px. Rien d'autre.
- Rayons : vignette d'accueil 18 · liste 14 · mini-lecteur 20 · carte 20 · lecteur (visuel) 32 · bouton pilule = moitié de la hauteur.
- Zones tactiles : **44 × 44 px minimum**, toujours.
- Respecter les zones sûres iPhone : `env(safe-area-inset-top/bottom)`. La barre d'onglets touche le bas de l'écran.

## 4. Composants
- **Vignette de radio** : carré, logo plein cadre sur fond blanc si le logo en a un. Sans logo : dégradé mandarine → magenta, nom en Bebas Neue couleur nuit, qui rétrécit pour que chaque mot tienne sur une ligne (jamais de mot coupé).
- **Radio en cours** : anneau intérieur crème 3 px + nuit 3 px (jamais d'anneau extérieur, il se fait couper) et petit égaliseur magenta en haut à droite.
- **Mini-lecteur** : 64 px de haut, logo 48 px, nom en Bebas Neue 19 px, état en dessous (« ● EN DIRECT » magenta, pause en soleil), bouton soleil 48 px.
- **Barre d'onglets** : 4 onglets (Accueil, Explorer, Podcasts, Réglages). Actif = magenta + graisse 800. Retoucher l'onglet actif ramène à son début.
- **Bouton principal** : pilule `--sunh`, texte Bebas Neue nuit. Un seul par écran.
- **Bouton secondaire** : pilule `--nuit2`, texte Rethink Sans 700 crème.
- **Feuille (minuteur, promesse)** : monte du bas, coins 30 px, poignée grise, croix de fermeture 44 px, fond assombri derrière.
- **États** : chaque écran a son état chargement, erreur (avec « Réessayer »), vide et hors ligne. Jamais d'écran blanc.

## 4 bis. Finition Premium (validée)
- **Verre dépoli** pour la barre d'onglets et le mini-lecteur : fond `rgba(42,15,74,.55)` + flou 24 px + liseré clair 1 px. **Barre d'onglets collée au bas de l'écran** (corrigé le 17 octobre 2026 à la demande de Johanna) : pleine largeur, coins arrondis en haut seulement, hauteur `--tabH` = 66 px + zone du trait iPhone. Mini-lecteur en capsule flottante 10 px au-dessus. Fond de la barre **plein `#21103B`**, et même couleur pour le fond de la page et la couleur de thème : sur certains iPhone (iOS 26/27), le système dessine lui-même une bande sous l'app, de la couleur du fond de la page ; elle doit se confondre avec la barre. Sur l'accueil, la carte « en direct » remplace le mini-lecteur.
- **Grain** très léger sur tout l'écran (opacité 6 %), jamais plus.
- **Teinte de la radio** (`--tint`) : couleur dominante du logo, calculée automatiquement. Elle colore la carte « en direct » de l'accueil, l'ombre du visuel et le fond flouté du lecteur. Le bouton lecture reste toujours au dégradé soleil.
- **Carte « en direct »** (accueil) : 168 px, coins 30, ondes radio en filigrane, logo 76, nom en Bebas Neue, bouton crème 62 px.
- **Top du mois** (accueil, piste A validée le 16 octobre 2026) : logo 74 px, petite pastille de rang en Bebas Neue qui chevauche le coin bas gauche (verre nuit pour tous, dégradé soleil pour le n°1), nom en dessous puis audience en gris (« 34 M »). Plus de grands chiffres en contour ; page Top avec podium (1er au centre, liseré soleil) puis liste avec barres proportionnelles.
- **Vignettes de genre** : dégradé de la couleur du genre, reflet en haut, motif fin propre au genre (lignes, cercles de vinyle, paillettes, zigzag, ondes, arcs, égaliseur), nom en Bebas Neue + nombre de radios.

## 4 ter. Podcasts et Autour de moi (16 octobre 2026)
- Onglet Podcasts : titre PODCASTS, recherche propre aux podcasts, « Mes podcasts » (pochettes en ligne), puis « Top des podcasts » : podium des 3 premiers comme le Top radios, puis liste numérotée avec pochette, nom, éditeur · thème.
- Page d'émission : pochette 104 px (coins 20), nom en Bebas Neue, bouton « Suivre » en contour lagon (plein lagon quand suivi). Épisodes en liste : titre sur 2 lignes max, date + durée (ou « Reste … »), fine barre magenta de progression, rond lecture 44 px.
- Lecteur en mode podcast : pas de « EN DIRECT » ni de point magenta, barre d'avancement magenta avec temps écoulé / restant, boutons −15 s et +30 s à la place de précédent / suivant, pas de cœur ni de bandeau de favoris.
- Raccourcis d'Explorer, juste sous la recherche : pastilles verre de 44 px qui défilent (Autour de moi en lagon, Récentes en soleil, Info en continu en magenta, Outre-mer en mandarine, icône fine + texte Rethink Sans 800). « Autour de moi » affiche « à X km » dans les résultats.

## 4 quater. Écran d'ouverture « Palmiers et néon » (version Enseigne, choisie le 17 octobre 2026)
- Ciel de coucher de soleil (violet → magenta → mandarine → soleil), soleil rayé, palmiers en ombre nuit, logo en enseigne néon : EFFEM (et le cadre de l'Enseigne) apparaît en douceur, sans clignoter ; seul « radio » grésille en s'allumant (le logo garde Anton et « radio » signé en bas à droite).
- Une seule version : Enseigne (cadre néon lagon + plaque « ● EN DIRECT »). Néon XL et Sur le soleil ont été retirées, ainsi que le choix dans Réglages.
- Enseigne choisie par Johanna le 17 octobre 2026 enseigne un peu plus basse, soleil plus bas (puissance actuelle), ville au loin façon Miami sur l'horizon (décalée à droite, bas des tours caché par la courbure de la Terre, floue, couleur « brume rose »), horizon droit. Le logo et la ville sont déjà là : seul le soleil se lève (2,8 s), rien ne clignote.
- 4,2 s (doublé le 17 octobre 2026 à la demande de Johanna), un toucher pour passer, 0,8 s si « Réduire les animations ».

## 4 quinquies. Version ordinateur (écran de 900 px et plus, 17 octobre 2026)
- Même app, même code : seule la mise en page change au-delà de 900 px de large.
- Barre d'onglets à gauche (232 px, fond `#150A2A`, logo EFFEM en haut), contenu centré jusqu'à 1080 px, favoris sur une ligne de 8, genres sur 4 colonnes, Top du mois sans défilement.
- Lecteur et « Modifier » en panneau de 440 px qui glisse depuis la droite ; minuteur et promesse en fenêtre centrée ; mode voiture en plein écran 4 × 2.
- Écran d'ouverture : le ciel prend toute la largeur, le soleil, les palmiers et le néon gardent des proportions de téléphone au centre.

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
