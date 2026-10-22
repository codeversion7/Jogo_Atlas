import sys
from pathlib import Path
from PIL import Image

def components(im, threshold=128, minimum=1000):
    a=im.convert('RGBA').getchannel('A')
    w,h=a.size
    mask=bytearray(1 if p>=threshold else 0 for p in a.get_flattened_data())
    result=[]
    for start in range(w*h):
        if not mask[start]: continue
        mask[start]=0
        stack=[start]; count=0; x0=w; y0=h; x1=0; y1=0
        while stack:
            p=stack.pop(); x=p%w; y=p//w
            count+=1; x0=min(x,x0); y0=min(y,y0); x1=max(x+1,x1); y1=max(y+1,y1)
            for q in ((p-1 if x else -1),(p+1 if x+1<w else -1),(p-w if y else -1),(p+w if y+1<h else -1)):
                if q>=0 and mask[q]: mask[q]=0; stack.append(q)
        if count>=minimum: result.append({'bbox':(x0,y0,x1,y1),'area':count})
    return result

if __name__=='__main__':
    root=Path(__file__).resolve().parents[2]/'referencias/personagem'
    for path in root.glob('Spritesheet*.png'):
        print(path.name,components(Image.open(path)))

