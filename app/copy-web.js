// Copie la version web (générée à la racine par source/build.py) dans app/www, que l'app native embarque.
const fs = require('fs'), path = require('path');
const root = path.join(__dirname, '..'), www = path.join(__dirname, 'www');
fs.rmSync(www, { recursive: true, force: true }); fs.mkdirSync(www);
for (const f of ['index.html', 'manifest.webmanifest', 'icon-180.png', 'icon-192.png', 'icon-512.png'])
  if (fs.existsSync(path.join(root, f))) fs.copyFileSync(path.join(root, f), path.join(www, f));
console.log('www prêt');
