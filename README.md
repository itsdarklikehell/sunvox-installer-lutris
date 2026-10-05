# sunvox-installer-lutris

SunVox installer voor Lutris — automatiseert de installatie van SunVox op Linux.

## Vereisten

- Linux (x86_64, ARM, ARM64)
- `wget`, `unzip`, `curl`
- `sudo` rechten

## Installatie

```bash
git clone https://github.com/itsdarklikehell/sunvox-installer-lutris.git
cd sunvox-installer-lutris
chmod +x sunvox-installer.sh
./sunvox-installer.sh <VERSIE>
```

Voorbeeld:
```bash
./sunvox-installer.sh 2.1.1c
```

## Opties

| Optie | Beschrijving |
|-------|-------------|
| `-h, --help` | Toon help bericht |
| `-v, --version` | Toon script versie |
| `-u, --uninstall` | Verwijder SunVox installatie |
| `-d, --dry-run` | Toon wat er zou gebeuren zonder wijzigingen |

## Gebruik

Start SunVox via Lutris of vanaf de terminal:

```bash
sunvox          # Standaard versie
sunvox_opengl   # OpenGL versie
```

## Bijdragen

Zie [CONTRIBUTING.md](CONTRIBUTING.md) voor richtlijnen.

## Licentie

Zie [LICENSE](LICENSE) voor details.
