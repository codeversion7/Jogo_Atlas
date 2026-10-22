@echo off
setlocal
set "ATLAS_GODOT=%GODOT_BIN%"
if not defined ATLAS_GODOT set "ATLAS_GODOT=C:\Users\Arthur-Gamer\OneDrive\Documentos\Godot\Godot_v4.7.2-stable_win64.exe"
if not exist "%ATLAS_GODOT%" (
  echo Godot 4.7.2 nao encontrado. Abra project.godot no Godot e use F5.
  echo Ou defina GODOT_BIN com o caminho do executavel Godot 4.7.2.
  pause
  exit /b 1
)
start "ATLAS" "%ATLAS_GODOT%" --path "%~dp0."
