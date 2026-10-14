# Effem Radio — prototype

Toutes les radios françaises, sans pub dans l'app.

- `index.html` : l'app (générée, ne pas modifier à la main)
- `source/src.html` : le code de l'app
- `source/build.py` : régénère `index.html` (logos et radios locales intégrés) — `python3 source/build.py` depuis la racine
- `source/data/local.json` : radios locales classées par région (relevé de l'annuaire Radio Browser)

Pause = son coupé, le direct reste connecté (durée réglable) : à la reprise, pas de nouvelle pub de connexion.
