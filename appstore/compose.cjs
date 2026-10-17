const {chromium}=require('playwright');const path=require('path');
const S=[
 ['r1-home-play.png','0 PUB DANS L’APP','JUSTE LA RADIO.<br>RIEN D’AUTRE.','Tes radios françaises en direct, sans bannière ni vidéo qui s’invite.'],
 ['r2-player.png','EN DIRECT','UN TOUCHER,<br>ET C’EST PARTI','Tes 8 radios préférées à portée de pouce. Pause sans perdre le direct.'],
 ['r3-car.png','MODE VOITURE','LES YEUX<br>SUR LA ROUTE','Huit grandes touches pour changer de radio d’un geste.'],
 ['r5-explore.png','TOUTE LA FRANCE','DE BREST<br>À NOUMÉA','Les radios locales de toutes les régions et de l’outre-mer.'],
 ['r4-pods.png','PODCASTS','LE TOP DU JOUR,<br>GRATUIT','Les podcasts les plus écoutés en France, et tes émissions suivies.'],
];
(async()=>{const u=new URL(process.env.HTTPS_PROXY);
const b=await chromium.launch({proxy:{server:u.protocol+'//'+u.host,username:decodeURIComponent(u.username),password:decodeURIComponent(u.password)}});
const pg=await b.newPage({viewport:{width:440,height:956},deviceScaleFactor:3});
for (const [i,[img,k,h,p]] of S.entries()){
 const url='file://'+path.resolve('frame.html')+'?'+new URLSearchParams({img:'file://'+path.resolve(img),k,h,p});
 await pg.goto(url);await pg.waitForTimeout(1200);
 await pg.screenshot({path:`effem-appstore-${i+1}.png`});
}
await b.close();})();
