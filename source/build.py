import base64, io, json
from PIL import Image
L='source/radio_logos/'; out={}
for k,f in [('inter','inter.svg'),('culture','culture.svg')]:
    out[k]='data:image/svg+xml;base64,'+base64.b64encode(open(L+f,'rb').read()).decode()
for k,f in [('franceinfo','franceinfo.png'),('fip','fip.png'),('tsf','tsf.png'),('nostalgie','nostalgie.png'),('skyrock','skyrock.png'),('rfm','rfm.png'),('europe1','europe1.png'),('rtl','rtl.png'),('rmc','rmc.png'),('nova','nova.png')]:
    im=Image.open(L+f).convert('RGB'); im.thumbnail((320,320)); b=io.BytesIO(); im.save(b,'JPEG',quality=86)
    out[k]='data:image/jpeg;base64,'+base64.b64encode(b.getvalue()).decode()
s=open('source/src.html').read().replace('%%LOGOS%%',json.dumps(out)).replace('%%LOCAL%%',open('source/data/local.json').read())
open('index.html','w').write(s)
json.dump({"name":"Effem Radio","short_name":"Effem","start_url":"./","display":"standalone","background_color":"#170B2E","theme_color":"#170B2E",
 "icons":[{"src":"icon-192.png","sizes":"192x192","type":"image/png"},{"src":"icon-512.png","sizes":"512x512","type":"image/png"}]},open('manifest.webmanifest','w'),ensure_ascii=False)
print(len(s)//1024,'Ko')
