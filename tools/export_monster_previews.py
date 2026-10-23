"""Empacota capturas reais do Godot em GIF/APNG; não altera a arte-fonte."""
from pathlib import Path
from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "docs/arte/monstros/previas"
MODES = {"idle": (8, 6), "walk": (12, 12), "run": (12, 18), "hurt": (5, 20)}

for mode, (count, fps) in MODES.items():
    frames = [Image.open(OUT / f"{mode}_{i:02d}.png").convert("RGBA") for i in range(count)]
    durations = [1000 / fps] * count
    if mode == "hurt":
        durations[-1] += 350  # Repouso no fim do recuo, somente na prévia.
    frames[0].save(OUT / f"{mode}.png", save_all=True, append_images=frames[1:],
                   duration=durations, loop=0, disposal=0, blend=0)
    gif_durations = [10 * (round((i+1)*100/fps)-round(i*100/fps)) for i in range(count)]
    if mode == "hurt":
        gif_durations[-1] += 350
    # Paleta compartilhada evita mudanças de cor entre quadros da prévia.
    palette = frames[0].convert("RGB").quantize(colors=256)
    gifs = [frame.convert("RGB").quantize(palette=palette, dither=Image.Dither.NONE) for frame in frames]
    gifs[0].save(OUT / f"{mode}.gif", save_all=True, append_images=gifs[1:],
                 duration=gif_durations, loop=0, disposal=2, optimize=False)
    with Image.open(OUT / f"{mode}.png") as result:
        assert result.n_frames == count
    with Image.open(OUT / f"{mode}.gif") as result:
        assert result.n_frames == count
    print(f"{mode}: {count} frames, GIF/APNG verified")

(OUT.parent / "previas.html").write_text("""<!doctype html><meta charset="utf-8">
<title>ATLAS — animações dos monstros</title>
<style>body{background:#0c1116;color:#eadcc0;font:16px sans-serif;max-width:1320px;margin:24px auto}img{width:640px;image-rendering:pixelated}section{display:inline-block;margin:8px}h2{font-size:18px}</style>
<h1>ATLAS — quatro monstros, quatro direções</h1>
<p>Arte original articulada por malha no Godot. Provisório; sem ataques novos. Linhas: Fenda, Carcaça, Esporo, Escavador. Colunas: frente, esquerda, direita, costas.</p>
""" + "".join(f'<section><h2>{title}</h2><img src="previas/{mode}.png" alt="{title}"></section>'
for mode, title in [("idle","Parado"),("walk","Caminhada"),("run","Corrida"),("hurt","Dano")]), encoding="utf-8")
