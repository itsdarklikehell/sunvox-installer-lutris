#! /bin/bash

read -p "Please enter the version of sunvox, you want to install (Example: 2.1b): " VERSION 

# Check if the version is provided
if [ -z "$VERSION" ]; then
    echo "Version not provided. Exiting."
    exit 1
fi

echo "Removing previous version"
if [ -d /opt/sunvox ]; then sudo rm -rf /opt/sunvox; fi
if [ -d /usr/local/bin/sunvox ]; then sudo rm /usr/local/bin/sunvox; fi
if [ -d /usr/share/applications/sunvox.desktop ]; then sudo rm /usr/share/applications/sunvox.desktop; fi
if [ -d /usr/share/applications/sunvox-opengl.desktop ]; then sudo rm /usr/share/applications/sunvox-opengl.desktop; fi
if [ -d /usr/share/applications/sunvox-fix.desktop ]; then sudo rm /usr/share/applications/sunvox-fix.desktop; fi

echo "Download SunVox from official server"
wget https://warmplace.ru/soft/sunvox/sunvox-$VERSION.zip
wget https://warmplace.ru/soft/sunvox/images/icon.png
# Unzip the downloaded file
unzip sunvox-$VERSION.zip
rm sunvox-$VERSION.zip

echo "Installation"
# Create a directory for SunVox
sudo mkdir /opt/sunvox
sudo mv icon.png sunvox/
# Move the SunVox files to the new directory
sudo mv sunvox/* /opt/sunvox/
rm -r sunvox

echo "Creating starters"
# Create a symbolic link to the SunVox binary
sudo ln -s /opt/sunvox/sunvox/linux_x86_64/sunvox /usr/local/bin/
sudo ln -s /opt/sunvox/sunvox/linux_x86_64/sunvox_opengl /usr/local/bin/
# Create a desktop file for SunVox
echo "[Desktop Entry]
Name=SunVox
Exec=/opt/sunvox/sunvox/linux_x86_64/sunvox
Icon=/opt/sunvox/icon.png
Type=Application" | sudo tee /usr/share/applications/sunvox.desktop > /dev/null

echo "[Desktop Entry]
Name=SunVox Open-GL
Exec=/opt/sunvox/sunvox/linux_x86_64/sunvox_opengl
Icon=/opt/sunvox/icon.png
Type=Application" | sudo tee /usr/share/applications/sunvox-opengl.desktop > /dev/null

echo "[Desktop Entry]
Name=SunVox Gnome-Integration
Exec=xdotool search --name "Sunvox" set_window --class "Sunvox"
Icon=/opt/sunvox/icon.png
Type=Application" | sudo tee /usr/share/applications/sunvox-fix.desktop > /dev/null



# Set the permissions of the SunVox files
sudo chown -R $USER:$USER /opt/sunvox
sudo chmod -R 755 /opt/sunvox
echo "Sunvox is now installed on your system. You can start it with following commands from terminal:"
echo "sunvox"
echo "sunvox_opengl"
