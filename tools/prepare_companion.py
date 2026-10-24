"""Importa sem alterar pixels e analisa grade/alfa das fontes do NPC."""
from pathlib import Path
import hashlib
import json
from PIL import Image

root = Path(__file__).resolve().parents[1]
source = root / 'NPC_Personagem/assets/npcs/companheiro/pixel_v2'
target = root / 'assets/npcs/companheiro/pixel_v2'
target.mkdir(parents=True, exist_ok=True)
records = []
for name, expected, count in [('companheiro_idle_48x64.png',(192,64),4),('companheiro_walk_48x64.png',(192,256),16)]:
    data = (source / name).read_bytes()
    (target / name).write_bytes(data)
    image = Image.open(source / name).convert('RGBA')
    assert image.size == expected
    assert set(image.getchannel('A').tobytes()) <= {0,255}
    bounds = []
    for i in range(count):
        x, y = (i % 4) * 48, (i // 4) * 64
        bbox = image.crop((x,y,x+48,y+64)).getchannel('A').getbbox()
        assert bbox and bbox[0]>0 and bbox[1]>0 and bbox[2]<48 and bbox[3]<64
        bounds.append(bbox)
    records.append(dict(file=name,sha256=hashlib.sha256(data).hexdigest(),size=expected,cells=bounds))
(target / 'companheiro_frames.tres').write_bytes((source / 'companheiro_frames.tres').read_bytes())
(target / 'sources.json').write_text(json.dumps(records,indent=2),encoding='utf-8')
print('ATLAS_COMPANION_SOURCES: 20 cells; binary alpha; no edge clipping; copies identical')
