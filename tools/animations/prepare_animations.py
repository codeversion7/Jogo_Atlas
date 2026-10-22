"""Technical preparation only: does not invent missing gait poses."""
import sys, json, hashlib, statistics, shutil
from pathlib import Path
from PIL import Image, ImageDraw
from components import components

ROOT=Path(__file__).resolve().parents[2]
OUT=ROOT/'assets/personagem/revisao'
DOC=ROOT/'docs/atlas/animacoes'
OUT.mkdir(parents=True,exist_ok=True)
DOC.mkdir(parents=True,exist_ok=True)
DIRS=['down','left','right','up']
CELL=(40,48)
PIVOT=(20,46)
report={'status':'RASCUNHO TECNICO; ciclos ainda nao aprovados', 'cell':CELL,'pivot':PIVOT,'directions':DIRS,'animations':{}}
all_frames={}
for kind,name,cols,fps in [('idle','Spritesheet de respiração do protagonista.png',4,4),('walk','Spritesheet de caminhada do Atlas.png',6,8)]:
    original=ROOT/'referencias/personagem'/name
    im=Image.open(original).convert('RGBA')
    found=components(im)
    assert len(found)==cols*4,(name,len(found))
    # Rows are clustered by actual component tops, never by dividing 1254 / 4.
    found.sort(key=lambda c:c['bbox'][1])
    frames=[]; records=[]
    for row in range(4):
        group=sorted(found[row*cols:(row+1)*cols],key=lambda c:c['bbox'][0])
        # One isotropic scale per direction; retain per-frame height changes for review.
        height=max(c['bbox'][3]-c['bbox'][1] for c in group)
        scale=43/height
        for col,component in enumerate(group):
            bbox=component['bbox']
            crop=im.crop(bbox)
            crop.putalpha(crop.getchannel('A').point(lambda a:255 if a>=128 else 0))
            # Hair/head center, unlike the full silhouette, is not displaced by scarf sway.
            pixels=crop.getchannel('A').load()
            centers=[]
            for y in range(round(crop.height*.08),round(crop.height*.28)):
                xs=[x for x in range(crop.width) if pixels[x,y]]
                if xs: centers.append((min(xs)+max(xs))/2)
            head_center=statistics.median(centers)
            size=(round(crop.width*scale),round(crop.height*scale))
            small=crop.resize(size,Image.Resampling.NEAREST)
            x=PIVOT[0]-round(head_center*scale)
            y=PIVOT[1]-small.height
            assert x>=1 and x+small.width<=39,(kind,row,col,size,x)
            cell=Image.new('RGBA',CELL,(0,0,0,0))
            cell.paste(small,(x,y))
            # No RGB residue in transparent pixels; no semi-transparent edge pixels.
            cell.putdata([p if p[3] else (0,0,0,0) for p in cell.get_flattened_data()])
            frames.append(cell)
            records.append({'direction':DIRS[row],'frame':col,'source_bbox':bbox,'source_size':crop.size,'scale':scale,'destination_bbox':cell.getbbox(),'head_axis_x':PIVOT[0],'foot_baseline_y':PIVOT[1]})
        if kind == 'idle':
            # Hold boots/lower legs from the neutral frame. Changes to this area are
            # not breathing, and must not make a stationary character shuffle.
            fixed_feet=frames[row*cols].crop((0,32,40,48))
            for frame in frames[row*cols:(row+1)*cols]:
                frame.paste(fixed_feet,(0,32))
        for col,frame in enumerate(frames[row*cols:(row+1)*cols]):
            records[row*cols+col]['destination_bbox']=frame.getbbox()
        all_frames[f'{kind}_{DIRS[row]}']=frames[row*cols:(row+1)*cols]
    sheet=Image.new('RGBA',(cols*40,4*48))
    for n,frame in enumerate(frames):sheet.paste(frame,((n%cols)*40,(n//cols)*48))
    sheet.save(OUT/f'{kind}_rascunho.png')
    hist=sheet.getchannel('A').histogram()
    assert sum(hist[1:255])==0
    report['animations'][kind]={'source':name,'source_sha256':hashlib.sha256(original.read_bytes()).hexdigest(),'detected_components':len(found),'fps':fps,'columns':cols,'sheet_size':sheet.size,'frames':records,'binary_alpha':True,'fixed_lower_region': [0,32,40,48] if kind=='idle' else None}

def checker(size):
    bg=Image.new('RGBA',size,'#a7b4b4'); d=ImageDraw.Draw(bg)
    for y in range(0,size[1],4):
        for x in range(0,size[0],4):
            if (x//4+y//4)%2:d.rectangle((x,y,x+3,y+3),fill='#718181')
    return bg

for name,frames in all_frames.items():
    kind=name.split('_')[0]; fps=4 if kind=='idle' else 8
    for factor,label in [(1,'normal'),(2,'lento')]:
        duration=round(1000/fps*factor)
        frames[0].save(DOC/f'{name}_{label}.png',save_all=True,append_images=frames[1:],duration=duration,loop=0,disposal=0,blend=0)
        # GIF preview uses a fixed checkerboard so browser GIF disposal cannot hide edge defects.
        display=[]
        for frame in frames:
            bg=checker(CELL);bg.alpha_composite(frame)
            display.append(bg.convert('RGB').resize((160,192),Image.Resampling.NEAREST))
        # GIF is quantized to 10 ms: alternate 120/130 to preserve a 750 ms walk cycle.
        gif_duration = [120,130]*3 if kind=='walk' and factor==1 else duration
        display[0].save(DOC/f'{name}_{label}.gif',save_all=True,append_images=display[1:],duration=gif_duration,loop=0,optimize=False,disposal=2)
    strip=Image.new('RGB',(len(frames)*164,212),'#253339');d=ImageDraw.Draw(strip)
    for n,frame in enumerate(frames):
        bg=checker(CELL);bg.alpha_composite(frame);strip.paste(bg.resize((160,192),Image.Resampling.NEAREST),(n*164,0));d.text((n*164,194),f'{n+1}',fill='white')
    strip.save(DOC/f'{name}_quadros.png')

# SpriteFrames is ready to inspect in the editor, but explicitly named as a draft.
lines=['[gd_resource type="SpriteFrames" load_steps=43 format=3]','', '[ext_resource type="Texture2D" path="res://assets/personagem/revisao/idle_rascunho.png" id="1_idle"]','[ext_resource type="Texture2D" path="res://assets/personagem/revisao/walk_rascunho.png" id="2_walk"]','']
anim_records=[]
for name,frames in all_frames.items():
    kind,direction=name.split('_'); row=DIRS.index(direction)
    ids=[]
    for col in range(len(frames)):
        ident=f'{name}_{col}';ids.append(ident)
        lines.extend([f'[sub_resource type="AtlasTexture" id="{ident}"]',f'atlas = ExtResource("{1 if kind=="idle" else 2}_{kind}")',f'region = Rect2({col*40}, {row*48}, 40, 48)',''])
    frame_text=', '.join('{"duration": 1.0, "texture": SubResource("'+i+'")}' for i in ids)
    anim_records.append('{"frames": ['+frame_text+'], "loop": true, "name": &"'+name+'", "speed": '+str(4.0 if kind=='idle' else 8.0)+'}')
lines.extend(['[resource]','animations = ['+',\n'.join(anim_records)+']',''])
(OUT/'atlas_rascunho.tres').write_text('\n'.join(lines),encoding='utf-8')
(DOC/'medicoes.json').write_text(json.dumps(report,ensure_ascii=False,indent=2),encoding='utf-8')

html='''<!doctype html><html lang="pt-BR"><meta charset="utf-8"><title>ATLAS — revisão dos ciclos</title><style>body{background:#172329;color:#e8e4d6;font:16px system-ui;margin:28px}article{display:inline-block;vertical-align:top;border:1px solid #567;padding:16px;margin:8px}img{image-rendering:pixelated;background:repeating-conic-gradient(#a7b4b4 0% 25%,#718181 0% 50%) 0/8px 8px}figure{display:inline-block;margin:12px}figcaption{font-size:13px}h2{font-size:18px}a{color:#dfba7c}</style><h1>ATLAS — rascunhos normalizados</h1><p>40 × 48 px · pivô (20,46) · baixo, esquerda, direita, cima.</p><p><strong>Não aprovados para substituir a animação do jogo.</strong> Conferir apoios, passagem dos pés, estabilidade e fechamento. As poses laterais ainda precisam de redesenho.</p>'''
for name in all_frames:
    html+=f'<article><h2>{name}</h2>'
    for label in ['normal','lento']:
        html+=f'<figure><img width="40" height="48" src="{name}_{label}.png"><figcaption>{label} · tamanho nativo</figcaption></figure><figure><img width="160" height="192" src="{name}_{label}.png"><figcaption>{label} · 4× nearest</figcaption></figure>'
    html+=f'<p><a href="{name}_quadros.png">Quadros lado a lado</a></p></article>'
(DOC/'previas.html').write_text(html,encoding='utf-8')
print('Prepared two draft sheets, 8 animations, 16 APNGs, 16 GIFs, 8 frame strips and measurements.')


