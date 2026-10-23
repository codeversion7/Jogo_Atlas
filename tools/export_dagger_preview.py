"""Empacota capturas do Godot em animações de revisão, sem alterar a arte-fonte."""
import json
from pathlib import Path
from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "docs/arte/ataque_adaga/previas"
manifest = json.loads((ROOT / "assets/personagem/ataque_adaga_v1/manifesto.json").read_text(encoding="utf-8"))
frames = [Image.open(OUT / f"ataque_{i:02d}.png").convert("RGBA") for i in range(12)]
durations = [item["duration"] * 1000 for item in manifest["frames"][:12]]
palette = frames[3].convert("RGB").quantize(colors=256)
gifs = [frame.convert("RGB").quantize(palette=palette, dither=Image.Dither.NONE) for frame in frames]
for name, multiplier in [("ataque_normal",1),("ataque_lento",4)]:
    times = [t * multiplier for t in durations]
    times[-1] += 450
    frames[0].save(OUT / (name+".png"), save_all=True, append_images=frames[1:], duration=times, loop=0, disposal=0, blend=0)
    ticks = []
    elapsed = 0
    last = 0
    for time in times:
        elapsed += time
        tick = round(elapsed/10)*10
        ticks.append(tick-last)
        last = tick
    gifs[0].save(OUT / (name+".gif"), save_all=True, append_images=gifs[1:], duration=ticks, loop=0, disposal=2, optimize=False)
    for extension in ["gif","png"]:
        with Image.open(OUT / f"{name}.{extension}") as output:
            assert output.n_frames == 12
print("ATLAS_DAGGER_PREVIEWS: 2 GIFs + 2 APNGs, 12 frames each; verified")
(OUT.parent / "previas.html").write_text('''<!doctype html><meta charset="utf-8"><title>ATLAS — ataque com adaga</title>
<style>body{background:#10171a;color:#eadfca;font:16px sans-serif;margin:24px}img{width:640px;image-rendering:pixelated}section{display:inline-block;margin:8px}</style>
<h1>ATLAS — revisão do ataque com adaga</h1><p>Frente, esquerda, direita e costas. Preparação: 0,08 s; golpe: 0,12 s; recuperação: 0,20 s. A pausa final é somente da prévia. Não integrado ao combate nesta etapa.</p>
<section><h2>Tempo normal</h2><img src="previas/ataque_normal.png" alt="Ataque em tempo normal"></section>
<section><h2>Quatro vezes mais lento</h2><img src="previas/ataque_lento.png" alt="Ataque em câmera lenta"></section>''',encoding="utf-8")
