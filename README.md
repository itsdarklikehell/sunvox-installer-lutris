# sunvox-installer-lutris

Installer scripts for [SunVox](https://warmplace.ru/soft/sunvox/) — a small, fast and
powerful modular synthesizer with a pattern-based sequencer (tracker).

This repository contains two ways to install SunVox:

- `sunvox-installer.sh` — a standalone shell installer that installs SunVox
  system-wide into `/opt/sunvox` and creates desktop launchers.
- `sunvox-installer.yaml` — a [Lutris](https://lutris.net/) install script.

## Shell installer

### Dependencies

The script needs the following packages (Debian/Ubuntu names):

```
sudo apt install wget unzip xdotool
```

`xdotool` is only required for the optional "SunVox Gnome-Integration" launcher,
which fixes window class detection under GNOME.

### Usage

```bash
git clone https://github.com/itsdarklikehell/sunvox-installer-lutris.git
cd sunvox-installer-lutris
chmod +x sunvox-installer.sh
./sunvox-installer.sh
```

The script prompts for the SunVox version to install (for example `2.1.2`) and then
downloads `sunvox-<version>.zip` from the official server at
<https://warmplace.ru/soft/sunvox/>. Check that page for the current version number.

`sudo` is used to write to `/opt` and `/usr/share/applications`, so you will be asked
for your password.

### What it installs

- SunVox into `/opt/sunvox`
- `sunvox` and `sunvox_opengl` symlinks in `/usr/local/bin`
- Desktop entries: `sunvox.desktop`, `sunvox-opengl.desktop`, `sunvox-fix.desktop`

Re-running the script removes the previous installation first.

### Launching

From a terminal:

```bash
sunvox        # default build
sunvox_opengl # OpenGL build
```

Or from your desktop application menu.

## Lutris installer

Install `sunvox-installer.yaml` through Lutris via
*Add game → Install from a local install script*.

## License

SunVox itself is distributed under its own license by Alexander Zolotov (NightRadio);
see <https://warmplace.ru/soft/sunvox/> for details.


---

## 🎥 Gource Visualization

De ontwikkelhistorie van dit project in een film:

<video src="https://raw.githubusercontent.com/itsdarklikehell/sunvox-installer-lutris/main/gource.mp4" controls width="100%"></video>

*De video wordt automatisch gegenereerd door de [Gource workflow](.github/workflows/gource.yml) bij elke push.*

Lokale video genereren:

```bash
# Eerst de Gource renderbaan genereren (textuur + tree als PPM-stream):
gource --max-files 1000 --key -800x600 \
  --highlight-users --filename-time 3 --output-framerate 60 \
  -s 0.6 --multi-sampling --auto-skip-seconds 0.1 \
  --stop-at-end --hide mouse,progress -o gource.ppm

# PPM stream naar MP4 (hoge kwaliteit, 60fps):
ffmpeg -y -r 60 -f image2pipe -vcodec ppm -i gource.ppm \
  -vcodec libx264 -preset medium -pix_fmt yuv420p \
  -crf 1 -threads 0 -bf 0 gource.mp4
```

Voor een kleinere versie (640x480, voor Telegram/markdown):

```bash
ffmpeg -y -i gource.mp4 -vf "scale=640:480" -c:v libx264 -crf 23 -preset fast gource_telegram.mp4
```
