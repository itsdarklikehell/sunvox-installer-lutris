#!/bin/bash
set -euo pipefail

# sunvox-installer: installeert SunVox op Linux
# Gebruik: bash sunvox-installer.sh [VERSION]

VERSION="${1:-}"

if [ -z "$VERSION" ]; then
    read -p "Please enter the version of sunvox, you want to install (Example: 2.1b): " VERSION
fi

if [ -z "$VERSION" ]; then
    echo "Version not provided. Exiting."
    exit 1
fi

echo "Removing previous version"
sudo rm -rf /opt/sunvox
sudo rm -f /usr/local/bin/sunvox /usr/local/bin/sunvox_opengl
sudo rm -f /usr/share/applications/sunvox.desktop
sudo rm -f /usr/share/applications/sunvox-opengl.desktop
sudo rm -f /usr/share/applications/sunvox-fix.desktop

echo "Downloading SunVox from official server"
wget "https://warmplace.ru/soft/sunvox/sunvox-${VERSION}.zip"
wget "https://warmplace.ru/soft/sunvox/images/icon.png"

echo "Unzipping"
unzip -o "sunvox-${VERSION}.zip"
rm "sunvox-${VERSION}.zip"

echo "Installing"
sudo mkdir -p /opt/sunvox
sudo mv icon.png sunvox/
sudo mv sunvox/* /opt/sunvox/
rm -r sunvox

echo "Creating starters"
sudo ln -sf /opt/sunvox/sunvox/linux_x86_64/sunvox /usr/local/bin/
sudo ln -sf /opt/sunvox/sunvox/linux_x86_64/sunvox_opengl /usr/local/bin/

sudo tee /usr/share/applications/sunvox.desktop > /dev/null <<'EOF'
[Desktop Entry]
Name=SunVox
Exec=/opt/sunvox/sunvox/linux_x86_64/sunvox
Icon=/opt/sunvox/icon.png
Type=Application
EOF

sudo tee /usr/share/applications/sunvox-opengl.desktop > /dev/null <<'EOF'
[Desktop Entry]
Name=SunVox Open-GL
Exec=/opt/sunvox/sunvox/linux_x86_64/sunvox_opengl
Icon=/opt/sunvox/icon.png
Type=Application
EOF

sudo tee /usr/share/applications/sunvox-fix.desktop > /dev/null <<'EOF'
[Desktop Entry]
Name=SunVox Gnome-Integration
Exec=xdotool search --name 'Sunvox' set_window --class 'Sunvox'
Icon=/opt/sunvox/icon.png
Type=Application
EOF

echo "SunVox ${VERSION} installed successfully."



# Set the permissions of the SunVox files
sudo chown -R "$USER":"$USER" /opt/sunvox
sudo chmod -R 755 /opt/sunvox
echo "Sunvox is now installed on your system. You can start it with following commands from terminal:"
echo "sunvox"
echo "sunvox_opengl"
