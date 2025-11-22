#!/bin/bash

if [ -d "/usr/share/sddm/themes/silent" ]; then 
    echo " El tema SilentSDDM ya se encuentra instalado en el sistema"
else
    sudo dnf install qt6-qtvirtualkeyboard qt6-qtmultimedia
    git clone -b main --depth=1 https://github.com/uiriansan/SilentSDDM
    cd SilentSDDM/
    sudo mkdir -p /usr/share/sddm/themes/silent
    sudo rm *.nix *.lock LICENSE README.md
    sudo cp -rf . /usr/share/sddm/themes/silent/
    sudo cp -r /usr/share/sddm/themes/silent/fonts/* /usr/share/fonts/
    sudo tee /etc/sddm.conf > /dev/null <<EOF
    [General]
    InputMethod=qtvirtualkeyboard
    GreeterEnvironment=QML2_IMPORT_PATH=/usr/share/sddm/themes/silent/components/,QT_IM_MODULE=qtvirtualkeyboard

    [Theme]
    Current=silent
    EOF
    cd ..
    rm -rf SilentSDDM/
    echo "El tema SilentSDDM se ha instalado correctamente"
fi


