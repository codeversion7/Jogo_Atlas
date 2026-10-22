"""Empacota as fontes jogáveis sem cache, credenciais, Git ou builds recursivos."""
from pathlib import Path
import zipfile

root = Path(__file__).resolve().parents[1]
out = root / 'builds' / 'ATLAS_jogavel_fontes.zip'
out.parent.mkdir(exist_ok=True)
exclude = {'.git', '.godot', '.test-user', 'builds', '__pycache__'}
with zipfile.ZipFile(out, 'w', zipfile.ZIP_DEFLATED) as archive:
    for path in sorted(root.rglob('*')):
        rel = path.relative_to(root)
        if not path.is_file() or any(part in exclude for part in rel.parts):
            continue
        if path.suffix.lower() in {'.zip', '.log', '.tmp', '.bak'} or path.name.startswith('.env'):
            continue
        if rel.parts[0] == 'ATLAS_Pacote_Para_Codex':
            continue
        archive.write(path, 'ATLAS/' + rel.as_posix())
with zipfile.ZipFile(out) as archive:
    assert archive.testzip() is None
    assert 'ATLAS/scenes/playable.tscn' in archive.namelist()
    assert 'ATLAS/project.godot' in archive.namelist()
print(out)
