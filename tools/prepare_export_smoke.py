"""Build a tiny independent harness, mounting only the actual game PCK for gameplay.
Usage: python tools/prepare_export_smoke.py <empty-output-directory>
No game assets or scripts are copied into the harness as fallback resources.
"""
from pathlib import Path
import sys
source=Path(__file__).resolve().parents[1]
dest=Path(sys.argv[1]).resolve()
dest.mkdir(parents=True,exist_ok=True)
assert not any(dest.iterdir()), 'Use a new empty harness directory'
project=(source/'project.godot').read_text(encoding='utf-8-sig')
project=project.replace('run/main_scene="res://scenes/playable.tscn"','run/main_scene="res://smoke.tscn"')
(dest/'project.godot').write_bytes(project.encode('utf-8'))
(dest/'smoke.gd').write_bytes((source/'tools/verify_export_runtime.gd').read_bytes())
(dest/'smoke.tscn').write_text('[gd_scene load_steps=2 format=3]\n[ext_resource type="Script" path="res://smoke.gd" id="1"]\n[node name="ExportSmoke" type="Node"]\nscript = ExtResource("1")\n',encoding='utf-8')
(dest/'export_presets.cfg').write_text('[preset.0]\nname="Windows Desktop"\nplatform="Windows Desktop"\nrunnable=true\nexport_filter="all_resources"\ninclude_filter=""\nexclude_filter=""\nexport_path="Harness.exe"\nscript_export_mode=2\n[preset.0.options]\nbinary_format/architecture="x86_64"\nbinary_format/embed_pck=false\ndebug/export_console_wrapper=1\ncodesign/enable=false\n',encoding='utf-8')
print('Isolated export harness ready:',dest)
