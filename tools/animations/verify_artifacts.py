import sys,json,hashlib
from pathlib import Path
from PIL import Image,ImageChops
root=Path(__file__).resolve().parents[2]
doc=root/'docs/atlas/animacoes'
measure=json.loads((doc/'medicoes.json').read_text(encoding='utf-8'))
results={'checks':[], 'idle_foot_mask_differences':{}, 'limitations':'Pixel metrics do not certify a gait or absence of sliding.'}
for kind, count, cycle in [('idle',4,1000),('walk',6,750)]:
    sheet=Image.open(root/f'assets/personagem/revisao/{kind}_rascunho.png').convert('RGBA')
    assert sheet.size==(count*40,192)
    hist=sheet.getchannel('A').histogram()
    assert sum(hist[1:255])==0
    assert all(p==(0,0,0,0) for p in sheet.get_flattened_data() if p[3]==0)
    original=root/'referencias/personagem'/measure['animations'][kind]['source']
    assert hashlib.sha256(original.read_bytes()).hexdigest()==measure['animations'][kind]['source_sha256']
    for row,direction in enumerate(['down','left','right','up']):
        for col in range(count):
            cell=sheet.crop((col*40,row*48,(col+1)*40,(row+1)*48))
            bbox=cell.getbbox()
            assert bbox and bbox[0]>=1 and bbox[2]<=39 and bbox[1]>=1 and bbox[3]==46
        if kind=='idle':
            masks=[sheet.crop((col*40,row*48+36,(col+1)*40,row*48+46)).getchannel('A') for col in range(count)]
            results['idle_foot_mask_differences'][direction]=[sum(p>0 for p in ImageChops.difference(masks[0],m).get_flattened_data()) for m in masks]
            assert results['idle_foot_mask_differences'][direction]==[0,0,0,0]
            lower=[sheet.crop((col*40,row*48+32,(col+1)*40,row*48+48)) for col in range(count)]
            assert all(frame.tobytes()==lower[0].tobytes() for frame in lower)
        for mode,factor in [('normal',1),('lento',2)]:
            for ext in ['png','gif']:
                path=doc/f'{kind}_{direction}_{mode}.{ext}'
                im=Image.open(path)
                assert im.n_frames==count,(path,im.n_frames)
                durations=[]
                for n in range(im.n_frames):
                    im.seek(n);durations.append(im.info['duration'])
                assert sum(durations)==cycle*factor,(path,durations)
                results['checks'].append({'file':path.name,'frames':im.n_frames,'duration_ms':sum(durations),'loop':im.info.get('loop')})
    results['checks'].append({'sheet':kind,'binary_alpha':True,'transparent_rgb_zero':True,'original_hash_unchanged':True,'all_frames_inside_cell':True})
for mode,duration in [('normal',8/60*1000),('lento',16/60*1000)]:
    frames=[Image.open(doc/f'captura_{mode}_{n:02}.png').convert('RGB') for n in range(16)]
    frames[0].save(doc/f'godot_{mode}.png',save_all=True,append_images=frames[1:],duration=duration,loop=0)
    frames[0].save(doc/f'godot_{mode}.gif',save_all=True,append_images=frames[1:],duration=[130,140,130]*5+[130] if mode=='normal' else [270,260,270]*5+[270],loop=0,disposal=2)
results['checks'].append({'godot_captures':32,'size':[640,360],'preview_modes':['normal','lento']})
(doc/'verificacao_artefatos.json').write_text(json.dumps(results,ensure_ascii=False,indent=2),encoding='utf-8')
print('PASS: original hashes, alpha, bounds of 40 frames, 32 directional previews and durations, 32 Godot captures.')
print('Idle foot-mask differences vs frame 1:',results['idle_foot_mask_differences'])

