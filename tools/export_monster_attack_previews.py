"""Empacota capturas do Godot; não altera as fontes dos personagens."""
from pathlib import Path
import json
from PIL import Image

root = Path(__file__).resolve().parents[1]
folder = root / 'docs/arte/monstros/ataques_v1/previas'
frames = [Image.open(folder / f'ataques_{i:02d}.png').convert('RGB') for i in range(50)]
palette = frames[0].quantize(colors=192)
indexed = [frame.quantize(palette=palette, dither=Image.Dither.NONE) for frame in frames]
for name, duration in [('normal', 50), ('lento', 150)]:
    path = folder / f'ataques_{name}.gif'
    indexed[0].save(path, save_all=True, append_images=indexed[1:], duration=duration, loop=0, optimize=False, disposal=2)
    with Image.open(path) as preview:
        total = 0
        for i in range(preview.n_frames):
            preview.seek(i)
            total += preview.info['duration']
        assert total == duration * len(frames)
        assert preview.n_frames > 20
        print(f'{path.name}: {preview.n_frames} frames, {total} ms')
print('ATLAS_ATTACK_PREVIEWS: normal and slow verified')
catalog = json.loads((root / 'assets/monstros/ataques_v1/profiles.json').read_text(encoding='utf-8'))
checked = 0
for profile in catalog['attacks']:
    count = sum(phase['frames'] for phase in profile['phases'])
    for layer in ['body', 'effects', 'combined']:
        with Image.open(root / f"assets/monstros/ataques_v1/{profile['id']}_{layer}.png") as sheet:
            assert sheet.mode == 'RGBA' and sheet.size == (count * 128, 128)
            for i in range(count):
                alpha = sheet.getchannel('A').crop((i*128, 0, (i+1)*128, 128))
                bounds = alpha.getbbox()
                assert bounds is None or (bounds[0] > 0 and bounds[1] > 0 and bounds[2] < 128 and bounds[3] < 128), f"Clipped: {profile['id']} {layer} {i}"
                checked += 1
print(f'ATLAS_ATTACK_SHEETS: {checked} layer frames checked, no edge clipping')
