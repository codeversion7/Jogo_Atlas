"""Author new ATLAS provisional pixel sprites from integer vector primitives.
Does not read, trace, crop, or modify reference artwork. Python stdlib only.
Run from project root: python tools/generate_provisional_character.py
"""
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
OUT=ROOT/'assets/personagem/provisorio'
OUT.mkdir(parents=True,exist_ok=True)
P={'ink':'#171b20','hair':'#32251f','hair2':'#50392a','hair3':'#6a4b32','skin':'#b77c51','light':'#d49b68','shade':'#855438','jacket':'#485968','jlight':'#617480','jdark':'#34414e','shirt':'#b4afa0','pants':'#363b40','pantlight':'#4b5053','boot':'#493a2e','sole':'#251f20','scarf':'#24242a','red':'#863c41','tear':'#907b62'}
def sprite(direction, kind, i):
    a=[]
    def rect(x,y,w,h,c): a.append(f'<rect x="{x}" y="{y}" width="{w}" height="{h}" fill="{P.get(c,c)}"/>')
    def poly(points,c): a.append('<polygon points="'+' '.join(f'{x},{y}' for x,y in points)+'" fill="'+P.get(c,c)+'"/>')
    side=direction in ('left','right'); back=direction=='up'
    phase=[-3,-1,2,3,1,-2][i%6] if kind=='walk' else 0
    bob=1 if kind=='walk' and i%3==1 else 0
    breathe=1 if kind=='idle' and i in (1,2) else 0
    action=kind not in ('idle','walk')
    lean={'attack_windup':-2,'attack_active':3,'attack_recovery':1,'parry':0,'dodge':3,'hurt':-2,'dead':0}.get(kind,0)
    crouch=5 if kind=='dodge' else (2 if kind=='hurt' else 0)
    if kind=='dead':
        # Authored prone silhouette, same floor anchor; no upright sprite rotation.
        rect(5,39,31,5,'ink'); rect(7,38,10,5,'hair'); rect(9,36,8,3,'hair2'); rect(13,40,6,4,'skin')
        rect(18,38,10,6,'jacket'); rect(19,37,8,2,'jlight'); rect(19,42,11,2,'red'); rect(28,40,7,4,'pants'); rect(34,40,4,5,'boot')
        rect(6,43,9,2,'hair'); rect(17,44,9,2,'scarf'); rect(26,44,9,2,'sole')
        return ''.join(a)
    # Independent articulated legs: rear leg first, then opposite supporting leg.
    if side:
        offsets=[(phase, max(0,phase)),(-phase,max(0,-phase))]
        for j,(dx,lift) in enumerate(offsets):
            hip=18+j*3; foot=hip+dx
            poly([(hip-2,31),(hip+3,31),(foot+3,42-lift),(foot-2,42-lift)],'ink')
            poly([(hip-1,33),(hip+2,33),(foot+2,41-lift),(foot-1,41-lift)],'pants' if j==0 else 'pantlight')
            rect(foot-2,42-lift,7,4,'sole'); rect(foot-1,42-lift,5,3,'boot');rect(foot-1,41-lift,4,1,'tear')
    else:
        for j,x in enumerate((14,22)):
            step=phase if j==0 else -phase
            foot_y=43-max(0,step) if kind=='walk' else 43
            poly([(x-1,31),(x+5,31),(x+5,foot_y+3),(x-1,foot_y+3)],'ink')
            rect(x,33,4,max(2,foot_y-32),'pants');rect(x,34,2,max(1,foot_y-34),'pantlight')
            rect(x-1,foot_y,7,3,'sole');rect(x,foot_y,5,2,'boot');rect(x,foot_y-1,4,1,'tear')
    # Upper body rests on fixed hips; small vertical compression, no full-sprite wobble.
    lean += (i-1) if action and kind in ('attack_active','hurt','dodge') else 0
    a.append(f'<g transform="translate({lean} {bob+crouch})">')
    # Scarf tail / ponytail behind torso. Tail moves separately by one pixel.
    sway=(1 if i%3==1 else 0)
    if side:
        poly([(11,20),(15,21),(13+sway,39),(9+sway,42),(10+sway,31)],'ink');rect(11+sway,25,2,13,'red')
        rect(10,12,5,11,'ink');rect(11,13,3,9,'hair2');rect(11,13,3,2,'red')
    else:
        poly([(24,20),(28,22),(27+sway,39),(30+sway,43),(25+sway,41),(23,29)],'ink');poly([(25,24),(27,25),(26+sway,36),(28+sway,40),(25+sway,37)],'red')
    # Jacket, battered lapels, shirt, belt.
    poly([(14,20),(25,20),(29,25+breathe),(27,34),(13,34),(11,25+breathe)],'ink')
    rect(14,22,12,10,'jacket');rect(14,22,3,9,'jlight');rect(24,23,2,9,'jdark')
    if not back:
        rect(18,23,5,9,'shirt');rect(17,22,2,11,'jdark');rect(23,22,2,11,'jdark');rect(20,24,2,2,'#d1c6ad')
    else: rect(16,24,8,1,'jlight');rect(19,26,1,6,'jdark')
    rect(14,32,13,2,'boot');rect(20,32,3,2,'tear');rect(14,29,2,2,'tear')
    # Arms counter swing to legs; action silhouettes change hands/forearms directly.
    swing=int(phase/2)
    hands=[(11,29+swing),(26,29-swing)]
    if side: hands=[(16-phase//2,29),(23+phase//2,29)]
    if action:
        if kind=='attack_windup': hands=[(12,27),(25,19)]
        elif kind=='attack_active': hands=[(12,29),(31,25)]
        elif kind=='attack_recovery': hands=[(12,29),(28,29)]
        elif kind=='parry': hands=[(16,22),(26,22)]
        elif kind=='dodge': hands=[(10,27),(29,25)]
        elif kind=='hurt': hands=[(9,28),(29,29)]
    for j,(hx,hy) in enumerate(hands):
        shoulder=13 if j==0 else 26
        poly([(shoulder-2,22),(shoulder+2,22),(hx+3,hy+2),(hx-2,hy+2)],'ink')
        poly([(shoulder-1,23),(shoulder+1,23),(hx+2,hy),(hx-1,hy)],'jacket' if j else 'jdark')
        rect(hx-1,hy-1,4,2,'shirt');rect(hx-1,hy+1,4,4,'ink');rect(hx,hy+1,3,3,'skin');rect(hx,hy+1,2,1,'light')
    # Head: broad hair cap, medium skin, eyebrows, short defined beard.
    rect(13,7,14,12,'ink');rect(12,10,16,6,'ink')
    if back:
        rect(14,8,12,11,'hair');rect(15,7,9,4,'hair2');rect(14,10,3,6,'hair2');rect(21,9,3,6,'hair3')
        rect(17,17,7,3,'ink');rect(18,18,5,2,'red');rect(18,20,6,7,'ink');rect(19,20,4,6,'hair2');rect(20,21,2,4,'hair3')
    elif side:
        rect(16,10,11,9,'shade');rect(18,10,10,8,'skin');rect(23,12,5,5,'light');rect(28,14,2,3,'skin')
        rect(24,12,4,1,'ink');rect(26,13,1,2,'ink');rect(21,17,7,4,'hair');rect(24,17,3,1,'shade');rect(19,14,2,3,'light')
        poly([(12,10),(14,6),(22,5),(27,8),(27,11),(23,10),(20,12),(16,14),(15,18),(13,15)],'hair')
        rect(15,8,9,2,'hair2');rect(15,10,5,2,'hair2');rect(18,7,5,1,'hair3')
    else:
        rect(14,10,12,9,'skin');rect(16,11,8,7,'light');rect(13,14,2,3,'skin');rect(25,14,2,3,'shade')
        rect(16,13,3,1,'hair');rect(22,13,3,1,'hair');rect(17,14,1,2,'ink');rect(23,14,1,2,'ink');rect(20,15,1,2,'skin')
        rect(15,17,11,3,'hair');rect(17,20,7,1,'hair');rect(19,17,3,1,'shade')
        poly([(12,12),(13,8),(16,6),(23,5),(27,8),(28,12),(25,11),(23,9),(20,10),(18,12),(16,11),(14,15),(13,15)],'hair')
        rect(16,7,7,2,'hair2');rect(14,10,4,2,'hair2');rect(20,7,4,1,'hair3')
    # Scarf collar and dark-red stripe remain readable in every view.
    if not back:
        rect(14,20,13,3,'scarf');rect(16,22,10,1,'red');rect(24,20,3,2,'red')
    a.append('</g>')
    content=''.join(a)
    if direction=='left': content='<g transform="translate(40 0) scale(-1 1)">'+content+'</g>'
    return content

def resource(filename,clips):
    ex=[]; animations=[]
    for direction in ('down','left','right','up'):
        for kind,n,fps,loop in clips:
            refs=[]
            for i in range(n):
                name=f'{kind}_{direction}_{i}'
                svg='<svg xmlns="http://www.w3.org/2000/svg" width="40" height="48" viewBox="0 0 40 48" shape-rendering="crispEdges">'+sprite(direction,kind,i)+'</svg>'
                (OUT/(name+'.svg')).write_text(svg,encoding='utf8')
                idx=len(ex)+1
                ex.append(f'[ext_resource type="Texture2D" path="res://assets/personagem/provisorio/{name}.svg" id="{idx}"]')
                refs.append('{"duration": 1.0, "texture": ExtResource("'+str(idx)+'")}')
            animations.append('{"frames": ['+', '.join(refs)+'], "loop": '+str(loop).lower()+', "name": &"'+kind+'_'+direction+'", "speed": '+str(float(fps))+'}')
    text=f'[gd_resource type="SpriteFrames" load_steps={len(ex)+1} format=3]\n\n'+'\n'.join(ex)+'\n\n[resource]\nanimations = ['+',\n'.join(animations)+']\n'
    (OUT/filename).write_text(text,encoding='utf8')
resource('atlas_motion.tres',[('idle',4,4,True),('walk',6,8,True)])
resource('atlas_actions.tres',[(k,3,12,False) for k in ('attack_windup','attack_active','attack_recovery','parry','dodge','hurt','dead')])
# Contact sheet of authored limb phases, readable in a browser or SVG viewer.
parts=['<svg xmlns="http://www.w3.org/2000/svg" width="960" height="768" viewBox="0 0 240 192"><rect width="240" height="192" fill="#707d79"/>']
for row,d in enumerate(('down','left','right','up')):
    for col in range(6): parts.append(f'<g transform="translate({40*col} {48*row})">'+sprite(d,'walk',col)+'</g>')
parts.append('</svg>');(OUT/'walk_contact_sheet.svg').write_text(''.join(parts),encoding='utf8')
print('Authored 124 transparent 40x48 SVG sprite frames + 2 resources + contact sheet')
