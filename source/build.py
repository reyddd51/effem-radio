import base64, io, json
from PIL import Image
L='source/radio_logos/'; out={}
for k,f in [('inter','inter.svg'),('culture','culture.svg')]:
    out[k]='data:image/svg+xml;base64,'+base64.b64encode(open(L+f,'rb').read()).decode()
import glob, os
for p in sorted(glob.glob(L+'*.png')):   # tous les logos PNG du dossier, nommés par leur clé
    k=os.path.splitext(os.path.basename(p))[0]
    im=Image.open(p).convert('RGB'); im.thumbnail((256,256)); b=io.BytesIO(); im.save(b,'JPEG',quality=84)
    out[k]='data:image/jpeg;base64,'+base64.b64encode(b.getvalue()).decode()
s=open('source/src.html').read().replace('%%LOGOS%%',json.dumps(out)).replace('%%LOCAL%%',open('source/data/local.json').read())
open('index.html','w').write(s)
json.dump({"name":"Effem Radio","short_name":"Effem","start_url":"./","display":"standalone","background_color":"#170B2E","theme_color":"#170B2E",
 "icons":[{"src":"icon-192.png","sizes":"192x192","type":"image/png"},{"src":"icon-512.png","sizes":"512x512","type":"image/png"}]},open('manifest.webmanifest','w'),ensure_ascii=False)
print(len(s)//1024,'Ko')
