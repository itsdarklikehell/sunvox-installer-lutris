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

```
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

```
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
