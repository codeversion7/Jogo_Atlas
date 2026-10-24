"""Prévias a partir das capturas do Godot e inspeção das folhas exportadas."""
from pathlib import Path
from PIL import Image

root = Path(__file__).resolve().parents[1]
folder = root / 'docs/arte/npc/previas'
frames = [Image.open(folder / f'npc_{i:02d}.png').convert('RGB') for i in range(40)]
mosaic = Image.new('RGB',(2560,900))
for i, frame in enumerate(frames):
    mosaic.paste(frame.resize((320,180)),((i%8)*320,(i//8)*180))
palette = mosaic.quantize(colors=240)
indexed = [frame.quantize(palette=palette,dither=Image.Dither.NONE) for frame in frames]
for name, duration in [('normal',40),('lento',120)]:
    path = folder / f'npc_{name}.gif'
    indexed[0].save(path,save_all=True,append_images=indexed[1:],duration=duration,loop=0,optimize=False,disposal=2)
    with Image.open(path) as result:
        total = 0
        for i in range(result.n_frames):
            result.seek(i)
            total += result.info['duration']
        assert total == duration*40
        print(f'{path.name}: {result.n_frames} frames, {total} ms')
count = 0
for path in (root / 'assets/npcs/companheiro/animacoes_v1').glob('*.png'):
    with Image.open(path) as sheet:
        assert sheet.mode=='RGBA' and sheet.height==64 and sheet.width%64==0
        for x in range(0,sheet.width,64):
            bounds = sheet.getchannel('A').crop((x,0,x+64,64)).getbbox()
            assert bounds is None or (bounds[0]>0 and bounds[1]>0 and bounds[2]<64 and bounds[3]<64), str(path)
            count += 1
assert count == 648
print(f'ATLAS_COMPANION_SHEETS: {count} layer frames, no edge clipping; previews verified')
