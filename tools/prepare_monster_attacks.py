"""Analisa fontes sem editar pixels; prepara recortes/pivôs para animação no Godot."""
from pathlib import Path
import hashlib
import json
from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / 'assets/monstros/ataques_v1'
OUT.mkdir(parents=True, exist_ok=True)
SOURCE = json.loads((ROOT / 'MANIFESTO.json').read_text(encoding='utf-8-sig'))
IDS = ['b1_fenda','b2_carcaca','b3_esporo','b4_escavador']
# Recortes limpos: excluir spill da célula vizinha e FX já pintados nas poses de impacto.
CROPS = [
 [(45,175,655,585),(720,155,1160,590),(675,695,1205,1135)],
 [(45,150,660,575),(680,70,1330,575),(720,665,1300,1105)],
 [(70,80,605,510),(730,80,1265,505)],
 [(49,131,601,550)],
]
SCALES = [0.09,0.08,0.082,34/419]
PHASES = [
 [('windup',.45,8),('active',.16,4),('recovery',.45,8)],
 [('windup',.65,8),('active',.12,4),('recovery',.65,8)],
 [('windup',.50,6),('launch',.12,3),('flight',.55,8),('impact',.20,4),('recovery',.35,5)],
 [('warning',.65,8),('breakthrough',.20,5),('impact',.15,3),('recovery',.65,8)],
]
result={'version':1,'scope':'front-facing visual review; not gameplay integration',
        'canvas':[128,128],'pivot':[64,64],'sources':[],'attacks':[]}
for kind, item in enumerate(SOURCE['attacks']):
    actual = hashlib.sha256((ROOT/item['path']).read_bytes()).hexdigest()
    assert actual == item['sha256'], f'Source changed: {item["name"]}'
    result['sources'].append({'path':item['path'],'sha256':actual})
    path=item['path'] if kind<3 else 'assets/monstros/b4_escavador/pixel_v2/b4_escavador_quatro_direcoes.png'
    image=Image.open(ROOT/path).convert('RGBA')
    poses=[]
    for pose_index, box in enumerate(CROPS[kind]):
        x0,y0,x1,y1=box
        opaque=image.crop(box).getchannel('A').point(lambda a:255 if a>=216 else 0)
        bounds=opaque.getbbox()
        assert bounds is not None
        bottom=bounds[3]
        # Fenda cruza as pernas em alturas diferentes; incluir os dois apoios,
        # sem ancorar todo o corpo apenas no pé mais baixo.
        foot_band = 80 if kind == 0 and pose_index == 1 else 28
        xs=[x for y in range(max(bounds[1],bottom-foot_band),bottom)
              for x in range(bounds[0],bounds[2]) if opaque.getpixel((x,y))]
        poses.append({'region':[x0,y0,x1-x0,y1-y0],
                      'anchor':[(min(xs)+max(xs)+1)/2,bottom],
                      'source_scale':SCALES[kind]})
    result['attacks'].append({'id':IDS[kind],'body_source':path,'poses':poses,
        'phases':[dict(name=name,duration=duration,frames=count) for name,duration,count in PHASES[kind]],
        'target_locked_at_warning':kind==3,
        'note':'Escavador uses the existing clean body for emergence; attack sheet supplies the visual reference.' if kind==3 else 'Clean source keys plus native intermediate deformation and separate FX.'})
(OUT/'profiles.json').write_text(json.dumps(result,indent=2,ensure_ascii=False),encoding='utf-8')
print('ATLAS_MONSTER_ATTACK_PROFILES: 4 sources verified; 4 front-facing profiles; originals unchanged')
