"""Cria uma revisão isolada do ataque sobre o personagem SVG nativo atual.
Não executa o gerador anterior nem modifica seus arquivos. Biblioteca padrão.
"""
import ast
import copy
import hashlib
import json
import math
from pathlib import Path
import xml.etree.ElementTree as ET

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "assets/personagem/ataque_adaga_v1"
OUT.mkdir(parents=True, exist_ok=True)
SOURCE = ROOT / "tools/generate_provisional_character.py"

class NoArms(ast.NodeTransformer):
    def visit_For(self, node):
        if (isinstance(node.iter, ast.Call) and isinstance(node.iter.func, ast.Name)
                and node.iter.func.id == "enumerate" and node.iter.args
                and isinstance(node.iter.args[0], ast.Name) and node.iter.args[0].id == "hands"):
            return ast.Pass()
        return self.generic_visit(node)

# Reutiliza somente a paleta e a função de desenho. Não importa o módulo executável.
tree = ast.parse(SOURCE.read_text(encoding="utf-8-sig"))
nodes = [copy.deepcopy(node) for node in tree.body
         if (isinstance(node, ast.FunctionDef) and node.name == "sprite")
         or (isinstance(node, ast.Assign) and any(isinstance(t, ast.Name) and t.id == "P" for t in node.targets))]
module = ast.fix_missing_locations(NoArms().visit(ast.Module(body=nodes, type_ignores=[])))
namespace = {}
exec(compile(module, str(SOURCE), "exec"), namespace)
base_sprite = namespace["sprite"]
P = namespace["P"]

DIRECTIONS = ["down", "left", "right", "up"]
PHASES = ["attack_windup"] * 2 + ["attack_active"] * 4 + ["attack_recovery"] * 6
DURATIONS = [0.04] * 2 + [0.03] * 4 + [0.2 / 6] * 6
POSITIONS = {
    "down": [(28,29),(29,30),(28,38),(28,39),(22,40),(16,37),(16,37),(19,35),(23,33),(26,32),(27,31),(27,31)],
    "right": [(21,24),(19,22),(26,22),(33,25),(35,29),(32,32),(30,32),(28,32),(27,31),(27,31),(27,31),(27,31)],
    "up": [(13,28),(11,30),(8,24),(10,17),(17,13),(24,17),(24,18),(23,21),(21,24),(18,27),(15,30),(14,31)]}
ANGLES = {
    "down": [-0.8,-0.5,1.0,1.4,1.8,2.3,2.3,2.0,1.7,1.5,1.3,1.3],
    "right": [-1.8,-1.9,-0.4,-0.05,0.3,0.7,0.8,1.1,1.2,1.3,1.3,1.3],
    "up": [2.0,2.1,-2.4,-1.9,-1.5,-0.8,-0.6,-0.3,0.3,0.8,1.1,1.3]}

def polygon(points, color, opacity=None):
    points = " ".join(f"{round(x)},{round(y)}" for x,y in points)
    extra = f' opacity="{opacity}"' if opacity is not None else ""
    return f'<polygon points="{points}" fill="{P.get(color,color)}"{extra}/>'

def arm(shoulder, hand, light=True):
    sx,sy=shoulder; hx,hy=hand
    elbow=((sx+hx)/2 + (-2 if hx<sx else 2),(sy+hy)/2+1)
    ex,ey=elbow
    value=polygon([(sx-2,sy-1),(sx+2,sy-1),(ex+2,ey),(hx+2,hy),(hx-2,hy+2),(ex-2,ey+2)],"ink")
    value+=polygon([(sx-1,sy),(sx+1,sy),(ex+1,ey),(hx+1,hy),(hx-1,hy+1),(ex-1,ey+1)],"jacket" if light else "jdark")
    value+=polygon([(hx-2,hy-2),(hx+2,hy-2),(hx+2,hy),(hx-2,hy)],"shirt")
    value+=polygon([(hx-2,hy-1),(hx+2,hy-1),(hx+2,hy+3),(hx-2,hy+3)],"ink")
    value+=polygon([(hx-1,hy),(hx+1,hy),(hx+1,hy+2),(hx-1,hy+2)],"skin")
    return value

def dagger(hand, angle):
    hx,hy=hand; dx,dy=math.cos(angle),math.sin(angle); nx,ny=-dy,dx
    def pt(along,across=0): return (hx+dx*along+nx*across,hy+dy*along+ny*across)
    # Lâmina curta e fosca, pequena falha no fio, guarda discreta e cabo gasto.
    value=polygon([pt(-5,-2),pt(0,-2),pt(0,2),pt(-5,2)],"ink")
    value+=polygon([pt(-4,-1),pt(0,-1),pt(0,1),pt(-4,1)],"#493c34")
    value+=polygon([pt(-3,-1),pt(-2,-1),pt(-2,1),pt(-3,1)],"#87745c")
    value+=polygon([pt(-1,-3),pt(1,-3),pt(1,3),pt(-1,3)],"ink")
    value+=polygon([pt(0,-2),pt(1,-2),pt(1,2),pt(0,2)],"#9d8860")
    value+=polygon([pt(1,-2),pt(8,-2),pt(12,0),pt(8,2),pt(6,2),pt(5,1),pt(4,2),pt(1,2)],"ink")
    value+=polygon([pt(2,-1),pt(8,-1),pt(10,0),pt(7,1),pt(5,0),pt(4,1),pt(2,1)],"#9da9a6")
    value+=polygon([pt(2,-1),pt(7,-1),pt(9,0),pt(2,0)],"#d9d9bc")
    return value,(round(hx+dx*12),round(hy+dy*12))

def canvas(content):
    return '<svg xmlns="http://www.w3.org/2000/svg" width="80" height="80" viewBox="0 0 80 80" shape-rendering="crispEdges">'+content+'</svg>'

def transform(content, direction):
    if direction=="left": content='<g transform="translate(40 0) scale(-1 1)">'+content+'</g>'
    return '<g transform="translate(20 16)">'+content+'</g>'

manifest={"version":1,"status":"prepared_for_review_not_integrated","native_format":"SVG integer primitives",
          "source_generator_sha256":hashlib.sha256(SOURCE.read_bytes()).hexdigest(),
          "canvas":[80,80],"pivot":[40,62],"source_character_pivot":[20,46],
          "directions":DIRECTIONS,"total_seconds":0.4,"phases_seconds":{"attack_windup":0.08,"attack_active":0.12,"attack_recovery":0.20},
          "layers":["body","dagger","trail","combined"],"frames":[]}
manifest["unchanged_runtime_sha256"]={str(path):hashlib.sha256((ROOT/path).read_bytes()).hexdigest()
    for path in ["scripts/atlas_visual.gd","scripts/combat_player.gd","assets/personagem/provisorio/atlas_motion.tres","assets/personagem/provisorio/atlas_actions.tres"]}

for direction in DIRECTIONS:
    d="right" if direction=="left" else direction
    tips=[]
    for i in range(12):
        hand=POSITIONS[d][i]
        weapon,tip=dagger(hand,ANGLES[d][i]); tips.append(tip)
        body=base_sprite(d,"idle",0)
        shoulder=(14,23) if d=="up" else (25,23)
        other_shoulder=(26,23) if d=="up" else (13,23)
        other_hand=(27,29) if d=="up" else (11,29)
        # O tronco gira discretamente sobre os pés fixos, sem root motion.
        root=ET.fromstring('<svg>'+body+'</svg>')
        upper=list(root)[-1]
        lean=(-1 if i<2 else 1 if i<6 else 0) if d=="right" else 0
        upper.set("transform",f"translate({lean} 0)")
        body="".join(ET.tostring(node,encoding="unicode") for node in root)
        rear_arm=arm(other_shoulder,other_hand,False)
        front_arm=arm((shoulder[0]+lean,shoulder[1]),hand)
        body=rear_arm+body+front_arm
        trail=""
        if 3<=i<=5:
            points=tips[max(2,i-2):i+1]
            # Rastro curto acompanha a ponta; não representa a hitbox.
            points_text=" ".join(f"{x},{y}" for x,y in points)
            trail=f'<polyline points="{points_text}" fill="none" stroke="#dcc79c" stroke-width="2" opacity="0.65"/>'
        behind=d=="up"
        combined=trail+(weapon+body if behind else body+weapon)
        values={"body":body,"dagger":weapon,"trail":trail,"combined":combined}
        for layer,value in values.items():
            (OUT/f"{layer}_{direction}_{i:02d}.svg").write_text(canvas(transform(value,direction)),encoding="utf-8")
        def coords(point):
            x,y=point
            if direction=="left": x=40-x
            return [round(x+20),round(y+16)]
        manifest["frames"].append({"direction":direction,"index":i,"phase":PHASES[i],"duration":DURATIONS[i],
            "hand_px":coords(hand),"tip_px":coords(tip),"damage_phase":2<=i<=5,"dagger_behind_body":behind})

for layer in manifest["layers"]:
    ext=[]; clips=[]
    for direction in DIRECTIONS:
        ids=[]
        for i in range(12):
            index=len(ext)+1; ids.append(index)
            ext.append(f'[ext_resource type="Texture2D" path="res://assets/personagem/ataque_adaga_v1/{layer}_{direction}_{i:02d}.svg" id="{index}"]')
        for phase,indices in [("attack_windup",range(0,2)),("attack_active",range(2,6)),("attack_recovery",range(6,12)),("attack",range(12))]:
            frames=", ".join('{"duration": '+repr(DURATIONS[i])+', "texture": ExtResource("'+str(ids[i])+'")} ' for i in indices)
            clips.append('{"frames": ['+frames+'], "loop": false, "name": &"'+phase+'_'+direction+'", "speed": 1.0}')
    text=f'[gd_resource type="SpriteFrames" load_steps={len(ext)+1} format=3]\n\n'+"\n".join(ext)+'\n\n[resource]\nanimations = ['+",\n".join(clips)+']\n'
    (OUT/f"atlas_attack_{layer}.tres").write_text(text,encoding="utf-8")

icon,_=dagger((8,18),-math.pi/2)
(OUT/"adaga_emergencia.svg").write_text('<svg xmlns="http://www.w3.org/2000/svg" width="16" height="24" shape-rendering="crispEdges">'+icon+'</svg>',encoding="utf-8")
(OUT/"manifesto.json").write_text(json.dumps(manifest,ensure_ascii=False,indent=2),encoding="utf-8")
print("ATLAS_DAGGER_ASSETS: 48 poses, 4 layers, 4 SpriteFrames, dagger icon, manifest; gameplay unchanged")
